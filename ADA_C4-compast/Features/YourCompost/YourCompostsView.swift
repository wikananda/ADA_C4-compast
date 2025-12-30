//
//  YourCompostsView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 15/08/25.
//

import SwiftUI
import SwiftData

enum CompostNavigation: Hashable {
    case detail(Int)
    case updateCompost(Int)
    case pilePrototype(Int)
}

struct YourCompostsView: View {
    @Query(sort: \CompostItem.creationDate, order: .reverse) private var compostItems: [CompostItem]
    @Environment(\.modelContext) private var modelContext

    // MARK: - ViewModel
    @State private var viewModel: YourCompostsViewModel

    init() {
        // ViewModel will be properly initialized in onAppear with modelContext
        _viewModel = State(initialValue: YourCompostsViewModel(
            modelContext: ModelContext(try! ModelContainer(for: CompostItem.self))
        ))
    }

    private func fetchCompost(by id: Int) -> CompostItem? {
        viewModel.fetchCompost(byId: id)
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {

            ZStack(alignment: .topLeading){
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

                    Button(action: { viewModel.presentNewCompost() }) {
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
                .padding(.horizontal)
                .zIndex(1)
                .background(.thinMaterial)

                ScrollView {
                    LazyVStack (spacing: 25) {

                        // Getting the compost item data
                        if !viewModel.hasComposts {
                            VStack(spacing: 50){
                                Image("onboarding/guys-making-compost")
                                    .resizable()
                                    .frame(maxWidth: 300, maxHeight: 300)
                                    .aspectRatio(contentMode: .fit)
                                VStack(spacing: 28) {
                                    VStack{
                                        Text("You haven't create any pile.")
                                            .font(.title2).fontWeight(.bold)
                                        Text("Get started by creating one!").font(.subheadline)
                                    }

                                    Button(action: { viewModel.presentNewCompost() }) {
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

                            }
                            .padding(.top, 75)

                        } else {
                            ForEach(viewModel.compostItems) { item in
                                CompostCard(
                                    compostItem: item,
                                    alerts: [],
                                    navigationPath: $viewModel.navigationPath
                                )
                                // when press hold, show menu
                                .contextMenu {
                                    Button(role: .destructive) {
                                        viewModel.deleteCompost(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        Color.clear
                            .frame(height: 100)
                    }
                    .padding(.top, 100)
                    .sheet(isPresented: $viewModel.showingNewCompost) {
                        NewCompostView()
                    }
                }
                .padding(.horizontal)
            }
            .navigationDestination(for: CompostItem.self) { item in
                UpdateCompostView(compostItem: item, navigationPath: $viewModel.navigationPath)
            }
            .navigationDestination(for: CompostNavigation.self) { navigation in
                switch navigation {
                case .detail(let id), .updateCompost(let id):
                    if let item = viewModel.fetchCompost(byId: id) {
                        UpdateCompostView(compostItem: item, navigationPath: $viewModel.navigationPath)
                    }
                case .pilePrototype(let id):
                    if let item = viewModel.fetchCompost(byId: id) {
                        PilePrototype(compostItem: item)
                            .navigationBarBackButtonHidden(false)
                    } else {
                        Text("Compost not found")
                    }
                }
            }
        }
        .onAppear {
            // Re-initialize with correct context and sync items
            viewModel = YourCompostsViewModel(modelContext: modelContext)
            viewModel.updateItems(compostItems)
        }
        .onChange(of: compostItems) { _, newItems in
            viewModel.updateItems(newItems)
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
        let method = CompostMethod(
            compostMethodId: 1,
            name: "Hot Compost",
            descriptionText: "Fast composting method for active gardeners",
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
//        item1.lastTurnedOver = Date().addingTimeInterval(-5 * 24 * 60 * 60)
        
        let item2 = CompostItem(
            name: "Second pile"
        )
        item2.compostMethodId = method
        item2.creationDate = Date().addingTimeInterval(-7 * 24 * 60 * 60)
//        item2.lastTurnedOver = Date().addingTimeInterval(-3 * 24 * 60 * 60)
        
        let item3 = CompostItem(name: "Third pile")
        item3.compostMethodId = method
        item3.creationDate = Date().addingTimeInterval(-5 * 24 * 60 * 60)
//        item3.lastTurnedOver = Date().addingTimeInterval(-2 * 24 * 60 * 60)

        container.mainContext.insert(item1)
        container.mainContext.insert(item2)
        container.mainContext.insert(item3)
        
        return container
    } catch {
        fatalError("Unable to create preview container: \(error.localizedDescription)")
    }
}()
