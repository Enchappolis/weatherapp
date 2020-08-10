//
//  WAClient.swift
//  weatherapp
//
//  Created by Enchappolis on 7/26/20.
//  Copyright © 2020 Enchappolis. All rights reserved.
//  https://github.com/Enchappolis
/*
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 distribute, sublicense, create a derivative work, and/or sell copies of the
 Software in any work that is designed, intended, or marketed for pedagogical or
 instructional purposes related to programming, coding, application development,
 or information technology.  Permission for such use, copying, modification,
 merger, publication, distribution, sublicensing, creation of derivative works,
 or sale is expressly withheld.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
*/

import UIKit

class WAClient {
    
    enum Endpoints {
        
        static let base = "https://api.openweathermap.org/data/2.5/"
        static let apiKeyParam = "\(WAAPIKey.key.rawValue)"
        static let iconBase = "https://openweathermap.org/img/wn/" // /10d@2x.png"
        
        // Current weather.
        // api.openweathermap.org/data/2.5/weather?id={city id}&appid={your api key}
        
        // 5Days3Hours
        // api.openweathermap.org/data/2.5/forecast?id={city ID}&appid={your api key}
        
        case currentWeather(String)
        case _5Days3Hours(String)
        case icon(String)
        
        private var stringValue: String {
            
            switch self {
            case .currentWeather(let cityID):
                return "\(Endpoints.base)weather?id=\(cityID)&appid=\(Endpoints.apiKeyParam)"
            case ._5Days3Hours(let cityID):
                return "\(Endpoints.base)forecast?id=\(cityID)&appid=\(Endpoints.apiKeyParam)"
            case .icon(let iconID):
                return "\(Endpoints.iconBase)\(iconID)@2x.png"
            }
        }
        
        var url: URL? {
            return URL(string: stringValue)
        }
    }
    
    static func getRequest<ResponseType: Decodable>(
        url: URL,
        responseType: ResponseType.Type,
        completion: @escaping (Result<ResponseType, WANetworkError.NetworkError>) -> ()) -> URLSessionDataTask {
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else {
                DispatchQueue.main.async {
                    completion(.failure(.domainError(error!.localizedDescription)))
                }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.noDataError(error!.localizedDescription)))
                }
                return
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    completion(.failure(.httpResponseNot200(String(httpResponse.statusCode))))
                }
                return
            }

            do {
                
                let decoder = JSONDecoder()
                
                let cityWeatcher = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completion(.success(cityWeatcher))
                }
            }
            catch {
                
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error.localizedDescription)))
                }
                
                print("error:\(error.localizedDescription)")
            }
        }
        
        dataTask.resume()
        
        return dataTask
    }
    
    static func requestCurrentWeather(forCityID: String, completion: @escaping (Result<WACityCurrentWeather, WANetworkError.NetworkError>) -> ()) -> URLSessionDataTask? {
        
        guard let url = WAClient.Endpoints.currentWeather(forCityID).url else {
            
            completion(.failure(.urlError))
            return nil
        }
        
        let dataTask = getRequest(url: url, responseType: WACityCurrentWeather.self) { (result) in
            
            completion(result)
        }
        
        return dataTask
    }
    
    static func requestWeather5Days3Hours(forCityID: String, completion: @escaping (Result<WACity5Days3Hours, WANetworkError.NetworkError>) -> ()) -> URLSessionDataTask? {
        
        guard let url = WAClient.Endpoints._5Days3Hours(forCityID).url else {
            
            completion(.failure(.urlError))
            return nil
        }
        
        let dataTask = getRequest(url: url, responseType: WACity5Days3Hours.self) { (result) in
            
            completion(result)
        }
        
        return dataTask
    }
    
    static func requestIcon(forIconID: String, completion: @escaping (Result<UIImage, WANetworkError.NetworkError>) -> ()) -> URLSessionDataTask? {
        
        guard let url = WAClient.Endpoints.icon(forIconID).url else {
            
            completion(.failure(.urlError))
            return nil
        }
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard error == nil else {
                print("error: \(error!.localizedDescription)")
                
                DispatchQueue.main.async {
                    completion(.failure(.domainError(error!.localizedDescription)))
                }
                
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    
                    completion(.failure(.noDataError(error!.localizedDescription)))
                }
                return
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                DispatchQueue.main.async {
                    
                    completion(.failure(.httpResponseNot200(String(httpResponse.statusCode))))
                }
                return
            }
            
            if let Image = UIImage(data: data) {
                
                DispatchQueue.main.async {
                    completion(.success(Image))
                }
            }
            else {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError("Could not decode Image.")))
                }
            }
        }
        
        dataTask.resume()
        
        return dataTask
    }
}
