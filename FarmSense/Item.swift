//
//  Item.swift
//  FarmSense
//
//  Created by Zack LeCroy on 11/20/25.
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
