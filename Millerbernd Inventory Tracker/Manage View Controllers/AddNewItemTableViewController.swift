//
//  AddNewItemTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/24/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class AddNewItemTableViewController: UITableViewController, SelectCategoryTableDelegate, UITextFieldDelegate {
    
    //MARK: Properties

    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var manufacturerTextField: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    
    var activityIndicator = UIActivityIndicatorView()
    var isModifyingItem = false
    var SKU: Int?
    var category: Category?
    var locations = [String]()
    var stockAtLocation = [Int]()
    var item: Item? {
        guard let category = category,
        let SKU = SKU,
        let manufacturer = manufacturerTextField.text,
        let details = descriptionTextField.text,
        !manufacturer.isEmpty,
        !details.isEmpty
            else { return nil }
        
        return Item(manufacturer: manufacturer, details: details, SKU: SKU, category: category, locations: locations, stockAtLocation: stockAtLocation)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preloadFields()
        determineSKU()
        setupTextFields()
        updateDeleteButton()
        updateDoneButton()
        if isModifyingItem {
            title = "Modify Item"
        } else {
            title = "Add New Item"
        }
    }
    
    //MARK: Methods
    
    func determineSKU() {
        if !isModifyingItem {
            SKU = Int.random(in: 1000...9999)
            if let _ = ItemController.shared.items(withSKU: SKU!) {
                determineSKU()
            }
        }
        
    }
    
    func preloadFields() {
        guard let SKU = SKU,
            let item = ItemController.shared.items(withSKU: SKU) else { return }
        descriptionTextField.text = item.details
        manufacturerTextField.text = item.manufacturer
        category = item.category
        categoryLabel.text = item.category.name
        locations = item.locations
        stockAtLocation = item.stockAtLocation
        
    }
    
    func updateDoneButton() {
        if let _ = item {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    func updateDeleteButton() {
        if self.locations == [] {
            deleteButton.isEnabled = true
            deleteButton.setTitleColor(.red, for: .normal)
        } else {
            deleteButton.isEnabled = false
            deleteButton.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    func setupTextFields() {
        descriptionTextField.autocapitalizationType = .allCharacters
        manufacturerTextField.autocapitalizationType = .words
        descriptionTextField.autocorrectionType = .no
        manufacturerTextField.autocorrectionType = .no
        descriptionTextField.delegate = self
        manufacturerTextField.delegate = self
    }
    
    //MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 2 {
            if isModifyingItem {
                return "Only items that are out of stock can be permanently deleted."
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0, 1:
            return 44.0
        default:
            if isModifyingItem {
                return 44.0
            } else {
                return 0.0
            }
        }
    }
    
    //MARK: Delegate methods
    
    func didSelect(category: Category) {
        self.category = category
        categoryLabel.text = category.name
        tableView.reloadData()
        updateDoneButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == descriptionTextField {
            manufacturerTextField.becomeFirstResponder()
        } else {
            manufacturerTextField.resignFirstResponder()
        }
        return true
    }

    @IBAction func textFieldChanged(_ sender: Any) {
        updateDoneButton()
    }
    
    //MARK: Network UI
    
    func showNetworkFailureAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "Unable to update items.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            self.stopBarButtonIndicator()
        }))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (_) in
            self.doneButtonPressed(self)
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func startBarButtonIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            self.activityIndicator.color = .gray
            let barButton = UIBarButtonItem(customView: self.activityIndicator)
            self.navigationItem.setRightBarButton(barButton, animated: true)
            self.activityIndicator.startAnimating()
        }
        
    }
    
    func stopBarButtonIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigationItem.setRightBarButton(self.doneButton, animated: true)
        }
    }
    
    //MARK: Completion
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if let item = item {
            startBarButtonIndicator()
            ItemController.shared.putRemoteItems(item: item) { (success) in
                if success {
                    ItemController.shared.addNew(item: item)
                    ItemController.shared.addRecent(item: item)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showNetworkFailureAlert()
                }
            }
            
        } 
        
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Are you sure?", message: "Deleting items cannot be undone. Any prior adjustments will still be viewable.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            if let SKU = self.SKU {
                ItemController.shared.deleteRemoteItem(itemSKU: SKU, completion: { (success) in
                    self.startBarButtonIndicator()
                    if success {
                        ItemController.shared.deleteItem(withSKU: SKU)
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.showNetworkFailureAlert()
                    }
                })
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.selectCategorySegue {
            let selectCategoryController = segue.destination as! SelectCategoryTableViewController
            selectCategoryController.delegate = self
            selectCategoryController.selectedCategory = category
        }
    }
    

}
