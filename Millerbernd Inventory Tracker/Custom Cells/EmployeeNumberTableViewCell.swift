//
//  EmployeeNumberTableViewCell.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/13/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

protocol EmployeeTableCellDelegate {
    func employeeChanged(number: String)
}

class EmployeeNumberTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet weak var employeeTextField: UITextField!
    
    var delegate: StockInOutTableViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        employeeTextField.autocapitalizationType = .words
    }

    
    //MARK: Methods

    @IBAction func employeeTextFieldChanged(_ sender: UITextField) {
        delegate?.employeeChanged(number: employeeTextField.text!)
    }
}
