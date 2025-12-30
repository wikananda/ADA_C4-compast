//
//  NewCompostViewModel.swift
//  ADA_C4-compast
//
//  NewCompost Module - ViewModel
//

import SwiftUI
import SwiftData

/// ViewModel for the NewCompostView.
/// Manages the new compost creation wizard flow.
@Observable
final class NewCompostViewModel {

    // MARK: - Dependencies

    private let compostService: CompostServiceProtocol
    private let modelContext: ModelContext

    // MARK: - Wizard State

    /// Current step in the wizard (1-based)
    var currentStep: Int = 1

    /// Total number of steps
    let totalSteps: Int = 2

    /// Compost name entered by user
    var name: String?

    /// Selected composting method
    var selectedMethod: Option?

    /// Selected space option
    var selectedSpace: Option?

    /// Selected container option
    var selectedContainer: Option?

    // MARK: - Initialization

    init(
        compostService: CompostServiceProtocol = CompostService.shared,
        modelContext: ModelContext
    ) {
        self.compostService = compostService
        self.modelContext = modelContext
    }

    // MARK: - Computed Properties

    /// Whether the name is valid (not empty after trimming)
    var isNameValid: Bool {
        guard let name = name else { return false }
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Whether the current step is the last step
    var isLastStep: Bool {
        currentStep == totalSteps
    }

    /// Whether the user can proceed to the next step
    var canProceed: Bool {
        switch currentStep {
        case 1:
            return isNameValid
        default:
            return true
        }
    }

    /// Button title based on current step
    var buttonTitle: String {
        isLastStep ? "Let's Go" : "Next"
    }

    /// Title for current step
    var stepTitle: String {
        switch currentStep {
        case 1:
            return "New Compost"
        case 2:
            return ""
        default:
            return ""
        }
    }

    // MARK: - Actions

    /// Handles the main button action
    /// - Returns: true if the wizard should be dismissed
    func handleButtonAction() -> Bool {
        if currentStep < totalSteps {
            currentStep += 1
            return false
        }

        guard isNameValid else { return false }
        return addNewCompost()
    }

    /// Goes back to the previous step
    /// - Returns: true if wizard should be dismissed
    func goBack() -> Bool {
        if currentStep > 1 {
            currentStep -= 1
            return false
        }
        return true // Dismiss on first step
    }

    /// Creates a new compost item
    /// - Returns: true if creation was successful
    func addNewCompost() -> Bool {
        guard let writtenName = name else { return false }

        // Fetch the default method (Hot Compost, ID 1)
        guard let method = compostService.fetchMethod(byId: 1, in: modelContext) else {
            print("❌ No predefined compost method found")
            return false
        }

        do {
            let _ = try compostService.createCompost(
                name: writtenName,
                method: method,
                in: modelContext
            )
            print("✅ Successfully created new compost: \(writtenName)")
            return true
        } catch {
            print("❌ Failed to save: \(error)")
            return false
        }
    }

    /// Resets the wizard to initial state
    func reset() {
        currentStep = 1
        name = nil
        selectedMethod = nil
        selectedSpace = nil
        selectedContainer = nil
    }
}
