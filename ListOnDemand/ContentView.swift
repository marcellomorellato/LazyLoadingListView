//
//  ContentView.swift
//  ListOnDemand
//
//  Created by Marcello Morellato on 01/11/23.
//

import SwiftUI

struct OrderCell: View {
    let order: Order
    
    var body: some View {
        HStack {
            VStack {
                Text(order.creationDate.formatted(.dateTime.day()))
                    .font(.title)
                    .foregroundColor(.secondary)
                
                Text(order.creationDate.formatted(.dateTime.month(.twoDigits).year()))
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 5) {
                Text(order.descr)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text("Code \(order.code)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
    }
}



struct ContentView: View {
    @State private var orders: [Order] = []
    @State private var currentPage: Int = 0
    private let batchSize: Int = 50
    private let totalRecords: Int = 500
    private let prefetchThrottleDelay: Double = 0.5 // Throttle prefetching by 0.5 seconds

    var body: some View {
        NavigationView {
            LazyLoadingListView<[Order], OrderCell>(
                currentPage: $currentPage,
                batchSize: batchSize,
                totalRecords: totalRecords,
                prefetchThrottleDelay: prefetchThrottleDelay,
                dataProvider: databaseManager.loadOrders,
                cell: { order in
                    OrderCell(order: order)
                }
            )
            .navigationTitle("Lazy Loading Orders")
        }
    }

    private let databaseManager = DatabaseManager()
}


#Preview {
    ContentView()
}
