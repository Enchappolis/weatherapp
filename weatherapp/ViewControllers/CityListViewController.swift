//
//  CityListViewController.swift
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

import UIKit
import CoreData

class CityListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var cityListTableView: UITableView!
    
    // MARK: - Private Variables
    private struct StoryBoards {
        
        static let citySearchViewController = "CitySearchViewController"
    }
    
    private lazy var cityWeatherCoreDataHandler: CDCityWeatherCoreDataHandler = {
        
        let cityWeatherCoreDataHandler = CDCityWeatherCoreDataHandler()
        cityWeatherCoreDataHandler.fetchedResultsControllerDelegate = self
        return cityWeatherCoreDataHandler
    }()
    
    // MARK: - Actions
    @IBAction func citySearchBarButtonItemTapped(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: StoryBoards.citySearchViewController, sender: nil)
    }
    
    // MARK: - Private Methods
    @objc private func addTapped() {
        
        performSegue(withIdentifier: StoryBoards.citySearchViewController, sender: nil)
    }
    
    // MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cities"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        cityListTableView.delegate = self
        cityListTableView.dataSource = self
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        extFullScreen(viewController: segue.destination)
        
        if segue.identifier == StoryBoards.citySearchViewController {
            
            if let navigationController = segue.destination as? UINavigationController {
                
                if let citySearchViewController = navigationController.topViewController as? CitySearchViewController {
                    
                    citySearchViewController.delegate = self
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension CityListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cityWeatherCoreDataHandler.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cityListTableViewCell = tableView.dequeueReusableCell(withIdentifier: CityListTableViewCell.tableViewCellName) as? CityListTableViewCell {
            
            if let cityWeather = cityWeatherCoreDataHandler.fetchedResultsController.fetchedObjects?[indexPath.row] {
                
                cityListTableViewCell.configure(cityWeather: cityWeather, delegateForAlert: self)
            }
            
            return cityListTableViewCell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let cityWeather = cityWeatherCoreDataHandler.fetchedResultsController.object(at: indexPath)
            
            do {
                try cityWeatherCoreDataHandler.delete(cityWeather: cityWeather)
            }
            catch {
                
                showAlertOK(title: "Error", message: CDCityWeatherError.deleteError.errorDescription)
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension CityListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cityWeather = cityWeatherCoreDataHandler.fetchedResultsController.fetchedObjects?[indexPath.row] else {

            return
        }

        do {
            try cityWeatherCoreDataHandler.update(cityWeather: cityWeather)
        }
        catch {
            
            showAlertOK(title: "Error", message: CDCityWeatherError.updateError.errorDescription)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - CitySearchViewControllerDelegate
extension CityListViewController: CitySearchViewControllerDelegate {
    
    // We got a new city back. Let's update the tableView.
    // First save the new city to core data then load all cities form core data
    // and get the current weather for all of them.
    func citySearchViewControllerDidSearch(city: WACity) {
        
        // Need to wait until viewcontroller is dismissed before showing alert view.
        dismiss(animated: true) {
            
            [weak self] in
            
            guard let self = self else { return }
            
            do {
                
                try self.cityWeatherCoreDataHandler.insertCityWeather(city: city)
                
                // Get all cities from core data.
                self.cityWeatherCoreDataHandler.resetAndRefetch()
                self.cityListTableView.reloadData()
            }
            catch CDCityWeatherError.creationError {
                
                self.showAlertOK(title: "Error", message: CDCityWeatherError.creationError.errorDescription)
            }
            catch {
                
                self.showAlertOK(title: "Error", message: error.localizedDescription)
            }
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension CityListViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            cityListTableView.insertRows(at: [newIndexPath!], with: .top)
            break
        case .delete:
            cityListTableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            cityListTableView.reloadRows(at: [indexPath!], with: .top)
        case .move:
            cityListTableView.reloadRows(at: [indexPath!], with: .top)
        default:
            fatalError("feature not yet implemented")
        }
    }
}

extension CityListViewController: CityListTableViewCellDelegate {

    func showAlert(title: String, messag: String) {

        showAlertOK(title: title, message: messag)
    }
}
