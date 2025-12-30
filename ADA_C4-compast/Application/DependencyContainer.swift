//
//  DependencyContainer.swift
//  ADA_C4-compast
//
//  MVVM Architecture - Dependency Injection Container
//

import SwiftUI
import SwiftData

/// Central dependency injection container for the app.
/// Provides factory methods for creating ViewModels with their dependencies.
@Observable
final class DependencyContainer {

    // MARK: - Singleton

    static let shared = DependencyContainer()

    // MARK: - Services

    let compostService: CompostServiceProtocol
    let taskStore: CompostTaskStore

    // MARK: - Initialization

    private init(
        compostService: CompostServiceProtocol = CompostService.shared,
        taskStore: CompostTaskStore = CompostTaskStore()
    ) {
        self.compostService = compostService
        self.taskStore = taskStore
    }

    /// Creates a container for testing with mock services
    static func forTesting(
        compostService: CompostServiceProtocol,
        taskStore: CompostTaskStore = CompostTaskStore()
    ) -> DependencyContainer {
        DependencyContainer(compostService: compostService, taskStore: taskStore)
    }

    // MARK: - ViewModel Factory Methods

    /// Creates YourCompostsViewModel
    func makeYourCompostsViewModel(modelContext: ModelContext) -> YourCompostsViewModel {
        YourCompostsViewModel(
            compostService: compostService,
            modelContext: modelContext
        )
    }

    /// Creates UpdateCompostViewModel for a specific compost item
    func makeUpdateCompostViewModel(
        compostItem: CompostItem,
        modelContext: ModelContext
    ) -> UpdateCompostViewModel {
        UpdateCompostViewModel(
            compostItem: compostItem,
            compostService: compostService,
            modelContext: modelContext
        )
    }

    /// Creates PilePrototypeViewModel for a specific compost item
    func makePilePrototypeViewModel(
        compostItem: CompostItem,
        modelContext: ModelContext
    ) -> PilePrototypeViewModel {
        PilePrototypeViewModel(
            compostItem: compostItem,
            compostService: compostService,
            modelContext: modelContext
        )
    }

    /// Creates NewCompostViewModel
    func makeNewCompostViewModel(modelContext: ModelContext) -> NewCompostViewModel {
        NewCompostViewModel(
            compostService: compostService,
            modelContext: modelContext
        )
    }

    /// Creates ToDoViewModel
    func makeToDoViewModel(modelContext: ModelContext) -> ToDoViewModel {
        ToDoViewModel(
            compostService: compostService,
//            taskStore: taskStore,
            modelContext: modelContext
        )
    }

    /// Creates SettingsViewModel
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel()
    }

    /// Creates HelpViewModel
    func makeHelpViewModel() -> HelpViewModel {
        HelpViewModel()
    }

    /// Creates InsightViewModel
    func makeInsightViewModel(modelContext: ModelContext) -> InsightViewModel {
        InsightViewModel(
            compostService: compostService,
            modelContext: modelContext
        )
    }
}

// MARK: - Environment Key

private struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer.shared
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

// MARK: - View Extension for Easy Access

extension View {
    /// Injects the dependency container into the environment
    func withDependencies(_ container: DependencyContainer = .shared) -> some View {
        environment(\.dependencies, container)
    }
}
