//
//  Item.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/3/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import Foundation

struct Item: Codable, Comparable, Equatable {
    
    //MARK: Properties
    
    var manufacturer: String
    var details: String
    var SKU: Int
    var category: Category
    var locations: [String]
    var stockAtLocation: [Int]
    var totalQuantity: Int {
        var total = 0
        for item in stockAtLocation {
            total += item
        }
        return total
    }
    var isBelowMinimumStock: Bool {
        if self.category.minimumStockLevel != nil {
            return self.totalQuantity < self.category.minimumStockLevel!
        } else {
            return false
        }
        
    }
    
    //MARK: Protocol Methods
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.SKU == rhs.SKU
    }
    
    static func < (lhs: Item, rhs: Item) -> Bool {
        return lhs.SKU < rhs.SKU
    }
    
    
}
