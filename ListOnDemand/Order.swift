//
//  Item.swift
//  ListOnDemand
//
//  Created by Marcello Morellato on 01/11/23.
//

import Foundation
import SwiftData

class Order: Identifiable, Equatable {
    let lastUpdate: Date
    let creationDate: Date
    let Identifier: String
    let descr: String
    let code: String

    var id: String { return Identifier }

    init(lastUpdate: Date, creationDate: Date, Identifier: String, descr: String, code: String) {
        self.lastUpdate = lastUpdate
        self.creationDate = creationDate
        self.Identifier = Identifier
        self.descr = descr
        self.code = code
    }

    static func == (lhs: Order, rhs: Order) -> Bool {
        return lhs.id == rhs.id
    }
}

