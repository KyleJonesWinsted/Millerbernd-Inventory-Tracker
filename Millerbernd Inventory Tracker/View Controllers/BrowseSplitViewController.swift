//
//  BrowseSplitViewController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 5/1/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import UIKit

class BrowseSplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    public var navController: UINavigationController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredDisplayMode = .allVisible
        
        navController = viewControllers[0] as? UINavigationController
        
    }

}
