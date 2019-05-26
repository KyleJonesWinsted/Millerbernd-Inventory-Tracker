//
//  EditCategoryTableViewCell.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/22/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

protocol EditCategoryCellDelegate {
    func categoryChanged(name: String, minQty: Int?, indexPath: IndexPath)
    func imageViewTapped(atIndexPath indexPath: IndexPath)
}

class EditCategoryTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    //MARK: Properties

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var categoryImageView: UIImageView!
    var delegate: EditCategoryTableViewController?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextField.autocapitalizationType = .words
        quantityTextField.keyboardType = .numberPad
        nameTextField.delegate = self
        quantityTextField.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(sender:)))
        categoryImageView.addGestureRecognizer(tapRecognizer)
        categoryImageView.layer.cornerRadius = 10.0
    }
    
    
        
    //MARK: Methods
    
    @objc func imageViewTapped(sender: Any?) {
        delegate?.imageViewTapped(atIndexPath: indexPath!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            quantityTextField.becomeFirstResponder()
        } else {
            quantityTextField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        guard let name = nameTextField.text else { return }
        let minQty: Int? = Int(quantityTextField.text!)
        delegate?.categoryChanged(name: name, minQty: minQty, indexPath: indexPath!)
    }
    
}
