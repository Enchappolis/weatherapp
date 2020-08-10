//
//  City5Days3HoursViewModel.swift
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

import Foundation

struct City5Days3HoursListViewModel {
    
    // MARK: - Private Variables
    private var city5Days3HoursAllHoursForOneDayListViewModel = [City5Days3HoursAllHoursForOneDayViewModel]()
    
    // MARK: - Init
    init(waCity5Days3Hours: WACity5Days3Hours) {
        
        self.assignAllHoursForOneDayToListViewModel(waCity5Days3Hours: waCity5Days3Hours)
    }
    
    // MARK: - Public Properties
    var numberOfSections: Int {
        return city5Days3HoursAllHoursForOneDayListViewModel.count
    }
    
    var numberOfRowsInSection: Int {
        return 1
    }
    
    func cellForRowAtIndexPath(indexPath: IndexPath) -> City5Days3HoursAllHoursForOneDayViewModel {
        return self.city5Days3HoursAllHoursForOneDayListViewModel[indexPath.section]
    }
    
    func titleForHeaderInSection(section: Int) -> String {
        return self.city5Days3HoursAllHoursForOneDayListViewModel[section].dayName
    }
    
    // MARK: - Private Methods
    private func dateOnly(date: Int) -> String {
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        let stringDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(date)))
        
        return stringDate
    }
    
    private func time(date: Int) -> String {
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let stringDate = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(date)))
        
        return stringDate
    }
    
    private func dayName(date: Int) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return "\(dateOnly(date: date)) - \(dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(date))))"
    }
    
    // All dates in all sections.
    mutating private func assignAllHoursForOneDayToListViewModel(waCity5Days3Hours: WACity5Days3Hours) {
        
        // List of all hours for one day.
        var cityListOneSection = [City5Days3HoursOneHourForOneDayViewModel]()
        
        var cityDate = ""
        var cityDayName = ""
        var loopCount = 1
        
        // Loop throug all dates and times received by api.
        for city5Days3Hours in waCity5Days3Hours.list {
            
            let city5Days3HoursOneHourForOneDayViewModel = City5Days3HoursOneHourForOneDayViewModel(
                date: dateOnly(date: city5Days3Hours.dt),
                time: time(date: city5Days3Hours.dt),
                dayName: dayName(date: city5Days3Hours.dt),
                temperature: city5Days3Hours.main.temp,
                weatherDescription: city5Days3Hours.weather[0].description,
                icon: city5Days3Hours.weather[0].icon)
            
            cityDate = dateOnly(date: city5Days3Hours.dt)
            cityDayName = dayName(date: city5Days3Hours.dt)
            
            // The first date always goes to cityListOneSection.
            if loopCount == 1 {
                
                cityListOneSection.append(city5Days3HoursOneHourForOneDayViewModel)
                loopCount += 1
                continue
            }
            
            // cityListOneSection has all hours for one section.
            // If the current date already exists in cityListOneSection, then the date belongs to the same section. Add it to cityListOneSection.
            if cityListOneSection.contains(where: { $0.date == dateOnly(date: city5Days3Hours.dt) }) {
                
                cityListOneSection.append(city5Days3HoursOneHourForOneDayViewModel)
            }
            else {
                
                // The current date is different the dates in cityListOneSection.
                // Save all dates in cityListOneSection to WACity5Days3HoursForDisplayOneDayHoursList
                // and start a new cityListOneSection for the new date.
                
                // Just pick the first. They are all the same in cityListOneSection.
                cityDate = cityListOneSection[0].date
                cityDayName = cityListOneSection[0].dayName
                
                let city5Days3HoursAllHoursForOneDayViewModel = City5Days3HoursAllHoursForOneDayViewModel(
                    date: cityDate,
                    dayName: cityDayName,
                    list: cityListOneSection)
                
                // Append all the hours of one day.
                self.city5Days3HoursAllHoursForOneDayListViewModel.append(city5Days3HoursAllHoursForOneDayViewModel)
                
                // Empty cityListOneSection before starting to add the next dates.
                cityListOneSection = []
                
                cityListOneSection.append(city5Days3HoursOneHourForOneDayViewModel)
            }
        }
        
        let city5Days3HoursAllHoursForOneDayViewModel = City5Days3HoursAllHoursForOneDayViewModel(
            date: cityDate,
            dayName: cityDayName,
            list: cityListOneSection)
        self.city5Days3HoursAllHoursForOneDayListViewModel.append(city5Days3HoursAllHoursForOneDayViewModel)
    }
}
