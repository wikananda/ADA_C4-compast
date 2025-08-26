//
//  ADA_C4_compastApp.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 12/08/25.
//

import SwiftUI
import SwiftData

@main
struct ADA_C4_compastApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CompostMethod.self,
            CompostItem.self,
            CompostMethodSteps.self,
            CompostStack.self,
            CompostFrequency.self,
            CompostContainer.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Seed initial data here
            let context = container.mainContext
            CompostMethodSeeder.seedInitialData(modelContext: context)
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
//            CompastView()
//            PilePrototype()
            NavigationStack {
                CompastView()
            }
            .modelContainer(sharedModelContainer)
        }
    }
}
