//
//  IntermediateTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/7/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class IntermediateTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var browseType: String!
    var browseItems = [String]()
    var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = browseType
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: ItemController.itemsUpdatedNotification, object: nil)

        updateUI()
    }
    
    //MARK: Methods
    
    @objc func updateUI() {
        browseItems.removeAll()
        switch browseType {
        case "Categories":
            categories = ItemController.shared.categories
            for item in categories {
                browseItems.append(item.name)
            }
        case "Locations":
            browseItems = ItemController.shared.locations
        case "Manufacturers":
            browseItems = ItemController.shared.manufacturers
        default:
            return
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: Cell Configuration
    
    func configure(_ cell: UITableViewCell, atIndexPath: IndexPath) {
        cell.textLabel?.text = browseItems[atIndexPath.row]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return browseItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.intermediateTableCell, for: indexPath)

        configure(cell, atIndexPath: indexPath)

        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let itemListController = segue.destination as! ItemListTableViewController
        let indexPath = tableView.indexPathForSelectedRow!
        itemListController.browseType = browseType
        itemListController.filterItem = browseItems[indexPath.row]
    }
    

}
