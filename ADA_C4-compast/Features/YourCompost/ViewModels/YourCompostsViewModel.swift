//
//  YourCompostsViewModel.swift
//  ADA_C4-compast
//
//  YourCompost Module - ViewModel
//

import SwiftUI
import SwiftData

/// ViewModel for the YourCompostsView.
/// Manages compost list display and navigation.
@Observable
final class YourCompostsViewModel {

    // MARK: - Dependencies

    private let compostService: CompostServiceProtocol
    private let modelContext: ModelContext

    // MARK: - State

    /// All compost items (synced from @Query)
    var compostItems: [CompostItem] = []

    /// Whether to show the new compost sheet
    var showingNewCompost: Bool = false

    /// Navigation path for detail navigation
    var navigationPath = NavigationPath()

    // MARK: - Initialization

    init(
        compostService: CompostServiceProtocol = CompostService.shared,
        modelContext: ModelContext
    ) {
        self.compostService = compostService
        self.modelContext = modelContext
    }

    // MARK: - Computed Properties

    /// Whether there are any composts
    var hasComposts: Bool {
        !compostItems.isEmpty
    }

    /// Number of active (non-harvested) composts
    var activeCompostCount: Int {
        compostItems.filter { $0.harvestedAt == nil }.count
    }

    /// Number of harvested composts
    var harvestedCompostCount: Int {
        compostItems.filter { $0.harvestedAt != nil }.count
    }

    /// Active composts only
    var activeComposts: [CompostItem] {
        compostItems.filter { $0.harvestedAt == nil }
    }

    /// Harvested composts only
    var harvestedComposts: [CompostItem] {
        compostItems.filter { $0.harvestedAt != nil }
    }

    // MARK: - Actions

    /// Updates items from @Query results
    func updateItems(_ items: [CompostItem]) {
        compostItems = items
    }

    /// Shows the new compost creation sheet
    func presentNewCompost() {
        showingNewCompost = true
    }

    /// Dismisses the new compost sheet
    func dismissNewCompost() {
        showingNewCompost = false
    }

    /// Navigates to compost detail
    func navigateToDetail(compostId: Int) {
        navigationPath.append(CompostNavigation.detail(compostId))
    }

    /// Navigates to pile prototype
    func navigateToPile(compostId: Int) {
        navigationPath.append(CompostNavigation.pilePrototype(compostId))
    }

    /// Fetches a compost item by ID
    func fetchCompost(byId id: Int) -> CompostItem? {
        compostItems.first { $0.compostItemId == id }
    }

    /// Deletes a compost item
    func deleteCompost(_ item: CompostItem) {
        do {
            try compostService.deleteCompost(item, in: modelContext)
        } catch {
            print("❌ Failed to delete compost: \(error)")
        }
    }

    /// Pops the navigation stack
    func popNavigation() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}

// CompostNavigation enum is defined in YourCompostsView.swift
