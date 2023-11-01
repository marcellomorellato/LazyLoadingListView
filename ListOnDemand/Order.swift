//
//  Item.swift
//  ListOnDemand
//
//  Created by Marcello Morellato on 01/11/23.
//

import Foundation
import SwiftData

struct Order: Identifiable {
    let lastUpdate: Date
    let Identifier: String
    let descr: String
    var id: String { return Identifier }
}
