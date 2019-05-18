//
//  LocationQuantityTableViewCell.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/13/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

protocol LocationCellDelegate {
    func quantityChanged(to quantity: Int, difference: Int, indexPath: IndexPath)
}

class LocationQuantityTableViewCell: UITableViewCell {
    
    //MARK: Properties
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var changeLabel: UILabel!
    var originalQuantity: Int!
    var delegate: StockInOutTableViewController?
    var indexPath: IndexPath?
    
    //MARK: Methods
    
    func updateUI() {
        quantityStepper.value = Double(originalQuantity)
        quantityLabel.text = String(originalQuantity)
        changeLabel.isHidden = true
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        quantityLabel.text = String(Int(quantityStepper.value))
        let change = Int(quantityStepper.value) - originalQuantity
        delegate?.quantityChanged(to: Int(quantityStepper.value), difference: change, indexPath: indexPath!)
        switch change {
        case 0:
            changeLabel.isHidden = true
        case ..<0:
            changeLabel.isHidden = false
            changeLabel.textColor = .red
            changeLabel.text = String(change)
        case 1...:
            changeLabel.isHidden = false
            changeLabel.textColor = .millerberndGreen
            changeLabel.text = "+\(change)"
        default:
            return
        }
    }
}
