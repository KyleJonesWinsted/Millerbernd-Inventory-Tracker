//
//  CategoryController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/4/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import Foundation
import UIKit

class CategoryController {
    
    //MARK: Properties
    
    static let shared = CategoryController()
    
    var categories = [Category]()
    var categoryImagesByID = [Int:UIImage]()
    
    //MARK: Data Persistance
    
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    func loadCategories() {
        let archiveURL = documentsDirectory.appendingPathComponent("categories").appendingPathExtension("json")
        
        if let data = try? Data(contentsOf: archiveURL) {
            categories = (try? JSONDecoder().decode([Category].self, from: data)) ?? []
        }
    }
    
    func saveCategories() {
        let archiveURL = documentsDirectory.appendingPathComponent("categories").appendingPathExtension("json")
        if let data = try? JSONEncoder().encode(categories) {
            try? data.write(to: archiveURL)
        }
    }
    
    func loadImages() {
        let archiveURL = documentsDirectory.appendingPathComponent("categoryImages").appendingPathExtension("json")
        guard let data = try? Data(contentsOf: archiveURL),
        let decodedImagesByID = (try? JSONDecoder().decode([Int:Data].self , from: data)) else { return }
        for (id, data) in decodedImagesByID {
            let image = UIImage(data: data, scale: UIScreen.main.scale)
            categoryImagesByID[id] = image
        }
        
    }
    
    func saveImages() {
        var encodedImagesByID = [Int:Data]()
        let archiveURL = documentsDirectory.appendingPathComponent("categoryImages").appendingPathExtension("json")
        for (id, image) in categoryImagesByID {
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                encodedImagesByID[id] = imageData
            }
        }
        if let data = try? JSONEncoder().encode(encodedImagesByID) {
            try? data.write(to: archiveURL)
        }
    }
    
    //MARK: Methods
    
    func modifyCategories(with categories: [Category]) {
        self.categories = categories
        ItemController.shared.updateItemCategories()
        saveCategories()
    }
    
    func modifyCategoryImages(with images: [Int:UIImage]) {
        self.categoryImagesByID = images
    }
    
    func imageForCategory(id: Int) -> UIImage? {
        return categoryImagesByID[id]
    }
}
