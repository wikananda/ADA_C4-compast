//
//  StatusChip.swift
//  ADA_C4-compast
//
//  Shared Component - Status Indicator Chip
//

import SwiftUI

/// A small chip displaying the status of a compost item.
struct StatusChip: View {
    enum ChipType {
        case healthy, needAction, harvested
    }

    let type: ChipType

    var body: some View {
        Text(label)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 100).fill(color))
            .foregroundStyle(.white)
            .font(.caption)
    }

    private var label: String {
        switch type {
        case .healthy:    return "Healthy"
        case .needAction: return "Need Action"
        case .harvested:  return "Harvested"
        }
    }

    private var color: Color {
        switch type {
        case .healthy:    return Color("Status/Success")
        case .needAction: return Color("Status/Warning")
        case .harvested:  return .blue
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        StatusChip(type: .healthy)
        StatusChip(type: .needAction)
        StatusChip(type: .harvested)
    }
    .padding()
}
