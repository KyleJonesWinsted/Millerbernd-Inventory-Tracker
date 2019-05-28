//
//  ItemListTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/7/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class ItemListTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var filterItem: String!
    var browseType: String!
    var items = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = filterItem
        tableView.separatorStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateItemQuantities), name: ItemController.itemsUpdatedNotification, object: nil)
        
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
    }
    
    //MARK: Methods
    
    func updateUI() {
        switch browseType {
        case "Categories":
            items = ItemController.shared.items(inCategory: filterItem)?.sorted(by: { (item1, item2) -> Bool in
                return item1.details < item2.details
            }) ?? []
        case "Locations":
            items = ItemController.shared.items(atLocation: filterItem) ?? []
        case "Manufacturers":
            items = ItemController.shared.items(fromManufacturer: filterItem)?.sorted(by: { (item1, item2) -> Bool in
                return item1.details < item2.details
            }) ?? []
        case "All Items":
            items = ItemController.shared.allItems()
        default:
            return
        }
    }
    
    @objc func updateItemQuantities() {
        let selectedRow = tableView.indexPathForSelectedRow
        let currentItemCount = items.count
        for (index, item) in items.enumerated() {
            if index < items.count {
                items.remove(at: index)
                if let replacementItem = ItemController.shared.items(withSKU: item.SKU) {
                    items.insert(replacementItem, at: index)
                }
            }
            
        }
        updateUI()
        tableView.reloadData()
        if items.count == currentItemCount {
            tableView.cellForRow(at: selectedRow!)?.setSelected(true, animated: true)
        }
        
    }
    
    //MARK: Cell Configuration
    
    func configure(_ cell: ItemTableCell, atIndexPath: IndexPath) {
        let item = items[atIndexPath.row]
        cell.item = item
    }
    
    func configureSummary(_ cell: UITableViewCell, atIndexPath: IndexPath) {
        let itemTotal = items.count
        var quantityTotal = Int()
        items.forEach { (item) in
            quantityTotal += item.totalQuantity
        }
        cell.textLabel?.text = "\(itemTotal) \(itemTotal > 1 ? "Items" : "Item"), \(quantityTotal) Total Quantity"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return items.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90.0
        } else {
            return 44.0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.itemListTableCell, for: indexPath) as! ItemTableCell
            configure(cell, atIndexPath: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.itemListSummaryCell, for: indexPath)
            configureSummary(cell, atIndexPath: indexPath)
            return cell
        }

    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 44.0
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let itemDetailController = navController.topViewController as! ItemDetailTableViewController
        let indexPath = tableView.indexPathForSelectedRow!
        itemDetailController.item = items[indexPath.row]
    }
    

}
