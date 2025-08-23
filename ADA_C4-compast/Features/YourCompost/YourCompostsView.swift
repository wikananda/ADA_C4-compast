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
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                LazyVStack (spacing: 25) {
                    HStack(alignment: .center, spacing: 50) {
                        
                        Image("navigation/nav-MyCompost")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 48)
                        // Placeholder button to add new item
                        
                        Spacer()
                        
                        Button(action: { showingNewCompost = true} ) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.white)
                        }
                        .background(
                            Circle().fill(Color("BrandGreen"))
                                .frame(width: 40, height: 40)
                        )
                    }.padding()
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
                                    RoundedRectangle(cornerRadius: 100)   // adjust radius as you like
                                        .stroke(Color.secondary, lineWidth: 1.5) // border color
                                        .fill(Color("BrandGreen"))
                                )
                                
                        }.padding(.top, 100)
                        
                        
                        
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
                .sheet(isPresented: $showingNewCompost) {
                    NewCompostView()
                }
            }
        }
        .navigationDestination(for: CompostItem.self) { item in
            UpdateCompostView(compostItem: item)
        }
    }
}

#Preview {
    YourCompostsView()
}
