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
        guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
            let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {return}
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["ifYouSeeThisIForgotToPutARealEmailHere@test.com"])
        mailComposeVC.setSubject(appName + " " + appVersion)
        mailComposeVC.setMessageBody("Feedback:\n\n", isHTML: false)
        var device = [String:String]()
        device["model"] = UIDevice().modelIdentifier()
        device["iOSVersion"] = UIDevice.current.systemVersion
        if let deviceData = try? JSONEncoder().encode(device) {
            mailComposeVC.addAttachmentData(deviceData, mimeType: "text/plain", fileName: "system")
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
