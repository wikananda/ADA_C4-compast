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
    var body: some Scene {
        WindowGroup {
//            CompastView()
//            PilePrototype()
            NavigationStack {
                CompastView()
            }
            .modelContainer(for: [
                CompostMethod.self,
                CompostItem.self,
                CompostMethodSteps.self,
                CompostStack.self,
                CompostFrequency.self,
                CompostContainer.self,
            ])
        }
    }
}
