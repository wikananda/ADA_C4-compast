//
//  UpdateCompostViewModel.swift
//  ADA_C4-compast
//
//  CompostDetail Module - ViewModel
//

import SwiftUI
import SwiftData

/// ViewModel for the UpdateCompostView.
/// Manages compost item state and business logic.
@Observable
final class UpdateCompostViewModel {

    // MARK: - Dependencies

    private let compostService: CompostServiceProtocol
    private let modelContext: ModelContext

    // MARK: - Compost Item Reference

    private(set) var compostItem: CompostItem

    // MARK: - UI State

    /// Sheet presentation state
    var vitalsSheetPresented: Bool = false

    /// Rename alert state
    var showRenameAlert: Bool = false
    var renameText: String = ""

    /// Delete confirmation state
    var showDeleteConfirm: Bool = false

    /// General alert state
    var showAlert: Bool = false
    var alertTitle: String = ""
    var alertMessage: String = ""

    /// Save alert state
    var showSaveAlert: Bool = false

    // MARK: - Initialization

    init(
        compostItem: CompostItem,
        compostService: CompostServiceProtocol = CompostService.shared,
        modelContext: ModelContext
    ) {
        self.compostItem = compostItem
        self.compostService = compostService
        self.modelContext = modelContext
    }

    // MARK: - Computed Properties

    /// Compost name for display
    var compostName: String {
        compostItem.name
    }

    /// Whether compost is healthy
    var isHealthy: Bool {
        compostItem.isHealthy
    }

    /// Creation date
    var createdAt: Date {
        compostItem.creationDate
    }

    /// Age of compost in days
    var ageDays: Int {
        Calendar.current.dateComponents([.day], from: compostItem.creationDate, to: Date()).day ?? 0
    }

    /// Text describing when pile was last turned
    var turnedOverText: String {
        if let days = compostItem.daysSinceLastTurn {
            return days == 0 ? "Today" : "\(days) days ago"
        } else {
            return "Never"
        }
    }

    /// Whether the compost log was recently updated (within 24 hours)
    var isRecentlyUpdated: Bool {
        compostItem.lastLogged > Date().addingTimeInterval(-60 * 60 * 24)
    }

    /// Chip type based on compost status
    var chipType: StatusChip.ChipType {
        switch compostItem.compostStatus {
        case .healthy:    return .healthy
        case .needAction: return .needAction
        case .harvested:  return .harvested
        }
    }

    /// Whether the pile has no materials yet
    var isPileEmpty: Bool {
        compostItem.compostStacks.isEmpty
    }

    /// Whether the pile has been turned today
    var hasBeenTurnedToday: Bool {
        guard let lastTurnedDate = compostItem.lastTurnedOver else { return false }
        return Calendar.current.isDate(Date(), inSameDayAs: lastTurnedDate)
    }

    /// Whether the compost has been harvested
    var isHarvested: Bool {
        compostItem.harvestedAt != nil
    }

    /// Compost item ID for navigation
    var compostItemId: Int {
        compostItem.compostItemId
    }

    /// Last logged date formatted
    var lastLoggedFormatted: String {
        compostItem.lastLogged.ddMMyyyy()
    }

    /// Estimated harvest remaining text
    var daysRemainingText: String {
        guard let targetDate = compostItem.estimatedHarvestAt else { return "—" }
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: targetDate).day ?? 0

        if daysRemaining > 0 {
            return "\(daysRemaining) days"
        } else if daysRemaining <= 0 {
            return "Ready"
        } else {
            return "—"
        }
    }

    /// Get compost advice
    var adviceItems: [CompostProblem] {
        CompostKnowledge.advice(for: compostItem)
    }

    /// Get temperature issue if any
    var temperatureIssue: CompostProblem? {
        adviceItems.first { $0.category == .temperature }
    }

    /// Get moisture issue if any
    var moistureIssue: CompostProblem? {
        adviceItems.first { $0.category == .moisture }
    }

    // MARK: - Actions

    /// Marks the compost as harvested
    func markAsHarvested() {
        compostItem.harvestedAt = Date()
        save()
    }

    /// Prepares rename alert
    func prepareRename() {
        renameText = compostItem.name
        showRenameAlert = true
    }

    /// Renames the compost
    func renameCompost() {
        let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        compostItem.name = trimmed
        save()
    }

    /// Deletes the compost
    /// - Returns: true if deletion was successful
    func deleteCompost() -> Bool {
        do {
            try compostService.deleteCompost(compostItem, in: modelContext)
            return true
        } catch {
            showAlertWith(title: "Error", message: "Failed to delete compost.")
            return false
        }
    }

    /// Mixes (turns) the compost pile
    func mixCompost() {
        guard !isPileEmpty else {
            showAlertWith(
                title: "Pile is still empty",
                message: "Fill your pile first before you can start mixing it."
            )
            return
        }

        guard !hasBeenTurnedToday else {
            showAlertWith(
                title: "Pile already mixed",
                message: "You just need to mix the pile once a day."
            )
            return
        }

        compostItem.turnNow(in: modelContext)
        save()

        showAlertWith(
            title: "You mixed the compost!",
            message: "Very great! Keep up the good work!"
        )
    }

    /// Shows the vitals update sheet
    func showVitalsSheet() {
        vitalsSheetPresented = true
    }

    /// Shows save confirmation and triggers callback
    func confirmSave() {
        showSaveAlert = true
    }

    /// Prepares delete confirmation
    func prepareDelete() {
        showDeleteConfirm = true
    }

    // MARK: - Private Helpers

    private func save() {
        try? modelContext.save()
    }

    private func showAlertWith(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
