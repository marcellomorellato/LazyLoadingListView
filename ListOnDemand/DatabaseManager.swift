//
//  DatabaseManager.swift
//  ListOnDemand
//
//  Created by Marcello Morellato on 01/11/23.
//

import Combine
import SwiftUI

class DatabaseManager {
    func loadOrders(currentPage: Binding<Int>, batchSize: Int, totalRecords: Int, completion: @escaping ([Order]) -> Void) {
        DispatchQueue.global().async {
            let start = currentPage.wrappedValue * batchSize
            if start >= totalRecords {
                return // No more data to load
            }

            let end = min(start + batchSize, totalRecords)
            var newOrders: [Order] = []

            for index in start..<end {
                let newOrder = Order(
                    lastUpdate: Date(),
                    creationDate: Date(),
                    Identifier: "Order \(index + 1)",
                    descr: "Description for Order \(index + 1)",
                    code: "00\(index + 1)"
                )
                newOrders.append(newOrder)
            }

            // Simulate database or network delay
            sleep(1)

            // Update the data on the main queue
            DispatchQueue.main.async {
                completion(newOrders)
                currentPage.wrappedValue += 1
            }
        }
    }
}

