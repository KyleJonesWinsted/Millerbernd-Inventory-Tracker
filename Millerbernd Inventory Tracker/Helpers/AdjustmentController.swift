//
//  AdjustmentController.swift
//  MillerberndInventoryTracker
//
//  Created by Kyle Jones on 4/10/19.
//  Copyright © 2019 Kyle Jones. All rights reserved.
//

import Foundation

class AdjustmentController {
    
    //MARK: Properties
    
    static let shared = AdjustmentController()
    
    private var allAdjustments = [Adjustment]()
    private var adjustmentsByEmployee = [String: [Adjustment]]()
    private var adjustmentsByDate = [Date: [Adjustment]]()
    private var adjustmentsBySKU = [Int : [Adjustment]]()
    private var adjustmentsByReason = [String: [Adjustment]]()
    
    var employees: [String] {
        get {
            return adjustmentsByEmployee.keys.sorted()
        }
    }
    
    var dates: [Date] {
        get {
            return adjustmentsByDate.keys.sorted(by: { (Date1, Date2) -> Bool in
                return Date1 > Date2
            })
        }
    }
    
    var SKU: [Int] {
        get {
            return adjustmentsBySKU.keys.sorted()
        }
    }
    
    var reasonCodes: [String] {
        get {
            return adjustmentsByReason.keys.sorted()
        }
    }
    
    let sampleAdjustments = [
        Adjustment(employee: "2718", reason: "Correction", dateAndTime: Date(timeIntervalSinceNow: -8000), item: Item(manufacturer: "TestManufacturer", details: "TestDescription", SKU: 1234, category: Category(id: 1, name: "TestCategory", minimumStockLevel: nil), locations: [], stockAtLocation: []), amountsChanged: [-1], locations: ["301A01A"]),
        Adjustment(employee: "2718", reason: "General Use", dateAndTime: Date(timeIntervalSinceNow: -2000), item: Item(manufacturer: "Sumitomo", details: "CNMG432EMX", SKU: 2345, category: Category(id: 2, name: "Carbide Insert", minimumStockLevel: nil), locations: [], stockAtLocation: []), amountsChanged: [-1], locations: ["302A01A"]),
        Adjustment(employee: "1234", reason: "Correction", dateAndTime: Date(timeIntervalSinceNow: -80000), item: Item(manufacturer: "Sandvik", details: "DCLNL 20 3D", SKU: 3456, category: Category(id: 3, name: "Lathe Tool Holder", minimumStockLevel: nil), locations: ["301A01A","303A01A"], stockAtLocation: [1,2]), amountsChanged: [-1,1], locations: ["301A01A","303A01A"])
    ]
    
    private func process(_ adjustments: [Adjustment]) {
        adjustmentsByEmployee.removeAll()
        adjustmentsByDate.removeAll()
        adjustmentsBySKU.removeAll()
        adjustmentsByReason.removeAll()
        
        allAdjustments = adjustments
        for adjustment in adjustments {
            adjustmentsByEmployee[adjustment.employee, default: []].insert(adjustment, at: 0)
            adjustmentsByDate[adjustment.date, default: []].insert(adjustment, at: 0)
            adjustmentsBySKU[adjustment.item.SKU, default: []].insert(adjustment, at: 0)
            adjustmentsByReason[adjustment.reason, default: []].insert(adjustment, at: 0)
        }
    }
    
    //MARK: HTTPS Networking
    
    func getRemoteAdjustments() {
        var request = URLRequest(url: URL(string: "https://api.myjson.com/bins/l6uv4")!)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data,
                let adjustments = try? JSONDecoder().decode([Adjustment].self, from: data) {
                self.process(adjustments)
                self.saveAdjustments()
            }
        }
        task.resume()
    }
    
    //MARK: Data Persistance
    
    func saveAdjustments() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("adjustments").appendingPathExtension("json")
        
        if let data = try? JSONEncoder().encode(allAdjustments) {
            try? data.write(to: archiveURL)
        }
    }
    
    func loadAdjustments() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let archiveURL = documentsDirectory.appendingPathComponent("adjustments").appendingPathExtension("json")
        
        guard let data = try? Data(contentsOf: archiveURL) else {
            allAdjustments = sampleAdjustments
            process(allAdjustments)
            return
        }
        allAdjustments = (try? JSONDecoder().decode([Adjustment].self, from: data)) ?? []
        process(allAdjustments)
    }
    
    //MARK: Methods
    
    func addNew(adjustment: Adjustment) {
        allAdjustments.append(adjustment)
        if allAdjustments.count > 5000 {
            allAdjustments.removeFirst()
        }
        process(allAdjustments)
    }
    
    //MARK: Property Access
    
    func adjustments(fromEmployee employee: String) -> [Adjustment]? {
        return adjustmentsByEmployee[employee]
    }
    
    func adjustments(onDate date: Date) -> [Adjustment]? {
        return adjustmentsByDate[date]
    }
    
    func adjustments(withSKU SKU: Int) -> [Adjustment]? {
        return adjustmentsBySKU[SKU]
    }
    
    func adjustments(forReasonCode reason: String) -> [Adjustment]? {
        return adjustmentsByReason[reason]
    }
    
    
}
