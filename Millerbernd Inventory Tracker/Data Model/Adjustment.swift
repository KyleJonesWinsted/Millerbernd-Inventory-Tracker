//
//  Adjustment.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/10/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import Foundation

struct Adjustment: Codable, Comparable, Equatable {
    
    //MARK: Properties
    
    var employee: String
    var reason: String
    var dateAndTime: Date
    var item: Item
    var amountsChanged: [Int]
    var locations: [String]
    var totalChange: Int {
        var total = 0
        for change in amountsChanged {
            total += change
        }
        return total
    }
    var date: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: self.dateAndTime)
        return Calendar.current.date(from: components)!
    }
    
    //MARK: Protocol Methods
    
    static func == (lhs: Adjustment, rhs: Adjustment) -> Bool {
        return lhs.dateAndTime == rhs.dateAndTime
    }
    
    static func < (lhs: Adjustment, rhs: Adjustment) -> Bool {
        return lhs.dateAndTime > rhs.dateAndTime
    }
}
