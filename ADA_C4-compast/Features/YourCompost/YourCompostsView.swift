//
//  YourCompostsView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 15/08/25.
//

import SwiftUI
import SwiftData

struct YourCompostsView: View {
    @Query(sort: \CompostItem.creationDate, order: .reverse) private var compostItems: [CompostItem]
    @State private var showingNewCompost: Bool = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack (spacing: 25) {
                    HStack(spacing: 50) {
                        // Placeholder button to add new item
                        Button(action: { showingNewCompost = true} ) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }
                    // Getting the compost item data
                    if compostItems.isEmpty {
                        Text("No composts yet. Tap + to add one.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(compostItems) { item in
                            CompostCard(
                                compostItem: item,
                                alerts: []
                            )
                            // when press hold, show menu
                            .contextMenu {
                                Button(role: .destructive) {
                                    modelContext.delete(item)
                                    try? modelContext.save()
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showingNewCompost) {
                    NewCompostView()
                }
            }
        }
    }
}

#Preview {
    YourCompostsView()
}
