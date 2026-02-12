//
//  WasteRatioBalance.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 27/08/25.
//

import Foundation
import SwiftUI

// MARK: - Live balance engine (Brown : Green)
struct BalanceRecommendation {
    enum Severity { case ok, warnGreens, warnBrowns, empty }
    let title: String
    let message: String
    let tip: String?
    let neededText: String?      // e.g. "Add 2 browns"
    let severity: Severity
    let ratio: Double            // Brown/Green
    let progressToIdeal01: Double // 0...1 toward 2.5 within 2.0–3.0 band
}

struct BalanceConfig {
    static let ideal: Double = 2.5
    static let acceptable: ClosedRange<Double> = 2.0...3.0
}

func computeBalanceRecommendation(browns b: Int, greens g: Int) -> BalanceRecommendation {
    // empty
    if b == 0 && g == 0 {
        return .init(
            title: "Let’s Start Your Pile",
            message: "Begin with a brown base (dry leaves/cardboard), then add a green layer (kitchen scraps). Aim for Brown:Green ≈ 2.5.",
            tip: "Rule of thumb: 2–3 parts brown for every 1 part green.",
            neededText: "Add your first pile (brown or green).",
            severity: .empty,
            ratio: 0,
            progressToIdeal01: 0
        )
    }

    if b > 0 && g == 0 {
        let targetG = Int(ceil(Double(b) / BalanceConfig.ideal))
        let neededGreens = max(1, targetG)
        
        return .init(
            title: "Too Many Browns",
            message: "You have only browns. Add green piles to balance your compost",
            tip: "",
            neededText: "Add \(neededGreens) green pile\(neededGreens > 1 ? "s" : "")",
            severity: .warnBrowns,
            ratio: Double(b),
            progressToIdeal01: 0
        )
    }

    // avoid div-by-zero: treat 0 green as 1 temporarily for ratio messaging,
    // but still compute needed greens precisely below
    let ratio = g == 0 ? Double(b) / 1.0 : Double(b) / Double(g)

    // helper to clamp progress within acceptable band
    func progress(_ r: Double) -> Double {
        let lo = BalanceConfig.acceptable.lowerBound
        let hi = BalanceConfig.acceptable.upperBound
        if r <= lo { return 0 }
        if r >= hi { return 1 }
        return (r - lo) / (hi - lo)
    }

    // compute discrete next steps to reach *ideal* 2.5 using minimal units
    let ideal = BalanceConfig.ideal
    var neededText: String? = nil

    if ratio < BalanceConfig.acceptable.lowerBound {
        // Too many greens → need browns
        // find smallest Δb s.t. (b+Δb)/g ≥ 2.5
        if g > 0 {
            // let neededBrowns = max(0, Int(ceil(ideal * Double(g))) - b)
            let neededBrowns = max(0, Int(ceil(BalanceConfig.acceptable.lowerBound * Double(g))) - b)
            neededText = neededBrowns > 0 ? "Add \(neededBrowns) brown\(neededBrowns > 1 ? "s" : "")" : nil
        } else {
            // no greens yet; suggest a base
            neededText = "Add 1 brown"
        }

        return .init(
            title: "Too Many Greens",
            message: "Your pile is nitrogen-heavy. Mix in more browns (dry leaves, paper, cardboard) to balance.",
            tip: "Odor usually means excess nitrogen — add browns and turn.",
            neededText: neededText,
            severity: .warnGreens,
            ratio: ratio,
            progressToIdeal01: progress(ratio)
        )
    } else if ratio > BalanceConfig.acceptable.upperBound {
        // Too many browns → need greens
        // find smallest Δg s.t. b/(g+Δg) ≤ 2.5  ⇒ g+Δg ≥ b/2.5
        // let targetG = Int(ceil(Double(b) / ideal))
        let targetG = Int(ceil(Double(b) / BalanceConfig.acceptable.upperBound))
        let neededGreens = max(0, targetG - g)
        neededText = neededGreens > 0 ? "Add \(neededGreens) green\(neededGreens > 1 ? "s" : "")" : nil

        return .init(
            title: "Too Many Browns",
            message: "Carbon-heavy pile. Add fresh greens (food scraps, grass) and a splash of water if dry.",
            tip: "Smaller pieces = faster compost. Chop big bits and mix.",
            neededText: neededText,
            severity: .warnBrowns,
            ratio: ratio,
            progressToIdeal01: progress(ratio)
        )
    } else {
        // Acceptable band (2.0–3.0) → OK, give a nudge toward 2.5
        var nudge: String? = nil
        if abs(ratio - ideal) >= 0.01 {
            if ratio < ideal {
                // need browns to reach ideal
                if g > 0 {
                    let needB = max(0, Int(ceil(ideal * Double(g))) - b)
                    if needB > 0 { nudge = "For ideal 2.5:1, add \(needB) brown\(needB > 1 ? "s" : "")" }
                }
            } else {
                // need greens to reach ideal
                let targetG = Int(ceil(Double(b) / ideal))
                let needG = max(0, targetG - g)
                if needG > 0 { nudge = "For ideal 2.5:1, add \(needG) green\(needG > 1 ? "s" : "")" }
            }
        }

        return .init(
            title: "Good Balance",
            message: "You’re within the ideal band (2.0–3.0). Keep layering browns and greens.",
            tip: "Aim near 2.5 browns for each 1 green for fastest results.",
            neededText: nudge,
            severity: .ok,
            ratio: ratio,
            progressToIdeal01: progress(ratio)
        )
    }
}

//Recommendation View
struct BalanceRecommendationView: View {
    let rec: BalanceRecommendation
    @State private var showInfo: Bool = false

    var body: some View {
        ZStack (alignment: .topLeading) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(color)
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 6) {
                    // Text(rec.title)
                    //     .font(.headline)
                    //     .foregroundStyle(color)
                    
                    HStack(spacing: 10) {
                        Text(rec.title)
                            .font(.headline)
                            .foregroundStyle(color)
                            .onTapGesture{
                                if !rec.message.isEmpty {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showInfo = true }
                                }
                            }
                        Button {
                            if !rec.message.isEmpty {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showInfo = true }
                            }
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if let need = rec.neededText {
                        Label(need, systemImage: "plus.circle")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .labelStyle(.titleAndIcon)
                    }
                    
                    // Progress toward ideal (2.5 within 2.0–3.0)
                    ProgressView(value: rec.progressToIdeal01) {
                        Text("Toward ideal 2.5")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .progressViewStyle(.linear)
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
            .overlay(
                RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
            
            if showInfo && !rec.message.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(rec.title)
                            .font(.headline)
                            .foregroundStyle(color)
                        Spacer()
                        Button {
                        } label: {
                            Image(systemName: "xmark.circle")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    Text(rec.message)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    if let tip = rec.tip, !tip.isEmpty {
                        Label {
                            Text(tip)
                                .fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: "info.circle")
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .stroke(Color("BrandGreenDark").opacity(0.5))
                        .tint(.black)
                )
                .offset(x: 36, y: -56)
                .zIndex(1)
                .onTapGesture{
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showInfo = false }
                }
            }
        }
    }

    private var color: Color {
        switch rec.severity {
        case .ok:          return Color("BrandGreenDark")
        case .warnGreens:  return Color("Status/Warning")
        case .warnBrowns:  return Color("Status/Warning")
        case .empty:       return .gray
        }
    }
    private var icon: String {
        switch rec.severity {
        case .ok:          return "checkmark.seal.fill"
        case .warnGreens:  return "leaf.circle"
        case .warnBrowns:  return "leaf"
        case .empty:       return "tray"
        }
    }
}


