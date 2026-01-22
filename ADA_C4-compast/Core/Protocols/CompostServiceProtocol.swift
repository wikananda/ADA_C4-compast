//
//  CompostServiceProtocol.swift
//  ADA_C4-compast
//
//  MVVM Architecture - Service Protocol
//

import Foundation
import SwiftData

/// Protocol defining the interface for compost data operations.
/// Enables dependency injection and testability.
protocol CompostServiceProtocol {
    // MARK: - CompostItem Operations

    /// Fetches all compost items from the data store
    func fetchAllComposts(in context: ModelContext) throws -> [CompostItem]

    /// Fetches active (non-harvested) compost items
    func fetchActiveComposts(in context: ModelContext) throws -> [CompostItem]

    /// Fetches harvested compost items
    func fetchHarvestedComposts(in context: ModelContext) throws -> [CompostItem]

    /// Fetches a single compost item by ID
    func fetchCompost(byId id: Int, in context: ModelContext) -> CompostItem?

    /// Creates a new compost item
    func createCompost(
        name: String,
        method: CompostMethod,
        in context: ModelContext
    ) throws -> CompostItem

    /// Updates a compost item's name
    func renameCompost(_ item: CompostItem, to newName: String, in context: ModelContext) throws

    /// Marks a compost as harvested
    func harvestCompost(_ item: CompostItem, in context: ModelContext) throws

    /// Deletes a compost item
    func deleteCompost(_ item: CompostItem, in context: ModelContext) throws

    /// Records a turn event for the compost
    func turnCompost(_ item: CompostItem, in context: ModelContext) throws

    // MARK: - CompostMethod Operations

    /// Fetches all available compost methods
    func fetchAllMethods(in context: ModelContext) throws -> [CompostMethod]

    /// Fetches a compost method by ID
    func fetchMethod(byId id: Int, in context: ModelContext) -> CompostMethod?

    // MARK: - PileBand Operations

    /// Saves pile bands for a compost item
    func savePileBands(_ bands: [PileBand], for item: CompostItem, in context: ModelContext) throws

    /// Clears all pile bands for a compost item
    func clearPileBands(for item: CompostItem, in context: ModelContext) throws

    // MARK: - CompostStack Operations

    /// Adds a compost stack record
    func addCompostStack(
        brownAmount: Int,
        greenAmount: Int,
        isShredded: Bool,
        to item: CompostItem,
        in context: ModelContext
    ) throws

    // MARK: - Vitals Operations

    /// Updates temperature and moisture readings
    func updateVitals(
        for item: CompostItem,
        temperature: String,
        moisture: String,
        in context: ModelContext
    ) throws
}
