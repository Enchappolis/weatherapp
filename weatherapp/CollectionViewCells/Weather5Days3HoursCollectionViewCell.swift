//
//  Weather5Days3HoursCollectionViewCell.swift
//  weatherapp
//
//  Created by Enchappolis on 8/6/20.
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

class Weather5Days3HoursCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionViewCellContentView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!

    static let collectionViewCellName = "Weather5Days3HoursCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        timeLabel.textColor = ColorTheme.weather5Days3HoursCollectionViewCellLabelColor
        temperatureLabel.textColor = ColorTheme.weather5Days3HoursCollectionViewCellLabelColor
    }
    
    func configure(city5Days3HoursAllHoursForOneDayViewModel: City5Days3HoursOneHourForOneDayViewModel) {
        
        timeLabel.text = city5Days3HoursAllHoursForOneDayViewModel.time
        temperatureLabel.text = TemperatureConverterViewModel.temperature(kelvin: city5Days3HoursAllHoursForOneDayViewModel.temperature)
        
        collectionViewCellContentView.backgroundColor = ColorTheme.weather5Days3HoursCollectionViewCellDayColor
        
        // If it's 8PM+ show gray background.
        if city5Days3HoursAllHoursForOneDayViewModel.time.uppercased().contains("PM") {
            
            if let index = city5Days3HoursAllHoursForOneDayViewModel.time.firstIndex(of: ":"),
                let timeNumber = Int(city5Days3HoursAllHoursForOneDayViewModel.time[city5Days3HoursAllHoursForOneDayViewModel.time.startIndex..<index]) {
                
                if timeNumber >= 8 {
                    
                    collectionViewCellContentView.backgroundColor = ColorTheme.weather5Days3HoursCollectionViewCellNightColor
                }
            }
        }
        
        Hub.show(onTopOf: self.contentView)
        self.weatherImageView.image = UIImage()
        
        _ = WAClient.requestIcon(forIconID: city5Days3HoursAllHoursForOneDayViewModel.icon) { [weak self] (result) in
            
            Hub.hide(from: self?.contentView ?? UIView())
            
            guard let self = self else { return }
            
            switch result {
            case .success(let image):
                self.weatherImageView.image = image
            case .failure(_):
                break
            }
        }
    }
}
