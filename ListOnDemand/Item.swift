//
//  Item.swift
//  ListOnDemand
//
//  Created by Marcello Morellato on 01/11/23.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
