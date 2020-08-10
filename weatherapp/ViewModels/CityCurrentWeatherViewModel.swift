//
//  CityCurrentWeatherViewModel.swift
//  weatherapp
//
//  Created by Enchappolis on 8/8/20.
//  Copyright © 2020 Enchappolis. All rights reserved.
//
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

struct CityCurrentWeatherViewModel {
        
    // MARK: - Private Variables
    private let waCityCurrentWeather: WACityCurrentWeather
    
    // MARK: - Init
    init(waCityCurrentWeather: WACityCurrentWeather) {
        self.waCityCurrentWeather = waCityCurrentWeather
    }
    
    // MARK: - Public Properties
    var name: String {
        return waCityCurrentWeather.name
    }
    
    var weatherDescription: String {
        
        return waCityCurrentWeather.weather[0].description
    }
    
    var temperature: String {
            
        return TemperatureConverterViewModel.temperature(kelvin: waCityCurrentWeather.main.temp)
    }
    
    var icon: String {
        
        return waCityCurrentWeather.weather[0].icon
    }
    
    func nameStateCountry(forState state: String,
                          andCountry country: String,
                          withfontSize fontSize: CGFloat) -> NSMutableAttributedString {
        
        var stateCountry = ""
        let state = state
        let country = country
        
        if !state.isEmpty {
            
            stateCountry.append(", \(state)")
        }
        
        if !country.isEmpty {
            
            stateCountry.append(", \(country)")
        }
        
        let firstAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        let secondAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.gray
        ]
        
        let firstString = NSMutableAttributedString(string: self.name, attributes: firstAttributes)
        
        let secondString = NSAttributedString(string: stateCountry, attributes: secondAttributes)
        
        firstString.append(secondString)
        
        return firstString
    }
}
