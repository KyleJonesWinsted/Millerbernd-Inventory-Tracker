//
//  ReportsTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/3/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class ReportsTableViewController: UITableViewController, UISplitViewControllerDelegate {
    
    //MARK: Properties
    
    let adjustmentTypes = ["Employee", "Date", "SKU", "Reason Code"]
    var items = [Item]()
    var lowStockItems = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        splitViewController?.delegate = self
        self.clearsSelectionOnViewWillAppear = true
        
        updateUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: ItemController.itemsUpdatedNotification, object: nil)
        
    }
    
    //MARK: Methods
    
    func determineLowStockItems() {
        lowStockItems.removeAll()
        for item in items {
            if item.isBelowMinimumStock {
                lowStockItems.append(item)
            }
        }
    }
    
    @objc func updateUI() {
        items = ItemController.shared.allItems()
        determineLowStockItems()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    // MARK: Cell Configuration
    
    func configureAdjustment(_ cell: UITableViewCell, atIndexPath: IndexPath) {
        cell.textLabel?.text = adjustmentTypes[atIndexPath.row]
    }
    
    func configureLowStock(_ cell: LowStockTableViewCell, atIndexPath: IndexPath) {
        cell.itemLabel?.text = lowStockItems[atIndexPath.row].details
        let quantityBelowMinimum = (lowStockItems[atIndexPath.row].totalQuantity - lowStockItems[atIndexPath.row].category.minimumStockLevel!) * -1
        cell.quantityLabel?.text = "\(quantityBelowMinimum)"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Adjustments By:"
        default:
            return "Low Stock Items"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 55.0
        } else {
            return 50.0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return adjustmentTypes.count
        default:
            return lowStockItems.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let adjustmentsCell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.adjustmentsTableCell, for: indexPath)
            configureAdjustment(adjustmentsCell, atIndexPath: indexPath)
            return adjustmentsCell
        default:
            let lowStockCell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.lowStockTableCell, for: indexPath) as! LowStockTableViewCell
            configureLowStock(lowStockCell, atIndexPath: indexPath)
            return lowStockCell
        }

        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.lowStockItemDetailSegue {
            let navController = segue.destination as! UINavigationController
            let itemDetailController = navController.topViewController as! ItemDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            itemDetailController.item = lowStockItems[indexPath.row]
        }
        if segue.identifier == PropertyKeys.intermediateAdjustmentSegue {
            let adjustmentTypeController = segue.destination as! AdjustmentTypeTableViewController
            let indexPath = tableView.indexPathForSelectedRow!
            adjustmentTypeController.browseType = adjustmentTypes[indexPath.row]
        }
    }
}
