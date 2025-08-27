//
//  InputFormula.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 27/08/25.
//

import Foundation
import SwiftUI

struct HotCompost {
    static let baseDurationDays: Double = 90

    // Ideal bands (informational; multipliers already handle off-ideal)
    static let idealTempC: ClosedRange<Double> = 55...65
    static let idealMoisturePct: ClosedRange<Double> = 50...60
    static let idealBrownGreen: Double = 2.5
    static let acceptableBrownGreen: ClosedRange<Double> = 2.0...3.0

    // Ops guidance (for UI hints / defaults)
    static let recommendedTurnsPerMonth: ClosedRange<Double> = 8...12
}

// MARK: - Category → numeric defaults (tweak to taste)
extension CompostItem {
    /// Core temperature in °C (nominal mapping)
    var coreTempC_nominal: Double {
        switch temperatureCategory.lowercased() {
        case "cold": return 30   // <38°C
        case "warm": return 55   // 38–65°C
        case "hot":  return 70   // >65°C, clamp will limit
        default:     return 35
        }
    }

    /// Moisture % (by feel)
    var moisturePct_nominal: Double {
        switch moistureCategory.lowercased() {
        case "dry":   return 40
        case "humid": return 55
        case "wet":   return 70
        default:      return 55
        }
    }

    /// Brown:Green ratio by volume (approx from your stacks)
    var brownGreenRatio: Double {
          let b = Double(totalBrown)
          let g = Double(totalGreen)
          if b == 0 && g == 0 { return HotCompost.idealBrownGreen }
          return safeDiv(b, max(g, 1))
      }

    /// Any “shredded” usage? (true if any band/stack is shredded)
    var isShreddedAny: Bool {
        let a = pileBands.contains { $0.isShredded } || compostStacks.contains { $0.isShredded }
        return a
    }

    /// Turns per month (rolling)
    var turnsPerMonth: Double {
          guard let first = turnEvents.map(\.date).min() else { return 0 }
          let comps = Calendar.current.dateComponents([.month, .day], from: first, to: Date())
          let months = Double(comps.month ?? 0)
          let daysRemainder = Double(comps.day ?? 0)
          let spanMonths = max(months + daysRemainder/30.0, 1.0/3.0)
          return safeDiv(Double(turnEvents.count), spanMonths)
      }

    /// Method type for m_Turn. Use your method name or add a flag.
    var isColdMethod: Bool {
        (compostMethodId?.name ?? "").localizedCaseInsensitiveContains("cold")
    }
}
