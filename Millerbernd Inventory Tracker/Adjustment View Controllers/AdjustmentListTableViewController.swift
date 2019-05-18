//
//  AdjustmentListTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/27/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class AdjustmentListTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var filterItem: String!
    var date: Date?
    var browseType: String!
    var adjustments = [Adjustment]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = filterItem
        
        updateUI()
    }
    
    //MARK: Methods
    
    func updateUI() {
        switch browseType {
        case "Employee":
            adjustments = AdjustmentController.shared.adjustments(fromEmployee: filterItem) ?? []
        case "Date":
            adjustments = AdjustmentController.shared.adjustments(onDate: date!) ?? []
        case "SKU":
            adjustments = AdjustmentController.shared.adjustments(withSKU: Int(filterItem)!) ?? []
        case "Reason Code":
            adjustments = AdjustmentController.shared.adjustments(forReasonCode: filterItem) ?? []
        default:
            return
        }
    }
    
    //MARK: Cell configuration
    
    func configure(_ cell: AdjustmentListTableViewCell, atIndexPath: IndexPath) {
        let adjustment = adjustments[atIndexPath.row]
        cell.descriptionLabel?.text = adjustment.item.details
        cell.quantityTextLabel?.text = "\(adjustment.totalChange > 0 ? "+" : "")\(adjustment.totalChange)"
        if adjustment.totalChange > 0 {
            cell.quantityTextLabel?.textColor = .millerberndGreen
        } else if adjustment.totalChange < 0 {
            cell.quantityTextLabel?.textColor = .red
        } else {
            cell.quantityTextLabel?.textColor = .black
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        cell.dateTextLabel?.text = dateFormatter.string(from: adjustment.dateAndTime)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adjustments.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.adjustmentListCell, for: indexPath) as! AdjustmentListTableViewCell

        configure(cell, atIndexPath: indexPath)

        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navController = segue.destination as! UINavigationController
        let adjustmentDetailController = navController.topViewController as! AdjustmentDetailsTableViewController
        let indexPath = tableView.indexPathForSelectedRow!
        adjustmentDetailController.adjustment = adjustments[indexPath.row]
    }
    

}
