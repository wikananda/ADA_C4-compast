//
//  OptionCard.swift
//  ADA_C4-compast
//
//  Shared Component - Reusable Selection Card
//

import SwiftUI

/// A card row for displaying selectable options.
/// Shows icon, title, subtitle, and selection state.
struct OptionCard: View {
    let option: Option
    @Binding var selected: Option?

    private var isSelected: Bool { selected == option }
    private var accent: Color { Color("BrandGreen") }

    var body: some View {
        Button {
            selected = option
        } label: {
            HStack(spacing: 14) {
                // Leading icon badge
                iconBadge

                // Title & subtitle
                textContent

                Spacer()

                // Radio → check
                selectionIndicator
            }
            .padding(16)
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .background(cardBackground)
            .overlay(cardBorder)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: isSelected)
    }

    // MARK: - Subviews

    private var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(option.tint.opacity(0.25), lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(option.tint.opacity(0.08))
                )
            Image(systemName: option.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(option.tint)
        }
        .frame(width: 36, height: 36)
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(option.title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(option.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var selectionIndicator: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(isSelected ? accent : .secondary.opacity(0.4))
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(isSelected ? accent.opacity(0.08) : .white)
            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(isSelected ? accent : .clear, lineWidth: 2)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: Option?

        private let options: [Option] = [
            .init(icon: "sun.max.fill", title: "Everyday", subtitle: "Faster compost", tint: .yellow),
            .init(icon: "calendar", title: "Weekly", subtitle: "Slower compost", tint: .blue)
        ]

        var body: some View {
            VStack(spacing: 16) {
                ForEach(options) { option in
                    OptionCard(option: option, selected: $selected)
                }
            }
            .padding()
            .background(Color(.systemGroupedBackground))
        }
    }

    return PreviewWrapper()
}
