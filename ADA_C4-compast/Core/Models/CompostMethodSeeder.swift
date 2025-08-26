//
//  CompostMethodSeeder.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 26/08/25.
//

import SwiftData
import SwiftUI

class CompostMethodSeeder {
    static func seedInitialData(modelContext: ModelContext) {
        // Check if data already exists
        let descriptor = FetchDescriptor<CompostMethod>()
        let existingMethods = try? modelContext.fetch(descriptor)
        
        if existingMethods?.isEmpty ?? true {
            // Create your predefined compost method
            let defaultMethod = CompostMethod(
                compostMethodId: 1,
                name: "Hot Composting",
                descriptionText: "A fast composting method.",
                compostDuration1: 30,
                compostDuration2: 180,
                spaceNeeded1: 1,
                spaceNeeded2: 4
            )
            
            modelContext.insert(defaultMethod)
            
            try? modelContext.save()
        }
    }
}
