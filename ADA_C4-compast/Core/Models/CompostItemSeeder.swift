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
            // 1. FAST compost - ready to harvest in <30 days under IDEAL conditions
            // (hot composting with perfect ratio, moisture, temp, and frequent turning)
            let item1 = CompostItem(name: "Hot Pile Express")
            item1.compostMethodId = method
            item1.creationDate = Date().addingTimeInterval(-25 * 24 * 60 * 60)  // 25 days old
            item1.lastLogged = Date().addingTimeInterval(-1 * 24 * 60 * 60)  // Logged yesterday
            item1.temperatureCategory = "Hot"  // Ideal for fast decomposition
            item1.moistureCategory = "Moist"   // Perfect moisture
            item1.isHealthy = true
            // Frequent turning (every 3-5 days for hot composting)
            let turn1a = TurnEvent(date: Date().addingTimeInterval(-20 * 24 * 60 * 60))
            let turn1b = TurnEvent(date: Date().addingTimeInterval(-15 * 24 * 60 * 60))
            let turn1c = TurnEvent(date: Date().addingTimeInterval(-10 * 24 * 60 * 60))
            let turn1d = TurnEvent(date: Date().addingTimeInterval(-5 * 24 * 60 * 60))
            turn1a.compostItem = item1
            turn1b.compostItem = item1
            turn1c.compostItem = item1
            turn1d.compostItem = item1
            item1.turnEvents.append(contentsOf: [turn1a, turn1b, turn1c, turn1d])
            
            // 2. Normal compost - ready to harvest (past max duration)
            let item2 = CompostItem(name: "Garden Pile")
            item2.compostMethodId = method
            item2.creationDate = Date().addingTimeInterval(-185 * 24 * 60 * 60)  // 185 days old
            item2.lastLogged = Date().addingTimeInterval(-3 * 24 * 60 * 60)  // Logged 3 days ago
            item2.temperatureCategory = "Cold"
            item2.moistureCategory = "Dry"
            item2.isHealthy = true
            // Occasional turning (slower method)
            let turn2a = TurnEvent(date: Date().addingTimeInterval(-150 * 24 * 60 * 60))
            let turn2b = TurnEvent(date: Date().addingTimeInterval(-100 * 24 * 60 * 60))
            let turn2c = TurnEvent(date: Date().addingTimeInterval(-50 * 24 * 60 * 60))
            turn2a.compostItem = item2
            turn2b.compostItem = item2
            turn2c.compostItem = item2
            item2.turnEvents.append(contentsOf: [turn2a, turn2b, turn2c])
            
            // 3. Compost needing log update (to demonstrate update log feature)
            let item3 = CompostItem(name: "Backyard Pile")
            item3.compostMethodId = method
            item3.creationDate = Date().addingTimeInterval(-40 * 24 * 60 * 60)  // 40 days old
            item3.lastLogged = Date().addingTimeInterval(-10 * 24 * 60 * 60)  // Last logged 10 days ago!
            item3.temperatureCategory = "Warm"
            item3.moistureCategory = "Moist"
            item3.isHealthy = true
            let turn3 = TurnEvent(date: Date().addingTimeInterval(-15 * 24 * 60 * 60))
            turn3.compostItem = item3
            item3.turnEvents.append(turn3)
            
            modelContext.insert(item1)
            modelContext.insert(item2)
            modelContext.insert(item3)
            
            try? modelContext.save()
        }
    }
}
