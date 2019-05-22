//
//  CategoryController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/4/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import Foundation

class CategoryController {
    
    //MARK: Properties
    
    static let shared = CategoryController()
    
    var categories = [Category]()
    
    let sampleCategories = [
        Category(id: 1, name: "TestCategory", minimumStockLevel: nil),
        Category(id: 2, name: "Carbide Insert", minimumStockLevel: 5),
        Category(id: 3, name: "Lathe Tool Holder", minimumStockLevel: 1)
    ]
    
    //MARK: HTTPS Networking
    
    enum NetworkError: Error {
        case noConnection
        case badURL
    }
    
    func putRemoteCategories(categories: [Category], completion: @escaping (Result<[Category],NetworkError>) -> Void) {
        let data: [Category] = categories
        var request = URLRequest(url: URL(string: "https://api.myjson.com/bins/pybpc")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try? JSONEncoder().encode(data)
        request.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil {
                completion(.success(categories))
            } else {
                completion(.failure(.noConnection))
            }
        }
        task.resume()
    }
    
    func getRemoteCategories() {
        var request = URLRequest(url: URL(string: "https://api.myjson.com/bins/pybpc")!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data,
                let categories = try? JSONDecoder().decode([Category].self, from: data) {
                self.categories = categories
                self.saveCategories()
            }
        }
        task.resume()
    }
    
    //MARK: Data Persistance
    
    func loadCategories() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("categories").appendingPathExtension("json")
        
        if let data = try? Data(contentsOf: archiveURL) {
            categories = (try? JSONDecoder().decode([Category].self, from: data)) ?? []
        } else {
            categories = sampleCategories
        }
    }
    
    func saveCategories() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("categories").appendingPathExtension("json")
        if let data = try? JSONEncoder().encode(categories) {
            try? data.write(to: archiveURL)
        }
    }
    
    //MARK: Methods
    
    func modifyCategories(with categories: [Category]) {
        self.categories = categories
        ItemController.shared.updateItemCategories()
        saveCategories()
    }
}
