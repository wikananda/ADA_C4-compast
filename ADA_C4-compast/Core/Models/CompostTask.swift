//
//  CompastTask.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 27/08/25.
//

import Foundation


import SwiftUI
import UserNotifications

// MARK: - Task Types
enum CompostTaskType: String, Codable, CaseIterable {
    case turnPile = "Turn the pile"
    case updateLog = "Update Log"
    case checkHarvest = "Check if ready for harvest"
}

// MARK: - Task Record (UI model, not persisted)
struct CompostTask: Identifiable, Hashable {
    let id = UUID()
    let compostId: Int
    let compostName: String
    let type: CompostTaskType
    let dueDate: Date
    var isCompleted: Bool = false
    var completedAt: Date? = nil
    var note: String? = nil

    var isOverdue: Bool { dueDate < Date() && !isCompleted }

    // Sectioning for UI
    enum Section { case current, history }
    var section: Section { isCompleted ? .history : .current }
}

// MARK: - Rule configuration (edit to taste)
struct CompostTaskRules {
    static var turnEveryDaysRange: ClosedRange<Int> = 5...7
    static var noLogDaysThreshold: Int = 5
    static var defaultHotBaseDays: Int = 90        // fallback if ETA missing
}

// MARK: - Task Engine
struct CompostTaskEngine {
    /// Build tasks for a single compost
    static func buildTasks(for compost: CompostItem, now: Date = Date()) -> [CompostTask] {
        var out: [CompostTask] = []
        let name = compost.name

        // --- 1) Turn the pile
        // Trigger: days since last TurnEvent ≥ lower bound (5 days)
        let daysSinceTurn = compost.daysSinceLastTurn ?? Int.max
        if daysSinceTurn >= CompostTaskRules.turnEveryDaysRange.lowerBound && compost.compostStatus != .harvested {
            let due = Calendar.current.date(byAdding: .day, value: CompostTaskRules.turnEveryDaysRange.lowerBound - daysSinceTurn, to: now) ?? now
            out.append(.init(compostId: compost.compostItemId,
                             compostName: name,
                             type: .turnPile,
                             dueDate: due))
        }

        // --- 2) Update Log
        // Trigger: no log update for ≥ 5 days
        let daysSinceLog = Calendar.current.dateComponents([.day], from: compost.lastLogged, to: now).day ?? 999
        if daysSinceLog >= CompostTaskRules.noLogDaysThreshold && compost.compostStatus != .harvested {
            out.append(.init(compostId: compost.compostItemId,
                             compostName: name,
                             type: .updateLog,
                             dueDate: now))
        }

        // --- 3) Check if ready for harvest
        // Trigger: age reaches ETA (estimatedHarvestAt) or hits base 90d fallback
        let ageDays = Calendar.current.dateComponents([.day], from: compost.creationDate, to: now).day ?? 0
        let eta = compost.estimatedHarvestAt
        let targetDays = eta.map { Calendar.current.dateComponents([.day], from: compost.creationDate, to: $0).day ?? CompostTaskRules.defaultHotBaseDays }
                        ?? CompostTaskRules.defaultHotBaseDays

        if ageDays >= targetDays && compost.harvestedAt == nil {
            out.append(.init(compostId: compost.compostItemId,
                             compostName: name,
                             type: .checkHarvest,
                             dueDate: now))
        }

        return out
    }

    /// Build tasks for many composts
    static func buildTasks(for composts: [CompostItem], now: Date = Date()) -> [CompostTask] {
        composts.flatMap { buildTasks(for: $0, now: now) }
                .sorted(by: { $0.dueDate < $1.dueDate })
    }
}
