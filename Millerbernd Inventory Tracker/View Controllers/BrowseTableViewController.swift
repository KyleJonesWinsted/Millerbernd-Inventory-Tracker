//
//  BrowseTableViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/3/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class BrowseTableViewController: UITableViewController, UISplitViewControllerDelegate {
    
    //MARK: Properties
    
    let browseTypes: [String] = ["Categories", "Locations", "Manufacturers"]
    var recentItems = [Item]() {
        didSet {
            let newCount = recentItems.count
            guard newCount > 0 else {return}
            let newItem = recentItems[0]
            if oldValue.count != newCount || (oldValue[0].SKU == newItem.SKU && oldValue[0].totalQuantity != newItem.totalQuantity) {
                 self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = .white
        splitViewController?.delegate = self
        updateItemQuantities()
        self.clearsSelectionOnViewWillAppear = true
        tableView.separatorStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: ItemController.itemsUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: ItemController.recentItemsNotification, object: nil)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.reloadData()
        
    }
    
    //MARK: Methods
    
    @objc func updateUI() {
        DispatchQueue.main.async {
            self.updateItemQuantities()
            if !(self.isViewLoaded && self.view?.window != nil) {
                self.tableView.reloadSections(IndexSet(integer: 2), with: .automatic)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            tableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 2))
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
    
    func updateItemQuantities() {
        recentItems = ItemController.shared.recentItems
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let view = UIView()
            view.backgroundColor = .white
            let label = UILabel()
            label.text = "Recently Viewed"
            label.textColor = .black
            label.font = UIFont.systemFont(ofSize: 20.0, weight: .heavy)
            view.addSubview(label)
            label.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: nil, paddingTop: 10.0, paddingLeft: 10.0, paddingBottom: 10.0, paddingRight: 0.0, width: 0.0, height: 0.0, enableInsets: true)
            return view
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 45.0
        } else {
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return UITableView.automaticDimension
        case 1:
            return UITableView.automaticDimension
        default:
            return 90.0
        }
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 1
        default:
            return recentItems.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let browseCell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.browseTableCell, for: indexPath)
            browseCell.textLabel?.text = browseTypes[indexPath.row]
            return browseCell
        case 1:
            let skusCell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.skusTableCell, for: indexPath)
            skusCell.textLabel?.text = "SKUs"
            return skusCell
        default:
            let recentCell = tableView.dequeueReusableCell(withIdentifier: PropertyKeys.recentItemBrowseCell, for: indexPath) as! ItemTableCell
            let item = recentItems[indexPath.row]
            recentCell.item = item
            return recentCell
        }
    
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = tableView.indexPathForSelectedRow!
        if segue.identifier == PropertyKeys.intermediateTableSegue {
            let intermediateTable = segue.destination as! IntermediateTableViewController
            intermediateTable.browseType = browseTypes[index.row]
            
        } else if segue.identifier == PropertyKeys.skusListSegue {
            let itemListTable = segue.destination as! ItemListTableViewController
            itemListTable.filterItem = "All Items"
            itemListTable.browseType = "All Items"
            
        } else if segue.identifier == PropertyKeys.recentItemDetailsSegue {
            let navController = segue.destination as! UINavigationController
            let itemDetails = navController.topViewController as! ItemDetailTableViewController
            itemDetails.item = recentItems[index.row]
            
        }
    }
    

}
