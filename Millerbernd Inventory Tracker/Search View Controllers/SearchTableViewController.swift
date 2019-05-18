//
//  SearchTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/28/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, ResultsTableDelegate, UISearchBarDelegate {
    
    //MARK: Properties
    
    var recentSearches = [String]()
    var selectedItem: Item?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadRecentSearch()
        setupSearchBar()
    }
    
    //MARK: Methods
    
    func setupSearchBar() {
        let resultsController = ResultsTableViewController()
        resultsController.delegate = self
        let searchController = UISearchController(searchResultsController: resultsController)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.millerberndBlue], for: .normal)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = resultsController
        searchController.searchBar.placeholder = "Search Part, Manufacturer, or SKU"
        searchController.searchBar.delegate = self
        definesPresentationContext = true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationItem.searchController?.searchBar.text = recentSearches[indexPath.row]
        navigationItem.searchController?.searchBar.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            recentSearches.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    //MARK: Delegate methods
    
    func didSelectResult(_ item: Item) {
        self.selectedItem = item
        performSegue(withIdentifier: PropertyKeys.searchDetailsSegue, sender: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text,
            !searchText.isEmpty,
            !recentSearches.contains(searchText) {
            recentSearches.insert(searchText, at: 0)
            if recentSearches.count > 5 {
                recentSearches.removeLast()
            }
            saveRecentSearch()
        }
        tableView.reloadData()
    }
    
    //MARK: Data persistance
    
    func saveRecentSearch() {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentDirectory.appendingPathComponent("searches").appendingPathExtension("json")
        if let data = try? JSONEncoder().encode(recentSearches) {
            try? data.write(to: archiveURL)
        }
    }
    
    func loadRecentSearch() {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentDirectory.appendingPathComponent("searches").appendingPathExtension("json")
        if let data = try? Data(contentsOf: archiveURL) {
            recentSearches = (try? JSONDecoder().decode([String].self, from: data)) ?? []
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentSearches.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Searches"
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.recentSearchCell, for: indexPath)

        cell.textLabel?.text = recentSearches[indexPath.row]
        
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let itemDetailController = segue.destination as! ItemDetailViewController
        itemDetailController.item = selectedItem!
    }
    

}
