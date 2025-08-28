//
//  CompostDataSeeder.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 28/08/25.
//

import SwiftData
import SwiftUI

class CompostItemSeeder {
    static func seedInitialItems(modelContext: ModelContext) {
        // Check if data already exists
        let descriptor = FetchDescriptor<CompostItem>()
        let existingItems = try? modelContext.fetch(descriptor)
        let method = CompostMethod(
            compostMethodId: 1,
            name: "Hot Composting",
            descriptionText: "A fast composting method.",
            compostDuration1: 30,
            compostDuration2: 180,
            spaceNeeded1: 1,
            spaceNeeded2: 4
        )
        
        if existingItems?.isEmpty ?? true {
            let item1 = CompostItem(name: "First pile")
            item1.compostMethodId = method
            item1.creationDate = Date().addingTimeInterval(-14 * 24 * 60 * 60)
            let turnEvent1 = TurnEvent(date: Date().addingTimeInterval(-5 * 24 * 60 * 60))
            turnEvent1.compostItem = item1
            item1.turnEvents.append(turnEvent1)
            
            let item2 = CompostItem(name: "Second pile")
            item2.compostMethodId = method
            item2.creationDate = Date().addingTimeInterval(-7 * 24 * 60 * 60)
            let turnEvent2 = TurnEvent(date: Date().addingTimeInterval(-3 * 24 * 60 * 60))
            turnEvent2.compostItem = item2
            item2.turnEvents.append(turnEvent2)
            
            let item3 = CompostItem(name: "Third pile")
            item3.compostMethodId = method
            item3.creationDate = Date().addingTimeInterval(-5 * 24 * 60 * 60)
            let turnEvent3 = TurnEvent(date: Date().addingTimeInterval(-2 * 24 * 60 * 60))
            turnEvent3.compostItem = item3
            item3.turnEvents.append(turnEvent3)
            
            modelContext.insert(item1)
            modelContext.insert(item2)
            modelContext.insert(item3)
            
            try? modelContext.save()
        }
    }
}
