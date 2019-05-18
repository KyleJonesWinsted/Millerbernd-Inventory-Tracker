//
//  SelectCategoryTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/24/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

protocol SelectCategoryTableDelegate {
    func didSelect(category: Category)
}

class SelectCategoryTableViewController: UITableViewController {
    
    //MARK: Properties
    
    let categories = CategoryController.shared.categories
    var selectedCategory: Category?
    var delegate: AddNewItemTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    //MARK: Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        delegate?.didSelect(category: selectedCategory!)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.selectCategoryTableCell, for: indexPath)
        
        if selectedCategory == categories[indexPath.row] {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.textLabel?.text = categories[indexPath.row].description

        return cell
    }
    
}
