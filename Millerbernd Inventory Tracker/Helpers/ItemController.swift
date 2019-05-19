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
    
    let sampleItems = [
        Item(manufacturer: "TestManufacturer", details: "TestDescription", SKU: 1234, category: Category(id: 1, name: "TestCategory", minimumStockLevel: nil), locations: ["301A01A", "302A02A", "303A02A"], stockAtLocation: [1, 2, 3]),
        Item(manufacturer: "Sumitomo", details: "CNMG432EMX", SKU: 2345, category: Category(id: 2, name: "Carbide Insert", minimumStockLevel: 5), locations: ["301A01A", "303A01A"], stockAtLocation: [2, 2]),
        Item(manufacturer: "Sandvik", details: "DCLNL 20 3D", SKU: 3456, category: Category(id: 3, name: "Lathe Tool Holder", minimumStockLevel: 1), locations: ["301A01A"], stockAtLocation: [1])
    ]
    
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
    
    //MARK: HTTPS Networking
    
    
    
//    func putRemoteItems(item: Item?, completion: @escaping (Bool) -> Void) {
//        var items = itemsBySKU
//        if var item = item {
//            while item.locations != item.locations.sorted() {
//                for i in 1 ... item.locations.count - 1 {
//                    let location1 = item.locations[i-1]
//                    let location2 = item.locations[i]
//                    let quantity2 = item.stockAtLocation[i]
//                    if location2 < location1 {
//                        item.locations.insert(location2, at: i-1)
//                        item.locations.remove(at: i + 1)
//                        item.stockAtLocation.insert(quantity2, at: i-1)
//                        item.stockAtLocation.remove(at: i + 1)
//                    }
//                }
//            }
//
//            for (index, stock) in item.stockAtLocation.enumerated().reversed() {
//                if stock == 0 {
//                    item.stockAtLocation.remove(at: index)
//                    item.locations.remove(at: index)
//                }
//            }
//            items[item.SKU] = item
//        }
//        let data: [Int:Item] = items
//        var request = URLRequest(url: URL(string: "https://api.myjson.com/bins/jrf0g")!)
//        request.httpMethod = "PUT"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        let jsonData = try? JSONEncoder().encode(data)
//        request.httpBody = jsonData
//        let task = URLSession.shared.dataTask(with: request) { (data,response,error) in
//            if error == nil {
//                completion(true)
//            } else {
//                completion(false)
//            }
//        }
//        task.resume()
//    }
    
    func deleteRemoteItem(itemSKU: Int, completion: @escaping (Bool) -> Void) {
        var items = itemsBySKU
        items.removeValue(forKey: itemSKU)
        let data: [Int:Item] = items
        var request = URLRequest(url: URL(string: "https://api.myjson.com/bins/jrf0g")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try? JSONEncoder().encode(data)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil {
                completion(true)
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    func getRemoteItem() {
        var request = URLRequest(url: URL(string: "https://api.myjson.com/bins/jrf0g")!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data,
                let items = try? JSONDecoder().decode([Int: Item].self, from: data) {
                    self.process(Array(items.values))
                
            }
        }
        task.resume()
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
        
        guard let data = try? Data(contentsOf: archiveURL) else {
            items = sampleItems
            process(items)
            return
        }
        items = (try? JSONDecoder().decode([Item].self, from: data)) ?? []
        process(items)
    }
    
    func loadRecent() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recentURL = documentsDirectory.appendingPathComponent("recentItems").appendingPathExtension("json")
        if let recentData = try? Data(contentsOf: recentURL) {
            recentItems = (try? JSONDecoder().decode([Item].self, from: recentData)) ?? []
        }
    }
    
    //MARK: Methods
    
    func adjustQuantities(for item: Item) {
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
        itemsBySKU[item.SKU] = item
        let newItems: [Item] = Array(itemsBySKU.values)
        process(newItems)
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
        NotificationCenter.default.post(name: ItemController.itemsUpdatedNotification, object: nil)
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
