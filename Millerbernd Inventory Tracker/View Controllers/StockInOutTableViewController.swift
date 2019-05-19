//
//  StockInOutTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/13/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

protocol StockInOutControllerDelegate {
    func itemModified(_ item: Item)
}

class StockInOutTableViewController: UITableViewController, ReasonTableViewDelegate, UITextFieldDelegate, EmployeeTableCellDelegate, LocationCellDelegate {
    
    //MARK: Properties
    
    @IBOutlet var doneButton: UIBarButtonItem!
    
    var item: Item!
    var changeReason: String?
    var employee: String?
    var amountsChanged = [Int]()
    var locations = [String]()
    var activityIndicator = UIActivityIndicatorView()
    
    //MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAdjustments()
        updateDoneButton()
        
    }
    
    func updateDoneButton() {
        guard let employee = employee,
            let _ = changeReason,
            !employee.isEmpty else {
                doneButton.isEnabled = false
                return
        }
        doneButton.isEnabled = true
    }
    
    func setupAdjustments() {
        for location in item.locations {
            amountsChanged.append(0)
            locations.append(location)
        }
    }
    
    func showAddLocationAlert() {
        let alert = UIAlertController(title: "Enter location number.", message: nil, preferredStyle: .alert)
        var returnLocation: String?
        alert.addTextField { (textField) in
            textField.placeholder = "301A01A"
        }
        let done = UIAlertAction(title: "Done", style: .default) { (_) in
            let locationNumber = alert.textFields![0].text!
            print(locationNumber)
            guard self.validateLocationNumber(locationNumber) else {
                let invalidAlert = UIAlertController(title: "Invalid location", message: "Please enter a valid location number. (ex. 301A01A)", preferredStyle: .alert)
                invalidAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                    self.showAddLocationAlert()
                }))
                self.present(invalidAlert, animated: true, completion: nil)
                return
            }
            returnLocation = locationNumber.capitalized
            self.item.locations.append(returnLocation!)
            self.locations.append(returnLocation!)
            self.item.stockAtLocation.append(0)
            self.amountsChanged.append(0)
            self.tableView.insertRows(at: [IndexPath(row: self.item.locations.count - 1, section: 2)], with: UITableView.RowAnimation.automatic)
            //self.tableView.reloadSections(IndexSet(arrayLiteral: 2), with: UITableView.RowAnimation.automatic)
        }
        alert.addAction(done)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func validateLocationNumber(_ number: String) -> Bool {
        guard number.isEmpty
            else { return true }
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == IndexPath(row: item.locations.count, section: 2) {
            showAddLocationAlert()
        }
        self.view.endEditing(true)
    }
    
    //MARK: Delegate methods
    
    func didSelect(reason: String) {
        changeReason = reason
        tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: UITableView.RowAnimation.automatic)
        updateDoneButton()
    }
    
    func employeeChanged(number: String) {
        self.employee = number
        updateDoneButton()
    }
    
    func quantityChanged(to quantity: Int, difference: Int, indexPath: IndexPath) {
        item.stockAtLocation[indexPath.row] = quantity
        amountsChanged[indexPath.row] = difference
    }
    
    //MARK: Networking UI Methods
    
    func showNetworkFailureAlert() {
        let alert = UIAlertController(title: "A problem occured", message: "Unable to update item.", preferredStyle: .alert)
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
        startBarButtonIndicator()
        guard let adjustment = createNewAdjustment() else {
            showNetworkFailureAlert()
            return
        }
        AdjustmentController.shared.addNew(adjustment: adjustment)
        ItemController.shared.adjustQuantities(for: self.item)
        ItemController.shared.saveItems()
        AdjustmentController.shared.saveAdjustments()
        dismiss(animated: true, completion: nil)
    }
    
    func createNewAdjustment() -> Adjustment? {
        for (index, change) in amountsChanged.enumerated().reversed() {
            if change == 0 {
                amountsChanged.remove(at: index)
                locations.remove(at: index)
            }
            
        }
        return Adjustment(employee: employee!, reason: changeReason!, dateAndTime: Date(timeIntervalSinceNow: 0), item: item, amountsChanged: amountsChanged, locations: locations)
    }
    
    //MARK: Cell configuration
    
    func configureCell1(_ cell: StockInOutItemTableViewCell, atindexPath: IndexPath) {
        cell.itemLabel?.text = item.details
        cell.quantityLabel?.text = "Current Qty: \(item.totalQuantity)"
        
    }
    
    func configureCell2(_ cell: EmployeeNumberTableViewCell, atindexPath: IndexPath) {
        cell.delegate = self
    }
    
    func configureCell3(_ cell: UITableViewCell, atindexPath: IndexPath) {
        if let changeReason = changeReason {
            cell.detailTextLabel?.text = changeReason
        } else {
            cell.detailTextLabel?.text = "Select"
        }
    }
    
    
    
    func configureCell4(_ cell: LocationQuantityTableViewCell, atindexPath: IndexPath) {
        let location = item.locations[atindexPath.row]
        let quantity = item.stockAtLocation[atindexPath.row]
        cell.originalQuantity = quantity
        cell.locationLabel.text = location
        cell.quantityStepper.value = Double(quantity)
        cell.updateUI()
        cell.delegate = self
        cell.indexPath = atindexPath
    }
    
    func configureCell5(_ cell: UITableViewCell, atIndexPath: IndexPath) {
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 2
        default:
            return item.locations.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 2:
            return "Locations and Quantities"
        default:
            return nil
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.stockInOutCell1, for: indexPath) as! StockInOutItemTableViewCell
            configureCell1(cell1, atindexPath: indexPath)
            return cell1
        case 1:
            if indexPath.row == 0 {
                let cell2 = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.stockInOutCell2, for: indexPath) as! EmployeeNumberTableViewCell
                configureCell2(cell2, atindexPath: indexPath)
                return cell2
            } else {
                let cell3 = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.stockInOutCell3, for: indexPath)
                configureCell3(cell3, atindexPath: indexPath)
                return cell3
            }
        default:
            if indexPath.row < item.locations.count {
                let cell4 = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.stockInOutCell4, for: indexPath) as! LocationQuantityTableViewCell
                configureCell4(cell4, atindexPath: indexPath)
                return cell4
            } else {
                let cell5 = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.stockInOutCell5, for: indexPath)
                configureCell5(cell5, atIndexPath: indexPath)
                return cell5
            }
            
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == PropertyKeys.stockInOutReasonSegue {
            let reasonController = segue.destination as! ReasonTableViewController
            reasonController.chosenReason = changeReason
            reasonController.delegate = self
        }
    }
    

}
