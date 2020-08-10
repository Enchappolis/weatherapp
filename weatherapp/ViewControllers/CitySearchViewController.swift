//
//  CitySearchViewController.swift
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

protocol CitySearchViewControllerDelegate: AnyObject {
    
    // State is not returned by API => We need WACity so that we have the state.
    func citySearchViewControllerDidSearch(city: WACity)
}

class CitySearchViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var citySearchTableView: UITableView!
    
    // MARK: - Private Variables
    private var cityListFiltered = [WACity]()
    private let searchController = UISearchController()
    
    // MARK: - Public Variables
    weak var delegate: CitySearchViewControllerDelegate?
    
    // MARK: - Private Methods
    private func setupSearchController() {
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "City"
        self.searchController.searchBar.returnKeyType = .default
        self.searchController.searchBar.autocorrectionType = .no
        self.searchController.definesPresentationContext = true
        
        // For didPresentSearchController() of UISearchControllerDelegate.
        self.searchController.delegate = self
        
        self.searchController.searchBar.delegate = self
    }
    
    private func reloadTableView(searchText: String = "") {
        
        // x in searchbar tapped.
        if searchText.isEmpty {
            
            self.cityListFiltered = []
        }
        else {
            
            self.cityListFiltered = WACityListComplete.data.filter {
                $0.name.starts(with: searchText)
            }
        }
        
        self.citySearchTableView.reloadData()
    }
    
    private func searchControllerBecomeFirstResponder() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: - View Load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citySearchTableView.delegate = self
        citySearchTableView.dataSource = self
        citySearchTableView.keyboardDismissMode = .onDrag
        
        setupSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchController.isActive = true
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: - UITableViewDataSource
extension CitySearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cityListFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let citySearchTableViewCell = tableView.dequeueReusableCell(withIdentifier: CitySearchTableViewCell.tableViewCellName) as? CitySearchTableViewCell {
            
            let city = cityListFiltered[indexPath.row]
            
            citySearchTableViewCell.configure(city: city)
            
            return citySearchTableViewCell
        }
        
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension CitySearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate?.citySearchViewControllerDidSearch(city: cityListFiltered[indexPath.row])
    }
}

// MARK: - UISearchBarDelegate
extension CitySearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        reloadTableView(searchText: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.searchController.searchBar.endEditing(true)
    }
}

// MARK: - UISearchControllerDelegate
extension CitySearchViewController: UISearchControllerDelegate {
    
    // Needs isActive = true in viewDidAppear().
    func didPresentSearchController(_ searchController: UISearchController) {
        
        self.searchControllerBecomeFirstResponder()
    }
}
