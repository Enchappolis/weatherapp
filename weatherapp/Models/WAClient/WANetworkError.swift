//
//  WANetworkError.swift
//  weatherapp
//
//  Created by Enchappolis on 7/28/20.
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

struct WANetworkError {
    
    enum NetworkError: Error {
        case decodingError(String)
        case noDataError(String)
        case domainError(String)
        case httpResponseNot200(String)
        case urlError
        
        var errorMessage: String {
            
            switch self {
            case .decodingError(let errorMessage):
                return "Decoding error: \(errorMessage)"
            case .domainError(let errorMessage):
                return "Domain error: \(errorMessage)"
            case .noDataError(let errorMessage):
                return "No Data error: \(errorMessage)"
            case .httpResponseNot200(let errorMessage):
                return "StatusCode Error: \(errorMessage)"
            case .urlError:
                return "There was an error with the url."
            }
        }
    }
}
