//
//  ItemController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/4/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import Foundation

class ItemController {
    
    //MARK: Properties
    
    static let shared = ItemController()
    static let itemsUpdatedNotification = Notification.Name("ItemsUpdated")
    static let recentItemsNotification = Notification.Name("recentUpdated")
    
    private var itemsBySKU = [Int: Item]()
    private var itemsByManufacturer = [String: [Item]]()
    private var itemsByLocation = [String: [Item]]()
    private var itemsByCategory = [Category: [Item]]()
    
    var categories: [Category] {
        get {
            return itemsByCategory.keys.sorted()
        }
    }
    
    var manufacturers: [String] {
        get {
            return itemsByManufacturer.keys.sorted()
        }
    }
    
    var locations: [String] {
        get {
            return itemsByLocation.keys.sorted()
        }
    }
    
    var recentItems = [Item]()
    
    private func process(_ items: [Item]) {
        itemsBySKU.removeAll()
        itemsByManufacturer.removeAll()
        itemsByLocation.removeAll()
        itemsByCategory.removeAll()
        
        for item in items {
            itemsBySKU[item.SKU] = item
            itemsByManufacturer[item.manufacturer, default: []].append(item)
            itemsByCategory[item.category, default: []].append(item)
            for location in item.locations.sorted() {
                itemsByLocation[location, default: []].append(item)
            }
        }
        
        for (index, item) in recentItems.enumerated().reversed() {
            recentItems.remove(at: index)
            if let replacementItem = ItemController.shared.items(withSKU: item.SKU) {
                recentItems.insert(replacementItem, at: index)
            }
        }
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: ItemController.itemsUpdatedNotification, object: nil)
            print("posted items updated notification")
        }
    }
    
    
    //MARK: Data persistance
    
    func saveItems() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("allItems").appendingPathExtension("json")
        
        let items = Array(itemsBySKU.values)
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: archiveURL)
        }
    }
    
    func saveRecent() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recentURL = documentsDirectory.appendingPathComponent("recentItems").appendingPathExtension("json")
        if let data = try? JSONEncoder().encode(recentItems) {
            try? data.write(to: recentURL)
        }
    }

    func loadItems() {
        var items: [Item]
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("allItems").appendingPathExtension("json")
        
        guard let data = try? Data(contentsOf: archiveURL) else { return }
        items = (try? JSONDecoder().decode([Item].self, from: data)) ?? []
        process(items)
    }
    
    func loadRecent() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recentURL = documentsDirectory.appendingPathComponent("recentItems").appendingPathExtension("json")
        if let recentData = try? Data(contentsOf: recentURL) {
            recentItems = (try? JSONDecoder().decode([Item].self, from: recentData)) ?? []
        }
        for (index, item) in recentItems.enumerated().reversed() {
            if !itemsBySKU.keys.contains(item.SKU) {
                recentItems.remove(at: index)
            }
        }
    }
    
    //MARK: Methods
    
    func adjustQuantities(for item: Item) -> Item {
        var item = item
        while item.locations != item.locations.sorted() {
            for i in 1 ... item.locations.count - 1 {
                let location1 = item.locations[i-1]
                let location2 = item.locations[i]
                let quantity2 = item.stockAtLocation[i]
                if location2 < location1 {
                    item.locations.insert(location2, at: i-1)
                    item.locations.remove(at: i + 1)
                    item.stockAtLocation.insert(quantity2, at: i-1)
                    item.stockAtLocation.remove(at: i + 1)
                }
            }
        }
        
        for (index, stock) in item.stockAtLocation.enumerated().reversed() {
            if stock == 0 {
                item.stockAtLocation.remove(at: index)
                item.locations.remove(at: index)
            }
        }
        return item
    }
    
    func updateItemCategories() {
        var newItems = [Item]()
        for category in CategoryController.shared.categories {
            if let items = ItemController.shared.items(byCategoryID: category.id) {
                for item in items {
                    var newItem = item
                    newItem.category = category
                    newItems.append(newItem)
                }
            }
        }
        process(newItems)
    }
    
    func addNew(item: Item) {
        itemsBySKU[item.SKU] = item
        process(Array(itemsBySKU.values))
    }
    
    func deleteItem(withSKU SKU: Int) {
        for (index, item) in recentItems.enumerated() {
            if item.SKU == SKU {
                recentItems.remove(at: index)
            }
        }
        itemsBySKU.removeValue(forKey: SKU)
        process(Array(itemsBySKU.values))
    }
    
    func addRecent(item: Item) {
        for (index, recentItem) in recentItems.enumerated().reversed() {
            if item.SKU == recentItem.SKU {
                recentItems.remove(at: index)
            }
        }
        recentItems.insert(item, at: 0)
        while recentItems.count > 50 {
            recentItems.remove(at: recentItems.count - 1)
        }
        NotificationCenter.default.post(name: ItemController.recentItemsNotification, object: nil)
        ItemController.shared.saveRecent()
    }
    
    //MARK: Property Access
    
    func items(withSKU SKU: Int) -> Item? {
        return itemsBySKU[SKU]
    }
    
    func allItems() -> [Item] {
        return itemsBySKU.values.sorted()
    }
    
    func items(inCategory categoryString: String) -> [Item]? {
        var category: Category? = nil
        for item in categories {
            if item.name.lowercased() == categoryString.lowercased() {
                category = item
            }
        }
        if category != nil {
            return itemsByCategory[category!]
        } else {
            return nil
        }
    }
    
    func items(byCategoryID categoryID: Int) -> [Item]? {
        var category: Category? = nil
        for item in categories {
            if item.id == categoryID {
                category = item
            }
        }
        if category != nil {
            return itemsByCategory[category!]
        } else {
            return nil
        }
    }
    
    func items(atLocation location: String) -> [Item]? {
        return itemsByLocation[location]
    }
    
    func items(fromManufacturer manufacturer: String) -> [Item]? {
        return itemsByManufacturer[manufacturer]
    }
    
}
