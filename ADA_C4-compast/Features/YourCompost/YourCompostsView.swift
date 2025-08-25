//
//  YourCompostsView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 15/08/25.
//

import SwiftUI
import SwiftData

enum CompostNavigation: Hashable {
    case updateCompost(Int)
    case pilePrototype(Int)
}

struct YourCompostsView: View {
    @Query(sort: \CompostItem.creationDate, order: .reverse) private var compostItems: [CompostItem]
    @State private var showingNewCompost: Bool = false
    @Environment(\.modelContext) private var modelContext
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVStack (spacing: 25) {
                    HStack(alignment: .center, spacing: 0) {
                        HStack (spacing: 10) {
                            Image("compost/logo-dark-green")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 32)
                            Text("My Compost")
                                .font(.custom("KronaOne-Regular", size: 20))
                                .foregroundStyle(Color("BrandGreenDark"))
                        }
                        // Placeholder button to add new item
                        
                        Spacer()
                        
                        Button(action: { showingNewCompost = true} ) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .bold(true)
                                .foregroundStyle(.white)
                        }
                        .background(
                            Circle().fill(Color("BrandGreenDark"))
                                .frame(width: 32, height: 32)
                        )
                    }
                    .padding()
                    // Getting the compost item data
                    if compostItems.isEmpty {
                        
                        VStack(spacing: 48){
                            Image("compost/my-compost")
                                .frame(width: .infinity)
                                .aspectRatio(contentMode: .fit)
                            
                            
                            VStack{
                                
                                Text("You haven't create any pile.")
                                    .font(.title2).fontWeight(.bold)
                                
                                Text("Get started by creating one!").font(.subheadline)
                            }
                            
                            Button(action: { showingNewCompost = true} ) {
                                HStack(spacing: 16){
                                    Image(systemName: "plus")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    Text("Create Compost Pile")
                                        .font(.headline)
                                }.foregroundStyle(.white)
                                
                            }
                            .frame(width: 280)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 20)
                            .background(
                                    RoundedRectangle(cornerRadius: 100)
                                        .stroke(Color.secondary, lineWidth: 1.5)
                                        .fill(Color("BrandGreenDark"))
                                )
                                
                        }
                        .padding(.top, 100)
                        
                    } else {
                        ForEach(compostItems) { item in
                            CompostCard(
                                compostItem: item,
                                alerts: [],
                                navigationPath: $navigationPath
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
                    Color.clear
                        .frame(height: 100)
                }
                .padding(.horizontal)
                .sheet(isPresented: $showingNewCompost) {
                    NewCompostView()
                }
            }
        }
        .navigationDestination(for: CompostNavigation.self) { nav in
            switch nav {
            case .updateCompost(let itemId):
                if let item = compostItems.first(where: {$0.compostItemId == itemId}) {
                    UpdateCompostView(compostItem: item, navigationPath: $navigationPath)
                } else {
                    Text("Compost Item not found")
                }
            case .pilePrototype(let itemId):
                if let item = compostItems.first(where: {$0.compostItemId == itemId}) {
                    PilePrototype(compostItem: item)
                } else {
                    Text("Compost item not found")
                }
            }
        }
    }
}

#Preview {
    YourCompostsView()
//        .modelContainer(previewContainer)
}

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: CompostItem.self, CompostMethod.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        // Creating dummy data
        let method = CompostMethod(
            compostMethodId: 1,
            name: "Hot Compost",
            descriptionText: "Fast composting method",
            compostDuration1: 30,
            compostDuration2: 180,
            spaceNeeded1: 1,
            spaceNeeded2: 4
        )

        let item1 = CompostItem(
            name: "First pile"
        )
        item1.compostMethodId = method
        item1.creationDate = Date().addingTimeInterval(-14 * 24 * 60 * 60)
        item1.lastTurnedOver = Date().addingTimeInterval(-5 * 24 * 60 * 60)
        
        let item2 = CompostItem(
            name: "Second pile"
        )
        item2.compostMethodId = method
        item2.creationDate = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        item2.lastTurnedOver = Date().addingTimeInterval(-3 * 24 * 60 * 60)
        
        let item3 = CompostItem(name: "Third pile")
        item3.compostMethodId = method
        item3.creationDate = Date().addingTimeInterval(-5 * 24 * 60 * 60)
        item3.lastTurnedOver = Date().addingTimeInterval(-2 * 24 * 60 * 60)
        
        container.mainContext.insert(method)
        container.mainContext.insert(item1)
        container.mainContext.insert(item2)
        container.mainContext.insert(item3)
        
        return container
    } catch {
        fatalError("Unable to create preview container: \(error.localizedDescription)")
    }
}()
