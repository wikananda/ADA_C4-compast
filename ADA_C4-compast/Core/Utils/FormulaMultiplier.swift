//
//  FormulaMultiplier.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 27/08/25.
//

import Foundation
import SwiftUI
import SwiftData


// MARK: - Harvest ETA engine
struct CompostETAResult {
    let m_T: Double
    let m_M: Double
    let m_BG: Double
    let f_S: Double
    let m_Turn: Double
    let baseDays: Double
    let effectiveDays: Double
    let estimatedDate: Date
}

extension CompostItem {

    /// Pick a base duration (days) from your method envelope.
    /// You can refine: use mid-point, or dynamic based on season/volume/etc.
    var baseDurationDays: Double {
        guard let m = compostMethodId else { return 90 }     // default 90d if no method
        // midpoint of your two ranges (e.g., Hot: 30–180)
        return Double((m.compostDuration1 + m.compostDuration2)) / 2.0
    }

    /// Compute multipliers and estimate a harvest date.
    func computeETA(now: Date = Date()) -> CompostETAResult {
        // Inputs (use live sensors when available)
        let T = min(coreTempC_nominal, 70)           // cap at 70 in the formula
        let Moist = moisturePct_nominal
        let BG = brownGreenRatio
        let turnsPM = turnsPerMonth

        // 1) Temperature multiplier: m_T = clamp( 2^((min(T,70)-35)/10), 0.6, 3.5 )
        let m_T = clamp(pow(2.0, (T - 35.0) / 10.0), 0.6, 3.5)

        // 2) Moisture multiplier: m_M = clamp( 1 - 0.012*|Moist-55|, 0.5, 1.2 )
        let m_M = clamp(1.0 - 0.012 * abs(Moist - 55.0), 0.5, 1.2)

        // 3) Brown:Green multiplier: m_BG = clamp( 1 - 0.07*|BG - 2.5|, 0.6, 1.2 )
        let m_BG = clamp(1.0 - 0.07 * abs(BG - 2.5), 0.6, 1.2)

        // 4) Shredded factor f_S (multiply base by 0.8 if shredded, else 1.0)
        let f_S = isShreddedAny ? 0.8 : 1.0

        // 5) Turning / Aeration: different slopes for COLD vs HOT
        let m_Turn = clamp(0.75 + 0.04 * turnsPM, 0.75, 1.25)

        // Base duration
        let base = HotCompost.baseDurationDays

        // Effective duration:
        // Reduce base with shredding, then divide by positive multipliers
        // (higher multipliers => faster => fewer days)
        let denom = max(m_T * m_M * m_BG * m_Turn, 0.1)
        let effective = max(round(base * f_S / denom), 7)     // keep >= 1 week

        let etaDate = Calendar.current.date(byAdding: .day, value: Int(effective), to: creationDate) ?? now

        return CompostETAResult(
                   m_T: m_T, m_M: m_M, m_BG: m_BG, f_S: f_S, m_Turn: m_Turn,
                   baseDays: base, effectiveDays: effective, estimatedDate: etaDate
               )
    }

    func recomputeAndStoreETA(in context: ModelContext) {
        let res = computeETA()
        self.estimatedHarvestAt = res.estimatedDate
        try? context.save()
    }
}

