//
//  EditCategoryTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/22/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class EditCategoryTableViewController: UITableViewController, EditCategoryCellDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    var categories = [Category]() {
        didSet {
            updateDoneButton()
        }
    }
    var categoryImages = [Int:UIImage]()
    var activityIndicator = UIActivityIndicatorView()
    var lastSelectedIndex = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        categories = CategoryController.shared.categories
        categoryImages = CategoryController.shared.categoryImagesByID
        updateDoneButton()

    }
    
    //MARK: Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let id = categories.count > 0 ? categories.last!.id + 1 : 1
            categories.append(Category(id: id, name: "", minimumStockLevel: nil))
            let lastRow = categories.count - 1
            tableView.insertRows(at: [IndexPath(row: lastRow, section: 0)], with: UITableView.RowAnimation.automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let items = ItemController.shared.items(byCategoryID: categories[indexPath.row].id) else {
                categoryImages.removeValue(forKey: categories[indexPath.row].id)
                categories.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                return
            }
            let alertMessage = items.count > 1 ? "are still \(items.count) items" : "is still 1 item"
            let alert = UIAlertController(title: "Unable to Delete Category", message: "Only empty categories can be deleted. There \(alertMessage) in this category.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func updateDoneButton() {
        let emptyCategories = categories.filter { return $0.name == "" }
        if emptyCategories.isEmpty {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        let category = categories[lastSelectedIndex.row]
        categoryImages[category.id] = image
        tableView.reloadRows(at: [lastSelectedIndex], with: .automatic)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.modalPresentationStyle = .popover
        imagePicker.delegate = self
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let imageView = (tableView.cellForRow(at: lastSelectedIndex) as! EditCategoryTableViewCell).quantityTextField
        imagePicker.popoverPresentationController?.sourceView = imageView
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showImageAlert(forCategoryID categoryID: Int) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Change category image", style: .default, handler: { (_) in
            self.showImagePicker()
        }))
        alert.addAction(UIAlertAction(title: "Delete category image", style: .destructive, handler: { (_) in
            self.categoryImages.removeValue(forKey: categoryID)
            self.tableView.reloadRows(at: [self.lastSelectedIndex], with: .automatic)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let imageView = (tableView.cellForRow(at: lastSelectedIndex) as! EditCategoryTableViewCell).quantityTextField
        alert.popoverPresentationController?.sourceView = imageView
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: Delegate Methods
    
    func categoryChanged(name: String, minQty: Int?, indexPath: IndexPath) {
        categories[indexPath.row].name = name
        categories[indexPath.row].minimumStockLevel = minQty
    }
    
    func imageViewTapped(atIndexPath indexPath: IndexPath) {
        lastSelectedIndex = indexPath
        let categoryID = categories[indexPath.row].id
        if let _ = categoryImages[categoryID] {
            showImageAlert(forCategoryID: categoryID)
        } else {
            showImagePicker()
        }
        
    }
    
    //MARK: Cell configuration
    
    func configure(_ cell: EditCategoryTableViewCell, atIndexPath: IndexPath) {
        cell.nameTextField.text = categories[atIndexPath.row].name
        if let minQty = categories[atIndexPath.row].minimumStockLevel {
            cell.quantityTextField.text = String(minQty)
        }
        if let image = categoryImages[categories[atIndexPath.row].id] {
            cell.categoryImageView.image = image
        }
        cell.delegate = self
        cell.indexPath = atIndexPath
    }
    
    //MARK: Networking UI
    
    func showNetworkFailureAlert(error: Error) {
        let alert = UIAlertController(title: "A Problem Occurred", message: "Error: \(error)", preferredStyle: .alert)
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
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if duplicatesFound() { return }
        startBarButtonIndicator()
        CategoryController.shared.modifyCategories(with: categories)
        CategoryController.shared.modifyCategoryImages(with: categoryImages)
        CategoryController.shared.saveImages()
        CategoryController.shared.saveCategories()
        ItemController.shared.saveItems()
        dismiss(animated: true, completion: nil)
    }
    
    func duplicatesFound() -> Bool {
        let filteredCategories = categories.removingDuplicates()
        if categories != filteredCategories {
            let alert = UIAlertController(title: "Unable to update categories.", message: "Duplicate categories are not allowed. Please delete the duplicates.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return true
        } else {
            return false
        }
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return categories.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 65.0
        } else {
            return 44.0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.editCategoryTableCell, for: indexPath) as! EditCategoryTableViewCell
            configure(cell, atIndexPath: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.addCategoryTableCell, for: indexPath)
            return cell
        }
    }

}
