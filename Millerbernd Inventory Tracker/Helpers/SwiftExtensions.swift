//
//  SwiftExtensions.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/23/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import Foundation
import UIKit

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

protocol Dated {
    var date: Date { get }
}

extension Array where Element: Dated {
    func groupedBy(dateComponents: Set<Calendar.Component>) -> [Date: [Element]] {
        let initial: [Date: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { acc, cur in
            let components = Calendar.current.dateComponents(dateComponents, from: cur.date)
            let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [cur]
        }
        
        return groupedByDateComponents
    }
}

extension UIColor {
    static let millerberndGreen = UIColor(displayP3Red: 181/255.0, green: 189/255.0, blue: 63/255.0, alpha: 1.0)
    static let millerberndBlue = UIColor(displayP3Red: 2/255.0, green: 94/255.0, blue: 164/255.0, alpha: 1.0)
}
