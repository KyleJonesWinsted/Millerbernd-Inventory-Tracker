//
//  AdjustmentDetailsTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/27/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class AdjustmentDetailsTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var adjustment: Adjustment! = Adjustment(employee: "", reason: "", dateAndTime: Date(), item: Item(manufacturer: "", details: "", SKU: 0, category: Category(id: 0, name: "", minimumStockLevel: nil), locations: [], stockAtLocation: []), amountsChanged: [], locations: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //MARK: Methods
    
    
    
    //MARK: Cell configuration
    
    func configure(_ cell: UITableViewCell, atIndexPath: IndexPath) {
        switch atIndexPath.section {
        case 0:
            switch atIndexPath.row {
            case 0:
                cell.textLabel?.text = "Manufacturer:"
                cell.detailTextLabel?.text = adjustment.item.manufacturer
            case 1:
                cell.textLabel?.text = "Description:"
                cell.detailTextLabel?.text = adjustment.item.details
            default:
                cell.textLabel?.text = "SKU:"
                cell.detailTextLabel?.text = adjustment.item.SKU.description
            }
        case 1:
            switch atIndexPath.row {
            case 0:
                cell.textLabel?.text = "Employee:"
                cell.detailTextLabel?.text = adjustment.employee
            case 1:
                cell.textLabel?.text = "Reason Code:"
                cell.detailTextLabel?.text = adjustment.reason
            default:
                cell.textLabel?.text = "Date and Time:"
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .medium
                cell.detailTextLabel?.text = dateFormatter.string(from: adjustment.dateAndTime)
            }
        case 2:
            cell.textLabel?.text = adjustment.locations[atIndexPath.row]
            let change = adjustment.amountsChanged[atIndexPath.row]
            cell.detailTextLabel?.text = "\(change > 0 ? "+" : "")\(change)"
            cell.detailTextLabel?.font = .boldSystemFont(ofSize: 17.0)
            switch change {
            case ..<0:
                cell.detailTextLabel?.textColor = .red
            case 0:
                cell.detailTextLabel?.textColor = .darkText
            default:
                cell.detailTextLabel?.textColor = .millerberndGreen
            }
            
        default:
            cell.textLabel?.text = adjustment.item.locations[atIndexPath.row]
            cell.detailTextLabel?.text = adjustment.item.stockAtLocation[atIndexPath.row].description
            cell.detailTextLabel?.font = .boldSystemFont(ofSize: 17.0)
            
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if adjustment.item.SKU == 0 {
            return 0
        } else {
            return 4
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0,1:
            return 3
        case 2:
            return adjustment.amountsChanged.count
        default:
            return adjustment.item.locations.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Item Details"
        case 1:
            return "Adjustment Details"
        case 2:
            return "Amounts Changed"
        default:
            return "Quantities after Change"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.adjustmentDetailsCell, for: indexPath)

        configure(cell, atIndexPath: indexPath)

        return cell
    }
    
}
