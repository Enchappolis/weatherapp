//
//  MainViewController.swift
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

class MainViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var tableView5Days3Hours: UITableView!
    
    
    // MARK: - Private Variables
    private struct StoryBoards {
        
        static let cityListViewController = "CityListViewController"
        static let settingsViewController = "SettingsViewController"
    }
    
    // Hide all views on app start.
    private var hideView: UIView!
    
    private var cityId = ""
    
    // Need state and country because it is not returned by api for current weather.
    private var state = ""
    private var country = ""
    
    private lazy var cityWeatherCoreDataHandler: CDCityWeatherCoreDataHandler = {
        
        let cityWeatherCoreDataHandler = CDCityWeatherCoreDataHandler()
        return cityWeatherCoreDataHandler
    }()
    
    private var cityCurrentWeatherViewModel: CityCurrentWeatherViewModel!
    private var city5Days3HoursListViewModel: City5Days3HoursListViewModel!
    
    // MARK: - Actions
    @IBAction func settingaBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: StoryBoards.settingsViewController, sender: nil)
    }
    
    @IBAction func citySearchBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: StoryBoards.cityListViewController, sender: nil)
    }
    
    // MARK: - Private Methods
    private func handleWeather5Days3Hours(result: Result<WACity5Days3Hours, WANetworkError.NetworkError>) {
        
        Hub.hide(from: self.view)
        self.showAllViews()
        
        switch result {
        case .success(let waCity5Days3Hours):
            
            self.city5Days3HoursListViewModel = City5Days3HoursListViewModel(waCity5Days3Hours: waCity5Days3Hours)
            
            self.tableView5Days3Hours.reloadData()
        case .failure(let networkError):
            
            self.showAlertOK(title: "Error", message: networkError.localizedDescription)
        }
    }
    
    private func handleRequestIcon(result: Result<UIImage, WANetworkError.NetworkError>) {
        
        switch result {
        case .success(let image):
            
            self.weatherIconImageView.image = image
            
            _ = WAClient.requestWeather5Days3Hours(forCityID: self.cityId, completion: handleWeather5Days3Hours(result:))
            
        case .failure(let networkError):
         
            Hub.hide(from: self.view)
            self.showAlertOK(title: "Error", message: networkError.localizedDescription)
        }
    }
    
    private func handleGetWeatherData(result: Result<WACityCurrentWeather, WANetworkError.NetworkError>) {
        
        switch result {
        case .success(let waCityCurrentWeather):
            
            self.cityCurrentWeatherViewModel = CityCurrentWeatherViewModel(waCityCurrentWeather: waCityCurrentWeather)
            
            let nameStateCountry = cityCurrentWeatherViewModel.nameStateCountry(
                forState: self.state, andCountry: self.country, withfontSize: 45)
            
            self.cityLabel.attributedText = nameStateCountry
            self.weatherDescriptionLabel.text = cityCurrentWeatherViewModel.weatherDescription
            self.temperatureLabel.text = cityCurrentWeatherViewModel.temperature
            
            _ = WAClient.requestIcon(forIconID: cityCurrentWeatherViewModel.icon, completion: handleRequestIcon(result:))
            
        case .failure(_):

            Hub.hide(from: self.view)

            // If there are no cities, don't show error.
        }
    }
    
    private func getWeatherData(completion: @escaping (Result<WACityCurrentWeather, WANetworkError.NetworkError>) -> ()) {
        
        cityWeatherCoreDataHandler.fetchSelectedCityWeater { (cdCityWeather) in
            
            guard let cdCityWeather = cdCityWeather else {
                completion(.failure(.noDataError("Error fetching CityWeather.")))
                return
            }
            
            self.cityId = String(cdCityWeather.id)
            self.state = cdCityWeather.state ?? ""
            self.country = cdCityWeather.country ?? ""
            
            _ = WAClient.requestCurrentWeather(forCityID: self.cityId) { (result) in
                
                completion(result)
            }
        }
    }
    
    private func hideAllViews() {
       
        hideView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.bounds.width,
                                        height: self.view.bounds.height))
        hideView.tag = 201
        hideView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
 
        self.view.addSubview(hideView)
    }
    
    private func showAllViews() {
        
        if let view = self.view.viewWithTag(201) {
            view.removeFromSuperview()
            hideView.removeFromSuperview()
        }
    }
    
    // MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView5Days3Hours.dataSource = self
        tableView5Days3Hours.delegate = self
        tableView5Days3Hours.rowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showAllViews()
        hideAllViews()
        Hub.show(onTopOf: self.view)
        
        self.getWeatherData(completion: self.handleGetWeatherData(result:))
    }
    
    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.city5Days3HoursListViewModel != nil ? self.city5Days3HoursListViewModel.numberOfSections : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.city5Days3HoursListViewModel != nil ? self.city5Days3HoursListViewModel.numberOfRowsInSection : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cityWeather5Days3HoursTableViewCell = tableView.dequeueReusableCell(withIdentifier: CityWeather5Days3HoursTableViewCell.tableViewCellName) as? CityWeather5Days3HoursTableViewCell {
            
            cityWeather5Days3HoursTableViewCell.city5Days3HoursAllHoursForOneDayViewModelList = self.city5Days3HoursListViewModel.cellForRowAtIndexPath(indexPath: indexPath)
            
            return cityWeather5Days3HoursTableViewCell
        }
        
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.city5Days3HoursListViewModel != nil
            ? self.city5Days3HoursListViewModel.titleForHeaderInSection(section: section)
            : ""
    }
}
