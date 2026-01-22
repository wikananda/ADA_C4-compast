//
//  AdviceCard.swift
//  ADA_C4-compast
//
//  Shared Component - Compost Advice Card
//

import SwiftUI

/// A card displaying advice or status for a specific compost category.
struct AdviceCard: View {
    let category: CompostCategory
    let issue: CompostProblem?

    var body: some View {
        if let issue {
            issueView(issue)
        } else {
            goodStatusView
        }
    }

    // MARK: - Issue View

    private func issueView(_ issue: CompostProblem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: iconFor(issue.category))
                    .foregroundStyle(.red)
                Text(issue.title)
                    .font(.headline)
                    .foregroundStyle(.red)
            }

            Divider().opacity(0.5)

            Label {
                Text(issue.solution)
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "lightbulb")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let tip = issue.tip, !tip.isEmpty {
                Label(tip, systemImage: "info.circle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 10)
    }

    // MARK: - Good Status View

    private var goodStatusView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: iconFor(category))
                    .foregroundStyle(Color("Status/Success"))
                Text(goodTitle(for: category))
                    .font(.headline)
                    .foregroundStyle(Color("Status/Success"))
            }
            Divider().opacity(0.5)
            Text(goodMessage(for: category))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 10)
    }

    // MARK: - Helpers

    private func goodTitle(for cat: CompostCategory) -> String {
        switch cat {
        case .temperature: return "Good temperature (warm)"
        case .moisture:    return "Good moisture (humid)"
        case .balance:     return "Good carbon/nitrogen balance"
        case .sizing:      return "Good material sizing"
        case .aeration:    return "Good aeration"
        }
    }

    private func iconFor(_ cat: CompostCategory) -> String {
        switch cat {
        case .moisture:    return "drop"
        case .temperature: return "thermometer"
        case .balance:     return "scalemass"
        case .sizing:      return "scissors"
        case .aeration:    return "wind"
        }
    }

    private func goodMessage(for cat: CompostCategory) -> String {
        switch cat {
        case .temperature: return "Temperature is healthy, keep it up!"
        case .moisture:    return "Moisture level looks good, keep it up!"
        case .balance:     return "Carbon/Nitrogen balance looks good."
        case .sizing:      return "Material sizing looks good!"
        case .aeration:    return "Aeration looks healthy!"
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AdviceCard(category: .temperature, issue: nil)
        AdviceCard(category: .moisture, issue: nil)
    }
    .padding()
}
