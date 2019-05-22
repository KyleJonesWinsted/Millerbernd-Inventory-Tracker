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
    private var itemURLsBySKU = [Int: URL]()
    
    
    
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
    
    enum NetworkError: Error {
        case noConnection
        case badURL
    }
    
    func post(item: Item, completion: @escaping (Result<URL,NetworkError>) -> Void) {
        let baseURL = URL(string: "https://api.myjson.com/bins")
        var request = URLRequest(url: baseURL!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try? JSONEncoder().encode(item)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                let decodedData = try! JSONDecoder().decode([String:String].self, from: data)
                if let uriString = decodedData["uri"],
                    let uri = URL(string: uriString) {
                    completion(.success(uri))
                } else {
                    completion(.failure(.badURL))
                }
            } else {
                completion(.failure(.noConnection))
            }
        }
        task.resume()
    }
    
    func put(item: Item, completion: @escaping (Result<Item, NetworkError>) -> Void) {
        let item = ItemController.shared.adjustQuantities(for: item)
        guard let baseURL = itemURLsBySKU[item.SKU] else { completion(.failure(.badURL)); return }
        var request = URLRequest(url: baseURL)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try? JSONEncoder().encode(item)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let _ = error {
                completion(.failure(.noConnection))
            } else {
                completion(.success(item))
            }
        }
        task.resume()
    }
    
    func deleteRemote(item: Item, completion: @escaping (Result<Item,NetworkError>) -> Void) {
        var itemURLs = itemURLsBySKU
        itemURLs.removeValue(forKey: item.SKU)
        let baseURL = URL(string: "https://api.myjson.com/bins/pc366")
        var request = URLRequest(url: baseURL!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try? JSONEncoder().encode(itemURLs)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { (_,_,error) in
            if let _ = error {
                completion(.failure(.noConnection))
            } else {
                completion(.success(item))
            }
        }
        
        task.resume()
    }
    
    func putURLs() {
        let baseURL = URL(string: "https://api.myjson.com/bins/pc366")
        var request = URLRequest(url: baseURL!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try? JSONEncoder().encode(self.itemURLsBySKU)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request)
        
        task.resume()
    }
    
    func getURLs() {
        let baseURL = URL(string: "https://api.myjson.com/bins/pc366")
        var request = URLRequest(url: baseURL!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, _, _) in
            if let data = data,
                let urls = try? JSONDecoder().decode([Int:URL].self, from: data) {
                self.itemURLsBySKU = urls
                self.getRemoteItems()
            } else {
                print("error getting urls")
            }
        }
        task.resume()
    }
    
    func getRemoteItems() {
        var items = [Item]()
        let taskGroup = DispatchGroup()
        for url in itemURLsBySKU.values {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            taskGroup.enter()
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, _, _) in
                if let data = data,
                    let item = try? JSONDecoder().decode(Item.self, from: data) {
                    items.append(item)
                }
                taskGroup.leave()
            })
            task.resume()
        }
        taskGroup.notify(queue: DispatchQueue.global()) {
            self.process(items)
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
    
    func saveURLs() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("itemURLs").appendingPathExtension("json")
        
        if let data = try? JSONEncoder().encode(itemURLsBySKU) {
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
    
    func loadURLs() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("itemURLs").appendingPathExtension("json")
        
        if let data = try? Data(contentsOf: archiveURL) {
                itemURLsBySKU = (try? JSONDecoder().decode([Int: URL].self, from: data)) ?? [:]
        }
    }
    
    func loadRecent() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recentURL = documentsDirectory.appendingPathComponent("recentItems").appendingPathExtension("json")
        if let recentData = try? Data(contentsOf: recentURL) {
            recentItems = (try? JSONDecoder().decode([Item].self, from: recentData)) ?? []
        }
    }
    
    //MARK: Methods
    
    func append(uri: URL, forSKU SKU: Int) {
        itemURLsBySKU[SKU] = uri
        self.saveURLs()
        DispatchQueue.global().async {
            self.putURLs()
        }
    }
    
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
        itemURLsBySKU.removeValue(forKey: SKU)
        DispatchQueue.global().async {
            self.putURLs()
        }
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
