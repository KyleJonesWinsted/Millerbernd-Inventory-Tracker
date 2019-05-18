//
//  ManageTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/3/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit
import MessageUI

class ManageTableViewController: UITableViewController,MFMailComposeViewControllerDelegate {
    
    //MARK: Properties
    
    var modifySKU: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            showReportIssueView(indexPath)
        }
        if indexPath == IndexPath(row: 1, section: 0) {
            showSKUEntryAlert()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func showSKUEntryAlert() {
        let alert = UIAlertController(title: "Enter SKU Number", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "1234"
            textField.keyboardType = .numberPad
        }
        let modify = UIAlertAction(title: "Modify", style: .default) { (_) in
            let SKU = Int(alert.textFields![0].text!)
            guard self.validateSKUNumber(SKU) else {
                let invalidAlert = UIAlertController(title: "Invalid SKU", message: "Please enter an existing SKU number.", preferredStyle: .alert)
                invalidAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.showSKUEntryAlert()
                }))
                self.present(invalidAlert, animated: true, completion: nil)
                return
            }
            self.modifySKU = SKU
            self.performSegue(withIdentifier: PropertyKeys.modifyItemSegue, sender: nil)
        }
        alert.addAction(modify)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func validateSKUNumber(_ sku: Int?) -> Bool {
        guard let sku = sku,
            let _ = ItemController.shared.items(withSKU: sku)
            else {return false}
        return true
    }
    
    //MARK: Report Issue
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    func showReportIssueView(_ indexPath: IndexPath) {
        guard MFMailComposeViewController.canSendMail() else { return }
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["KyleJonesWinsted@gmail.com"])
        switch indexPath.row {
        case 0:
            mailComposeVC.setSubject("Issue: Inventory Discrepency")
            mailComposeVC.setMessageBody("Please enter the following information along with any additional details below.\n\nEmployee number: \nItem SKU: \nCurrent Quantity: \nCorrect Quantity: \n Additional Details: ", isHTML: false)
        case 1:
            mailComposeVC.setSubject("Issue: Item Inaccuracy")
            mailComposeVC.setMessageBody("Please enter the following information along with any additional details below.\n\nEmployee number: \nItem SKU: \nCurrent Item Description: \nCorrect Description: \nAdditional Details: ", isHTML: false)
        case 2:
            mailComposeVC.setSubject("Issue: App Bug Report")
            mailComposeVC.setMessageBody("Please enter the following information along with any additional details below.\n\nEmployee number: \nAttempted action that caused the issue: \nSteps taken to resolve the issue: \nAdditional details: ", isHTML: false)
        default:
            fatalError("No option to report issue for this row")
        }
        present(mailComposeVC, animated: true, completion: nil)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.modifyItemSegue {
            let navController = segue.destination as! UINavigationController
            let addItemController = navController.topViewController as! AddNewItemTableViewController
            addItemController.SKU = modifySKU
            addItemController.isModifyingItem = true
        }
        if segue.identifier == PropertyKeys.addNewItemSegue {
            let navController = segue.destination as! UINavigationController
            let addItemController = navController.topViewController as! AddNewItemTableViewController
            addItemController.isModifyingItem = false
        }
    }
    

}
