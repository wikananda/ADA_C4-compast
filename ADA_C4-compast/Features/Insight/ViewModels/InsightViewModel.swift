//
//  InsightViewModel.swift
//  ADA_C4-compast
//
//  Insight Module - ViewModel
//

import SwiftUI
import SwiftData

/// ViewModel for the InsightView.
/// Manages statistics and insights about composting activity.
@Observable
final class InsightViewModel {

    // MARK: - Dependencies

    private let compostService: CompostServiceProtocol
    private let modelContext: ModelContext

    // MARK: - State

    /// All compost items
    var compostItems: [CompostItem] = []

    // MARK: - Initialization

    init(
        compostService: CompostServiceProtocol = CompostService.shared,
        modelContext: ModelContext
    ) {
        self.compostService = compostService
        self.modelContext = modelContext
    }

    // MARK: - Computed Properties

    /// Total number of composts created
    var totalComposts: Int {
        compostItems.count
    }

    /// Number of active composts
    var activeComposts: Int {
        compostItems.filter { $0.harvestedAt == nil }.count
    }

    /// Number of harvested composts
    var harvestedComposts: Int {
        compostItems.filter { $0.harvestedAt != nil }.count
    }

    /// Total turns across all composts
    var totalTurns: Int {
        compostItems.reduce(0) { $0 + $1.turnCount }
    }

    /// Total green materials added
    var totalGreenMaterials: Int {
        compostItems.reduce(0) { $0 + $1.totalGreen }
    }

    /// Total brown materials added
    var totalBrownMaterials: Int {
        compostItems.reduce(0) { $0 + $1.totalBrown }
    }

    /// Total materials added
    var totalMaterials: Int {
        totalGreenMaterials + totalBrownMaterials
    }

    /// Estimated waste rescued in kg (rough estimate: 0.5kg per material unit)
    var wasteRescuedKg: Double {
        Double(totalMaterials) * 0.5
    }

    /// Average age of active composts in days
    var averageCompostAge: Int {
        let activeItems = compostItems.filter { $0.harvestedAt == nil }
        guard !activeItems.isEmpty else { return 0 }

        let totalDays = activeItems.reduce(0) { total, item in
            let days = Calendar.current.dateComponents([.day], from: item.creationDate, to: Date()).day ?? 0
            return total + days
        }

        return totalDays / activeItems.count
    }

    /// Composting streak (consecutive days with activity)
    var compostingStreak: Int {
        // Simplified: count unique days with turn events in the last 30 days
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recentTurns = compostItems.flatMap { $0.turnEvents }
            .filter { $0.date >= thirtyDaysAgo }
            .map { Calendar.current.startOfDay(for: $0.date) }

        return Set(recentTurns).count
    }

    // MARK: - Actions

    /// Updates compost items from @Query
    func updateItems(_ items: [CompostItem]) {
        compostItems = items
    }

    /// Formats weight for display
    func formattedWeight(_ kg: Double) -> String {
        if kg >= 1000 {
            return String(format: "%.1f tons", kg / 1000)
        } else if kg >= 1 {
            return String(format: "%.1f kg", kg)
        } else {
            return String(format: "%.0f g", kg * 1000)
        }
    }

    /// Share statistics
    func shareStats() -> String {
        """
        My Composting Stats from Compast:
        - Total Composts: \(totalComposts)
        - Materials Added: \(totalMaterials)
        - Waste Rescued: \(formattedWeight(wasteRescuedKg))
        - Total Turns: \(totalTurns)

        Start composting with Compast!
        """
    }
}
