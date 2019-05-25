//
//  ItemDetailViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/7/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit
import MessageUI

class ItemDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var totalQuantityLabel: UILabel!
    @IBOutlet weak var locationsTableView: UITableView!
    @IBOutlet weak var stockInOutButton: UIBarButtonItem!
    
    var item: Item! = Item(manufacturer: "", details: "", SKU: 0, category: Category(id: 0, name: "", minimumStockLevel: nil), locations: [], stockAtLocation: [])
    var emailType: EmailType? = nil
    enum EmailType {
        case quantity, description, category, other
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if item.SKU != 0 {
            ItemController.shared.addRecent(item: item)
        }
        
        updateUI()
        NotificationCenter.default.addObserver(self, selector: #selector(updateItem), name: ItemController.itemsUpdatedNotification, object: nil)
        
    }
    
    //MARK: Methods
    
    func updateUI() {
        DispatchQueue.main.async {
            self.detailsLabel.text = self.item.SKU != 0 ? self.item.details : "Select an Item"
            self.manufacturerLabel.text = self.item.manufacturer
            self.skuLabel.text = self.item.SKU != 0 ? self.item.SKU.description : ""
            self.categoryLabel.text = self.item.category.name
            if self.item.isBelowMinimumStock {
                self.totalQuantityLabel.textColor = .red
                self.totalQuantityLabel.font = .boldSystemFont(ofSize: 25.0)
            }
            self.totalQuantityLabel.text = self.item.SKU != 0 ? self.item.totalQuantity.description : ""
            self.locationsTableView.delegate = self
            self.locationsTableView.dataSource = self
            self.locationsTableView.tableFooterView = UIView()
            if self.locationsTableView.contentSize.height < self.locationsTableView.frame.size.height {
                self.locationsTableView.isScrollEnabled = false
            } else {
                self.locationsTableView.isScrollEnabled = true
            }
            self.locationsTableView.reloadData()
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
    
    //MARK: Report Issue
    
    func showReportIssueView() {
        let alert = UIAlertController(title: "Select the type of issue.", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Incorrect Quantity", style: .default, handler: { (_) in
            print("quantity selected")
            self.emailType = .quantity
            self.presentEmailComposeView()
        }))
        alert.addAction(UIAlertAction(title: "Inaccurate Description", style: .default, handler: { (_) in
            self.emailType = .description
            self.presentEmailComposeView()
        }))
        alert.addAction(UIAlertAction(title: "Incorrect Category", style: .default, handler: { (_) in
            self.emailType = .category
            self.presentEmailComposeView()
        }))
        alert.addAction(UIAlertAction(title: "Other Issue", style: .default, handler: { (_) in
            self.emailType = .other
            self.presentEmailComposeView()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    
    func presentEmailComposeView() {
        if emailType == nil {
            print("nil email type")
            return
        } else {
            if !MFMailComposeViewController.canSendMail() {
                print("Cant send mail")
                return
            }
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["KyleJonesWinsted@gmail.com"])
            switch emailType {
            case .quantity?:
                composeVC.setSubject("Issue: Quantity SKU: \(self.item.SKU)")
                composeVC.setMessageBody("Current total quantity: \(self.item.totalQuantity)\nLocations: \(self.item.locations)\nQuantities: \(self.item.stockAtLocation)\n\nPlease enter the amount you counted and any additional details.\n", isHTML: false)
            case .description?:
                composeVC.setSubject("Issue: Description SKU: \(self.item.SKU)")
                composeVC.setMessageBody("Current description: \(self.item.details)\n\nPlease enter the correct description and any additional details.\n", isHTML: false)
            case .category?:
                composeVC.setSubject("Issue: Category SKU: \(self.item.SKU)")
                composeVC.setMessageBody("Current category: \(self.item.category.name)\n\nPlease enter the correct category and any additional details.\n", isHTML: false)
            case .other?:
                composeVC.setSubject("Issue: Other SKU: \(self.item.SKU)")
                composeVC.setMessageBody("Please describe the issue.\n", isHTML: false)
            case .none:
                return
            }
            print("Presenting email controller")
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func reportButtonPressed(_ sender: Any) {
        if item.SKU == 0 {
            return
        }
        showReportIssueView()
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Table view data source
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch item.locations.count {
        case 0:
            return "No Locations"
        case 1:
            return "1 Location"
        default:
            return "\(item.locations.count) locations"
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return item.locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.locationQuantityCell, for: indexPath)
        cell.textLabel?.text = item.locations[indexPath.row]
        cell.detailTextLabel?.text = "Qty: \(item.stockAtLocation[indexPath.row])"
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.stockInOutSegue {
            let navController = segue.destination as! UINavigationController
            let stockInOutController = navController.topViewController as! StockInOutTableViewController
            stockInOutController.item = item
        }
    }
    

}
