//
//  ResultsTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/28/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

protocol ResultsTableDelegate {
    func didSelectResult(_ item: Item)
}

class ResultsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    //MARK: Properties
    
    var items = ItemController.shared.allItems()
    var filteredItems = [Item]()
    var delegate: SearchTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(ResultsTableViewCell.self, forCellReuseIdentifier: PropertyKeys.resultsTableCell)
        
        updateItems()
        NotificationCenter.default.addObserver(self, selector: #selector(updateItems), name: ItemController.itemsUpdatedNotification, object: nil)

        
    }
    
    //MARK: Methods
    
    @objc func updateItems() {
        items.removeAll()
        items = ItemController.shared.allItems()
        filteredItems.removeAll()
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContentForSearchText(searchText)
        }
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredItems = items.filter({( item : Item) -> Bool in
            return item.details.lowercased().contains(searchText.lowercased()) || item.manufacturer.lowercased().contains(searchText.lowercased()) || item.SKU.description.contains(searchText)
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectResult(filteredItems[indexPath.row])
    }
    
    //MARK: Cell configuration
    
    func configure(_ cell: ResultsTableViewCell, atIndexPath: IndexPath) {
        let item = filteredItems[atIndexPath.row]
        cell.textLabel?.text = "\(item.manufacturer) \(item.details)"
        cell.detailTextLabel?.text = "\(item.SKU) - \(item.category.name)"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.resultsTableCell, for: indexPath) as! ResultsTableViewCell

        configure(cell, atIndexPath: indexPath)

        return cell
    }
    
    // MARK: - Navigation

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let itemDetailController = segue.destination as! ItemDetailViewController
//        let indexPath = tableView.indexPathForSelectedRow!
//        itemDetailController.item = filteredItems[indexPath.row]
//    }


}
