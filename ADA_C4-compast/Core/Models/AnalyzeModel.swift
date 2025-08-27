//
//  AnalyzeModel.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 26/08/25.
//

import Foundation
import SwiftUI

// MARK: - Compost Knowledge

enum CompostCategory: String, Codable, CaseIterable {
    case moisture = "Moisture"
    case temperature = "Temperature"
    case balance = "Brown/Green Balance"
    case sizing = "Sizing"
    case aeration = "Turning / Aeration"
}

struct CompostProblem: Identifiable, Codable, Hashable {
    let id: Int
    let category: CompostCategory
    let title: String     // e.g. "Too dry"
    let issue: String     // short issue line
    let solution: String  // what to do
    let tip: String?      // optional tip
    let backendInfo: String? // backend thresholds/notes
}

enum CompostKnowledge {
    static let issues: [CompostProblem] = [
        // Moisture
        .init(id: 1, category: .moisture, title: "Too dry",
              issue: "Moisture is below ideal range.",
              solution: "Add water or green materials to increase moisture.",
              tip: "Pile should feel like a wrung-out sponge.",
              backendInfo: "Ideal 50–60% moisture"),
        .init(id: 2, category: .moisture, title: "Too wet",
              issue: "Moisture is above ideal range.",
              solution: "Add browns and turn to introduce air; aim for 50–60%.",
              tip: "Pile should feel like a wrung-out sponge.",
              backendInfo: "Alert if >65% moisture"),

        // Temperature
        .init(id: 3, category: .temperature, title: "Too cold",
              issue: "Pile isn’t heating sufficiently.",
              solution: "Add greens, shred materials, and turn the pile.",
              tip: nil,
              backendInfo: "Alert if <40°C (104°F) during active phase"),
        .init(id: 4, category: .temperature, title: "Too hot",
              issue: "Temperature is excessive.",
              solution: "Turn to release heat and add more browns.",
              tip: "Over 70°C can kill beneficial microbes.",
              backendInfo: "Alert if >70°C (158°F)"),
        .init(id: 5, category: .temperature, title: "Cooled down too early",
              issue: "Temperature dropped too soon.",
              solution: "Add fresh greens and turn the pile.",
              tip: nil,
              backendInfo: "Drop of >15°C in <2 days before reaching maturity"),

        // Balance
        .init(id: 6, category: .balance, title: "Too many greens",
              issue: "Excess nitrogen; odors likely.",
              solution: "Add browns and mix thoroughly.",
              tip: "Odor usually means excess nitrogen.",
              backendInfo: "Greens >70% → trigger alert"),
        .init(id: 7, category: .balance, title: "Too many browns",
              issue: "Carbon-heavy; slow breakdown.",
              solution: "Add more greens and some water.",
              tip: nil,
              backendInfo: "Browns >70% → trigger alert"),

        // Sizing
        .init(id: 8, category: .sizing, title: "Materials too large",
              issue: "Pieces are too big; slows composting.",
              solution: "Shred/chop smaller before adding.",
              tip: "Smaller pieces = faster compost.",
              backendInfo: nil),

        // Aeration
        .init(id: 9, category: .aeration, title: "Not aerated (pile compacted)",
              issue: "Poor airflow; microbes starve.",
              solution: "Turn pile and add coarse browns.",
              tip: "Airflow keeps microbes active.",
              backendInfo: "Must be turned at least every 1–2 weeks"),
        .init(id: 10, category: .aeration, title: "Overturned (not heating)",
              issue: "Too-frequent turning prevents heat build-up.",
              solution: "Wait longer between turns.",
              tip: nil,
              backendInfo: "If pile temp never rises after frequent turns"),
    ]

    /// Map your selected categories to actionable advice.
    static func advice(for compost: CompostItem) -> [CompostProblem] {
        var out: [CompostProblem] = []

        // Temperature mapping
        switch compost.temperatureCategory.lowercased() {
        case "cold":
            if let issue = issues.first(where: { $0.id == 3 }) {
                out.append(issue)
            }
        case "hot":
            if let issue = issues.first(where: { $0.id == 4 }) {
                out.append(issue)
            }
        case "warm":   break // warm = OK
        default: break
        }

        // Moisture mapping
        switch compost.moistureCategory.lowercased() {
        case "dry":
            if let issue = issues.first(where: { $0.id == 1 }) {
                out.append(issue)
            }
        case "wet":
            if let issue = issues.first(where: { $0.id == 2 }) {
                out.append(issue)
            }
        case "humid": break // OK
        default: break
        }

        return out
    }
}
