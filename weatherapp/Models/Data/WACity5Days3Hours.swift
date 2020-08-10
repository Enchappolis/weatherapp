//
//  WACityList5Days3Hours.swift
//  weatherapp
//
//  Created by Enchappolis on 8/4/20.
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

import Foundation

/*
 {
    "cod": "200",
    "message": 0,
    "cnt": 40,
    "list": [
         {
            "dt": 1596574800,
            "main": {
                "temp": 290.72,
                "feels_like": 286.78,
                "temp_min": 290.56,
                "temp_max": 290.72,
                "pressure": 1014,
                "sea_level": 1015,
                "grnd_level": 1012,
                "humidity": 57,
                "temp_kf": 0.16
            },
            "weather": [
                 {
                    "id": 803,
                    "main": "Clouds",
                    "description": "broken clouds",
                    "icon": "04n"
                 }
            ],
            "clouds": {
                "all": 79
            },
            "wind": {
                "speed": 5.3,
                "deg": 224
            },
            "visibility": 10000,
            "pop": 0,
            "sys": {
                "pod": "n"
            },
            "dt_txt": "2020-08-04 21:00:00" // Doesn't change for different language.
         },
        ...
    ],
    "city": {
        "id": 2643743,
        "name": "London",
        "coord": {
            "lat": 51.5085,
            "lon": -0.1257
         },
        "country": "GB",
        "timezone": 3600,
        "sunrise": 1596515359,
        "sunset": 1596570226
     }
 }

 */

struct WACity5Days3Hours: Decodable {
    
    var cod: String
    var message: Int
    var cnt: Int
    var list: [WACityList5Days3HoursList]
    var city: WACityList5Days3HoursCity
}

struct WACityList5Days3HoursList: Decodable {
    
    var dt: Int
    var main: WACityList5Days3HoursListMain
    var weather: [WACityList5Days3HoursListWeather]
    var clouds: WACityList5Days3HoursListClouds
    var wind: WACityList5Days3HoursListWind
    var visibility: Int
    var pop: Double
    var sys: WACityList5Days3HoursListSys
    var dt_txt: String
}

struct WACityList5Days3HoursListMain: Decodable {
    
    var temp: Double
    var feelsLike: Double
    var tempMin: Double
    var tempMax: Double
    var pressure: Int
    var humidity: Int
    var seaLevel: Int
    var groundLevel: Int
    var temp_kf: Double
    
    private enum CodingKeys: String, CodingKey {
        case temp = "temp"
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure = "pressure"
        case humidity = "humidity"
        case seaLevel = "sea_level"
        case groundLevel = "grnd_level"
        case temp_kf = "temp_kf"
    }
}

struct WACityList5Days3HoursListWeather: Decodable {
    
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct WACityList5Days3HoursListClouds: Decodable {
    
    var all: Int
}

struct WACityList5Days3HoursListWind: Decodable {
    
    var speed: Double
    var deg: Int
}

struct WACityList5Days3HoursListSys: Decodable {
    
    var pod: String
}

struct WACityList5Days3HoursCity: Decodable {
    
    var id: Int
    var name: String
    var coord: WACityList5Days3HoursCityCoord
    var country: String
    var timezone: Int
    var sunrise: Int
    var sunset: Int
}

struct WACityList5Days3HoursCityCoord: Decodable {
    
    var lat: Double
    var lon: Double
}
