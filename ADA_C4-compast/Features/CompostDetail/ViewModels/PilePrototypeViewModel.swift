//
//  PilePrototypeViewModel.swift
//  ADA_C4-compast
//
//  CompostDetail Module - Pile ViewModel
//

import SwiftUI
import SwiftData

/// ViewModel for the PilePrototype view.
/// Manages pile bands, material ratios, and balance recommendations.
@Observable
final class PilePrototypeViewModel {

    // MARK: - Dependencies

    private let compostService: CompostServiceProtocol
    private let modelContext: ModelContext

    // MARK: - Compost Item Reference

    private(set) var compostItem: CompostItem

    // MARK: - UI State

    /// Whether the info sheet is visible
    var isInfoVisible: Bool = false

    /// Drop zone area for drag and drop
    var dropZoneArea: CGRect = .zero

    // MARK: - Pile State

    /// Current pile bands
    var bands: [PileBand] = []

    /// Green material count
    private(set) var greenAmount: Int = 0

    /// Brown material count
    private(set) var brownAmount: Int = 0

    /// Initial stack count when view was loaded
    private var initialStackCount: Int = 0

    /// Current brown/total ratio
    private(set) var ratio: CGFloat = 0.0

    /// Balance recommendation
    private(set) var recommendation: BalanceRecommendation

    // MARK: - Initialization

    init(
        compostItem: CompostItem,
        compostService: CompostServiceProtocol = CompostService.shared,
        modelContext: ModelContext
    ) {
        self.compostItem = compostItem
        self.compostService = compostService
        self.modelContext = modelContext
        self.recommendation = computeBalanceRecommendation(browns: 0, greens: 0)
    }

    // MARK: - Computed Properties

    /// Whether the pile has any materials
    var hasAnyMaterial: Bool {
        !bands.isEmpty
    }

    /// Simplified ratio for display (e.g., "1:3")
    var simplifiedRatio: (Int, Int) {
        simplifyRatio(greenAmount, brownAmount)
    }

    /// Total material count
    var totalMaterials: Int {
        greenAmount + brownAmount
    }

    // MARK: - Actions

    /// Loads existing compost stacks from the data model
    func loadExistingStacks() {
        let stacks = compostItem.compostStacks.sorted { $0.createdAt < $1.createdAt }

        bands = stacks.enumerated().map { idx, stack in
            PileBand(
                materialType: stack.greenAmount == 1 ? "green" : "brown",
                isShredded: stack.isShredded,
                order: idx
            )
        }

        initialStackCount = bands.count
        greenAmount = stacks.reduce(0) { $0 + $1.greenAmount }
        brownAmount = stacks.reduce(0) { $0 + $1.brownAmount }
        refreshBalance()
    }

    /// Adds a material band to the pile
    func addMaterial(_ type: MaterialType) {
        let pileBand = PileBand(
            materialType: type.rawValue,
            isShredded: false,
            order: bands.count
        )
        bands.append(pileBand)

        if type == .green {
            greenAmount += 1
        } else {
            brownAmount += 1
        }

        refreshBalance()
        recomputeETA()
    }

    /// Removes the last band from the pile
    func removeLastBand() {
        guard let last = bands.popLast() else { return }

        if last.materialType == "green" {
            greenAmount = max(0, greenAmount - 1)
        } else {
            brownAmount = max(0, brownAmount - 1)
        }

        refreshBalance()
        recomputeETA()
    }

    /// Resets all bands
    func resetPile() {
        bands.removeAll()
        brownAmount = 0
        greenAmount = 0
        refreshBalance()
    }

    /// Toggles shredded state for a band at index
    func toggleShredded(at index: Int) {
        guard index < bands.count else { return }
        bands[index].isShredded.toggle()
        recomputeETA()
    }

    /// Saves new compost stacks to the data model
    func saveCompostStacks() {
        guard bands.count > initialStackCount else { return }

        for band in bands[initialStackCount...] {
            let stack = CompostStack(
                brownAmount: band.materialType == "brown" ? 1 : 0,
                greenAmount: band.materialType == "green" ? 1 : 0,
                createdAt: Date(),
                isShredded: band.isShredded
            )
            stack.compostItemId = compostItem
            modelContext.insert(stack)
        }

        try? modelContext.save()
    }

    /// Shows the info sheet
    func showInfo() {
        isInfoVisible = true
    }

    // MARK: - Private Helpers

    private func refreshBalance() {
        let total = max(greenAmount + brownAmount, 1)
        let brownShare = CGFloat(brownAmount) / CGFloat(total)
        ratio = brownShare
        recommendation = computeBalanceRecommendation(browns: brownAmount, greens: greenAmount)
    }

    private func recomputeETA() {
        compostItem.recomputeAndStoreETA(in: modelContext)
    }
}

// gcd and simplifyRatio functions are defined in PilePrototype.swift
