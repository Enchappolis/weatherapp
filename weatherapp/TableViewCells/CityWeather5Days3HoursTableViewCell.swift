//
//  CityWeather5Days3HoursTableViewCell.swift
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

import UIKit

class CityWeather5Days3HoursTableViewCell: UITableViewCell {

    @IBOutlet weak var weather5Days3HoursCollectionView: Weather5Days3HoursCollectionView!
   
    var city5Days3HoursAllHoursForOneDayViewModelList: City5Days3HoursAllHoursForOneDayViewModel! {
        
        didSet {
            
            weather5Days3HoursCollectionView.setContentOffset(.zero, animated: false)
            weather5Days3HoursCollectionView.reloadData()
        }
    }
    
    // MARK: - Public Variables
    static let tableViewCellName = "CityWeather5Days3HoursTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 180, height: 65)
        flowLayout.minimumLineSpacing = 5.0
        flowLayout.minimumInteritemSpacing = 5.0
        self.weather5Days3HoursCollectionView.collectionViewLayout = flowLayout
        
        weather5Days3HoursCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension CityWeather5Days3HoursTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return city5Days3HoursAllHoursForOneDayViewModelList.list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if let weather5Days3HoursCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: Weather5Days3HoursCollectionViewCell.collectionViewCellName, for: indexPath) as? Weather5Days3HoursCollectionViewCell {
        
            let city5Days3HoursAllHoursForOneDayViewModel = city5Days3HoursAllHoursForOneDayViewModelList.list[indexPath.row]
            
            weather5Days3HoursCollectionViewCell.configure(city5Days3HoursAllHoursForOneDayViewModel: city5Days3HoursAllHoursForOneDayViewModel)
            
            return weather5Days3HoursCollectionViewCell
        }
        
        return UICollectionViewCell()
    }
}
