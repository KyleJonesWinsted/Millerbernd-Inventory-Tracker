//
//  Category.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/3/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import Foundation

struct Category: Hashable, Comparable, Codable, CustomStringConvertible {
    
    //MARK: Properties
    
    var id: Int
    var name: String
    var minimumStockLevel: Int?
    
    var description: String {
        return self.name
    }
    
    //MARK: Protocol Methods
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name.lowercased() == rhs.name.lowercased()
    }
    
    static func < (lhs: Category, rhs: Category) -> Bool {
        return lhs.name.lowercased() < rhs.name.lowercased()
    }
    
    
}
