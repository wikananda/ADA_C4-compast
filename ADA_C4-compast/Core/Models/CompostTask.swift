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
    case turnPile = "Mix the pile"
    case updateLog = "Update Log"
    case checkHarvest = "Check if ready for harvest"
    case balanceRatio = "Adjust brown/green ratio"
    case compostMilestone = "Compost milestone"
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
    static var acceptableBrownGreenRange: ClosedRange<Double> = 2.0...3.0
    /// Milestone thresholds expressed as completion fractions
    static var milestoneThresholds: [Double] = [0.25, 0.50, 0.75]
}

// MARK: - Task Engine
struct CompostTaskEngine {
    /// Build tasks for a single compost
    static func buildTasks(for compost: CompostItem, now: Date = Date()) -> [CompostTask] {
        var out: [CompostTask] = []
        let name = compost.name

        // Skip harvested composts entirely
        guard compost.harvestedAt == nil else { return out }

        // --- 1) Turn the pile
        // Trigger: days since last TurnEvent ≥ lower bound (5 days)
        let daysSinceTurn = compost.daysSinceLastTurn ?? Int.max
        if daysSinceTurn >= CompostTaskRules.turnEveryDaysRange.lowerBound {
            let due = Calendar.current.date(byAdding: .day, value: CompostTaskRules.turnEveryDaysRange.lowerBound - daysSinceTurn, to: now) ?? now
            out.append(.init(compostId: compost.compostItemId,
                             compostName: name,
                             type: .turnPile,
                             dueDate: due))
        }

        // --- 2) Update Log
        // Trigger: no log update for ≥ 5 days
        let daysSinceLog = Calendar.current.dateComponents([.day], from: compost.lastLogged, to: now).day ?? 999
        if daysSinceLog >= CompostTaskRules.noLogDaysThreshold {
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

        if ageDays >= targetDays {
            out.append(.init(compostId: compost.compostItemId,
                             compostName: name,
                             type: .checkHarvest,
                             dueDate: now))
        }

        // --- 4) Balance ratio check
        // Trigger: brown/green ratio outside acceptable range (2.0 - 3.0)
        let totalB = compost.totalBrown
        let totalG = compost.totalGreen
        let hasMaterials = totalB > 0 || totalG > 0
        if hasMaterials {
            let ratio = totalG == 0 ? Double(totalB) : Double(totalB) / Double(totalG)
            let range = CompostTaskRules.acceptableBrownGreenRange
            if ratio < range.lowerBound || ratio > range.upperBound {
                let note: String
                if ratio < range.lowerBound {
                    let neededBrowns = max(0, Int(ceil(2.5 * Double(max(totalG, 1)))) - totalB)
                    note = "Too many greens — add \(max(neededBrowns, 1)) more brown material\(neededBrowns > 1 ? "s" : "") like dry leaves or cardboard"
                } else {
                    let targetG = Int(ceil(Double(totalB) / 2.5))
                    let neededGreens = max(0, targetG - totalG)
                    note = "Too many browns — add \(max(neededGreens, 1)) more green material\(neededGreens > 1 ? "s" : "") like food scraps or grass"
                }
                out.append(.init(compostId: compost.compostItemId,
                                 compostName: name,
                                 type: .balanceRatio,
                                 dueDate: now,
                                 note: note))
            }
        }

        // --- 5) Compost milestones
        // Show a milestone celebration when the pile reaches 25%, 50%, or 75% of its ETA
        if targetDays > 0 {
            for threshold in CompostTaskRules.milestoneThresholds {
                let thresholdDay = Int(Double(targetDays) * threshold)
                // Show milestone if we're within 1 day of the threshold mark
                if ageDays >= thresholdDay && ageDays <= thresholdDay + 1 {
                    let pct = Int(threshold * 100)
                    let note = milestoneMessage(percent: pct, compostName: name, daysRemaining: targetDays - ageDays)
                    out.append(.init(compostId: compost.compostItemId,
                                     compostName: name,
                                     type: .compostMilestone,
                                     dueDate: now,
                                     note: note))
                    break // only show one milestone at a time
                }
            }
        }

        return out
    }

    /// Milestone celebration message
    private static func milestoneMessage(percent: Int, compostName: String, daysRemaining: Int) -> String {
        switch percent {
        case 25:
            return "\(compostName) is 25% done! The microbes are hard at work breaking things down."
        case 50:
            return "\(compostName) is halfway there! About \(daysRemaining) days to go."
        case 75:
            return "\(compostName) is 75% done! Almost ready — keep up the great composting!"
        default:
            return "\(compostName) has reached \(percent)% completion!"
        }
    }

    /// Build tasks for many composts
    static func buildTasks(for composts: [CompostItem], now: Date = Date()) -> [CompostTask] {
        composts.flatMap { buildTasks(for: $0, now: now) }
                .sorted(by: { $0.dueDate < $1.dueDate })
    }
}
