//
//  CompostService.swift
//  ADA_C4-compast
//
//  MVVM Architecture - Service Implementation
//

import Foundation
import SwiftData

/// Concrete implementation of CompostServiceProtocol.
/// Handles all SwiftData operations for compost-related entities.
final class CompostService: CompostServiceProtocol {

    // MARK: - Singleton

    static let shared = CompostService()

    private init() {}

    // MARK: - CompostItem Operations

    func fetchAllComposts(in context: ModelContext) throws -> [CompostItem] {
        let descriptor = FetchDescriptor<CompostItem>(
            sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func fetchActiveComposts(in context: ModelContext) throws -> [CompostItem] {
        let descriptor = FetchDescriptor<CompostItem>(
            predicate: #Predicate { $0.harvestedAt == nil },
            sortBy: [SortDescriptor(\.creationDate, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func fetchHarvestedComposts(in context: ModelContext) throws -> [CompostItem] {
        let descriptor = FetchDescriptor<CompostItem>(
            predicate: #Predicate { $0.harvestedAt != nil },
            sortBy: [SortDescriptor(\.harvestedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func fetchCompost(byId id: Int, in context: ModelContext) -> CompostItem? {
        let descriptor = FetchDescriptor<CompostItem>(
            predicate: #Predicate { $0.compostItemId == id }
        )
        return try? context.fetch(descriptor).first
    }

    func createCompost(
        name: String,
        method: CompostMethod,
        in context: ModelContext
    ) throws -> CompostItem {
        let item = CompostItem(name: name)
        item.compostMethodId = method
        context.insert(item)
        try context.save()
        return item
    }

    func renameCompost(_ item: CompostItem, to newName: String, in context: ModelContext) throws {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        item.name = trimmed
        try context.save()
    }

    func harvestCompost(_ item: CompostItem, in context: ModelContext) throws {
        item.harvestedAt = Date()
        try context.save()
    }

    func deleteCompost(_ item: CompostItem, in context: ModelContext) throws {
        context.delete(item)
        try context.save()
    }

    func turnCompost(_ item: CompostItem, in context: ModelContext) throws {
        item.turnNow(in: context)
    }

    // MARK: - CompostMethod Operations

    func fetchAllMethods(in context: ModelContext) throws -> [CompostMethod] {
        let descriptor = FetchDescriptor<CompostMethod>(
            sortBy: [SortDescriptor(\.compostMethodId)]
        )
        return try context.fetch(descriptor)
    }

    func fetchMethod(byId id: Int, in context: ModelContext) -> CompostMethod? {
        let descriptor = FetchDescriptor<CompostMethod>(
            predicate: #Predicate { $0.compostMethodId == id }
        )
        return try? context.fetch(descriptor).first
    }

    // MARK: - PileBand Operations

    func savePileBands(_ bands: [PileBand], for item: CompostItem, in context: ModelContext) throws {
        // Clear existing bands first
        try clearPileBands(for: item, in: context)

        // Add new bands
        for band in bands {
            band.compostItemId = item
            item.pileBands.append(band)
        }

        try context.save()
    }

    func clearPileBands(for item: CompostItem, in context: ModelContext) throws {
        for band in item.pileBands {
            context.delete(band)
        }
        item.pileBands.removeAll()
        try context.save()
    }

    // MARK: - CompostStack Operations

    func addCompostStack(
        brownAmount: Int,
        greenAmount: Int,
        isShredded: Bool,
        to item: CompostItem,
        in context: ModelContext
    ) throws {
        let stack = CompostStack(
            brownAmount: brownAmount,
            greenAmount: greenAmount,
            createdAt: Date(),
            isShredded: isShredded
        )
        stack.compostItemId = item
        item.compostStacks.append(stack)
        try context.save()
    }

    // MARK: - Vitals Operations

    func updateVitals(
        for item: CompostItem,
        temperature: String,
        moisture: String,
        in context: ModelContext
    ) throws {
        item.temperatureCategory = temperature
        item.moistureCategory = moisture
        item.lastLogged = Date()

        // Update health status based on vitals
        item.isHealthy = isHealthyVitals(temperature: temperature, moisture: moisture)

        try context.save()
    }

    // MARK: - Private Helpers

    private func isHealthyVitals(temperature: String, moisture: String) -> Bool {
        let healthyTemps = ["Warm", "Hot"]
        let healthyMoisture = ["Moist"]
        return healthyTemps.contains(temperature) && healthyMoisture.contains(moisture)
    }
}
