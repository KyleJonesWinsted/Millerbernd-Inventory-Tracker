//
//  AdjustmentTypeTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/27/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class AdjustmentTypeTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var browseType: String!
    var browseItems = [String]()
    var dates = [Date]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        title = browseType
        
        updateUI()
    }
    
    //MARK: Methods
    
    func updateUI() {
        browseItems.removeAll()
        switch browseType {
        case "Employee":
            browseItems = AdjustmentController.shared.employees
        case "Date":
            dates = AdjustmentController.shared.dates
            for date in dates {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                let formattedDate = dateFormatter.string(from: date)
                browseItems.append(formattedDate)
            }
        case "SKU":
            let SKUs = AdjustmentController.shared.SKU
            for SKU in SKUs {
                browseItems.append(String(SKU))
            }
        case "Reason Code":
            browseItems = AdjustmentController.shared.reasonCodes
        default:
            return
        }
        tableView.reloadData()
    }
    
    //MARK: Cell configuration
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.intermediateAdjustmentCell, for: indexPath)

        configure(cell, atIndexPath: indexPath)

        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let adjustmentListController = segue.destination as! AdjustmentListTableViewController
        let indexPath = tableView.indexPathForSelectedRow!
        adjustmentListController.browseType = browseType
        adjustmentListController.filterItem = browseItems[indexPath.row]
        if browseType == "Date" {
            adjustmentListController.date = dates[indexPath.row]
        }
    }   

}
