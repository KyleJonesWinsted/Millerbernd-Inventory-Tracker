//
//  BrowseTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/3/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class BrowseTableViewController: UITableViewController, UISplitViewControllerDelegate {
    
    //MARK: Properties
    
    let browseTypes: [String] = ["Categories", "Locations", "Manufacturers"]
    var recentItems = [Item]() {
        didSet {
            let newValue = recentItems.count
            if oldValue.count != newValue {
                 self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self
        updateItemQuantities()
        self.clearsSelectionOnViewWillAppear = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: ItemController.itemsUpdatedNotification, object: nil)
    
    }
    
    //MARK: Methods
    
    @objc func updateUI() {
        DispatchQueue.main.async {
            self.updateItemQuantities()
            if !(self.isViewLoaded && self.view?.window != nil) {
                self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 2))
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    func updateItemQuantities() {
        recentItems = ItemController.shared.recentItems
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            return "Recently Viewed"
        } else {
            return nil
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 1
        default:
            return recentItems.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let browseCell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.browseTableCell, for: indexPath)
        let skusCell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.skusTableCell, for: indexPath)
        let recentCell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.recentItemBrowseCell, for: indexPath)
        if indexPath.section == 0 {
            browseCell.textLabel?.text = browseTypes[indexPath.row]
            return browseCell
        } else if indexPath.section == 1 {
            browseCell.textLabel?.text = "SKUs"
            return skusCell
        } else {
            let item = recentItems[indexPath.row]
            recentCell.textLabel?.text = "\(item.manufacturer) \(item.details)"
            recentCell.detailTextLabel?.text = "\(item.SKU) - \(item.category.name)"
            return recentCell
        }
    
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = tableView.indexPathForSelectedRow!
        if segue.identifier == PropertyKeys.intermediateTableSegue {
            let intermediateTable = segue.destination as! IntermediateTableViewController
            intermediateTable.browseType = browseTypes[index.row]
            
        } else if segue.identifier == PropertyKeys.skusListSegue {
            let itemListTable = segue.destination as! ItemListTableViewController
            itemListTable.filterItem = "All Items"
            itemListTable.browseType = "All Items"
            
        } else if segue.identifier == PropertyKeys.recentItemDetailsSegue {
            let navController = segue.destination as! UINavigationController
            let itemDetails = navController.topViewController as! ItemDetailViewController
            itemDetails.item = recentItems[index.row]
            
        }
    }
    

}
