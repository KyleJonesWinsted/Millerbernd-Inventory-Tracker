//
//  ReasonTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/13/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

protocol ReasonTableViewDelegate {
    func didSelect(reason: String)
}

class ReasonTableViewController: UITableViewController {
    
    //MARK: Properties
    
    let changeReasons = [
        "General Use",
        "New Stock",
        "Relocation",
        "Correction",
        "Other"
    ]
    var chosenReason: String?
    var delegate: ReasonTableViewDelegate!
    
    //MARK: Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Reason"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenReason = changeReasons[indexPath.row]
        tableView.reloadData()
        delegate.didSelect(reason: chosenReason!)
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return changeReasons.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.stockInOutReasonCell, for: indexPath)

        cell.textLabel?.text = changeReasons[indexPath.row]
        if cell.textLabel?.text == chosenReason {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

}
