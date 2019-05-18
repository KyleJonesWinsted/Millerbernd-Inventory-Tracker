//
//  ResultsTableViewCell.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/28/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
