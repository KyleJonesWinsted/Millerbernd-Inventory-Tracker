//
//  ItemDetailTableViewController.swift
//  Millerbernd Inventory Tracker
//
//  Created by Kyle Jones on 5/25/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class ItemDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var stockInOutButton: UIBarButtonItem!
    
    var item: Item! = Item(manufacturer: "", details: "", SKU: 0, category: Category(id: 0, name: "", minimumStockLevel: nil), locations: [], stockAtLocation: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        
        if item.SKU != 0 {
            ItemController.shared.addRecent(item: item)
        }
        
        updateUI()
        NotificationCenter.default.addObserver(self, selector: #selector(updateItem), name: ItemController.itemsUpdatedNotification, object: nil)

    }
    
    // MARK: Methods
    
    func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func updateItem() {
        if let replacementItem = ItemController.shared.items(withSKU: item.SKU) {
            self.item = replacementItem
            updateUI()
        } else {
            stockInOutButton.isEnabled = false
        }
    }
    
    // MARK: Cell configuration
    
    func configure(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = item.details
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Manufacturer:"
                cell.detailTextLabel?.text = item.manufacturer
            case 1:
                cell.textLabel?.text = "SKU:"
                cell.detailTextLabel?.text = item.SKU.description
            case 2:
                cell.textLabel?.text = "Category:"
                cell.detailTextLabel?.text = item.category.name
            default:
                cell.textLabel?.text = "Total Quantities:"
                cell.detailTextLabel?.text = item.totalQuantity.description
                cell.detailTextLabel?.textColor = item.isBelowMinimumStock ? .red : .black
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 23.0, weight: .semibold)
            }
        default:
            cell.textLabel?.text = item.locations[indexPath.row]
            cell.detailTextLabel?.text = "Qty: \(item.stockAtLocation[indexPath.row])"
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if item.SKU == 0 {
            return 0
        } else {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            switch item.locations.count {
            case 0:
                return "No Locations"
            case 1:
                return "1 Location"
            default:
                return "\(item.locations.count) Locations"
            }
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let view = UIView()
            let label = UILabel()
            var text: String {
                switch item.locations.count {
                case 0:
                    return ""
                case 1:
                    return "1 Location"
                default:
                    return "\(item.locations.count) Locations"
                }
            }
            label.text = text
            label.font = UIFont.systemFont(ofSize: 20.0, weight: .bold)
            view.addSubview(label)
            label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 7.0, paddingLeft: 25.0, paddingBottom: 7.0, paddingRight: 0.0, width: 0.0, height: 0.0, enableInsets: true)
            return view
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 40.0
        } else {
            return 0.0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 4
        default:
            return item.locations.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.itemDetailCell1, for: indexPath)
            configure(cell, atIndexPath: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.itemDetailCell2, for: indexPath)
            configure(cell, atIndexPath: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.itemDetailCell3, for: indexPath)
            configure(cell, atIndexPath: indexPath)
            return cell
        }
    }
    
    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.stockInOutSegue {
            let navController = segue.destination as! UINavigationController
            let stockInOutController = navController.topViewController as! StockInOutTableViewController
            stockInOutController.item = item
        }
    }

}
