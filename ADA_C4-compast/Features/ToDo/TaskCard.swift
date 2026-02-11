//
//  TaskCard.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 27/08/25.
//

import SwiftUI

// MARK: - Section Header (unchanged)
struct SectionHeader: View {
    let title: String
    let icon: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "2D3E2D"))
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "2D3E2D"))
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Task Card

struct TaskCard: View {
    let task: CompostTask
    var isUpcoming: Bool = false
    let onToggle: () -> Void
    @State private var isTapped = false

    var body: some View {
        VStack(spacing: 0) {
            if isTapped && !isUpcoming && !task.isCompleted {
                ExpandedTaskCard(task: task, onToggle: onToggle, onTap: { isTapped.toggle() })
            } else {
                CompactTaskCard(
                    task: task,
                    isUpcoming: isUpcoming,
                    onToggle: onToggle,
                    onTap: {
                        if !isUpcoming && !task.isCompleted { isTapped.toggle() }
                    }
                )
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isTapped)
    }
}

struct CompactTaskCard: View {
    let task: CompostTask
    let isUpcoming: Bool
    let onToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Button(action: (isUpcoming || task.isCompleted) ? {} : onToggle) {
                ZStack {
                    Circle()
                        .fill(task.isCompleted ? Color(hex: "4A6741") : Color(hex: "D3D3D3"))
                        .frame(width: 24, height: 24)
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(isUpcoming || task.isCompleted)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: iconFor(task.type))
                        .font(.system(size: 16))
                        .foregroundColor(task.type == .compostMilestone ? Color(hex: "D4A017") : fgColor)
                    Text(task.type == .compostMilestone ? (task.note ?? task.type.rawValue) : task.type.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(task.type == .compostMilestone ? Color(hex: "D4A017") : fgColor)
                        .lineLimit(2)
                }
                Text(task.compostName)
                    .font(.system(size: 16))
                    .foregroundColor(subColor)

                if task.isOverdue && !isUpcoming && !task.isCompleted {
                    Text("Overdue")
                        .font(.caption2).foregroundStyle(.white)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Capsule().fill(Color.red.opacity(0.9)))
                }

                // Show actionable note for balance ratio tasks
                if task.type == .balanceRatio, let note = task.note, !isUpcoming && !task.isCompleted {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(task.isCompleted ? Color(hex: "C7CCC7") : Color.white)
        )
        .opacity(isUpcoming ? 0.9 : 1.0)
        .onTapGesture(perform: onTap)
        .transition(.blurReplace)
    }

    private var fgColor: Color { (isUpcoming || task.isCompleted) ? Color.gray.opacity(0.6) : Color(hex: "2D3E2D") }
    private var subColor: Color { (isUpcoming || task.isCompleted) ? Color.gray.opacity(0.6) : Color(hex: "4D4D4D") }

    private func iconFor(_ type: CompostTaskType) -> String {
        switch type {
        case .turnPile: return "arrow.trianglehead.2.clockwise"
        case .updateLog: return "doc.text"
        case .checkHarvest: return "checkmark.seal"
        case .balanceRatio: return "scalemass"
        case .compostMilestone: return "star.fill"
        }
    }
    private func relative(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .short
        return f.localizedString(for: date, relativeTo: Date())
    }
}

struct ExpandedTaskCard: View {
    let task: CompostTask
    let onToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 16) {
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .fill(task.isCompleted ? Color(hex: "4A6741") : Color(hex: "D3D3D3"))
                            .frame(width: 24, height: 24)
                        if task.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "2D3E2D"))
                        Text(task.type.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "2D3E2D"))
                    }
                    Text(task.compostName)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "4D4D4D"))
                }
                Spacer()
                Button(action: onTap) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.gray.opacity(0.5))
                }
            }

            Text(detailCopy(for: task.type))
                .font(.system(size: 16))
                .foregroundColor(Color.gray)

            if task.type == .updateLog {
                Text("Log temperature (Warm/Hot), moisture (Humid), and your layering today.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .fill(task.isCompleted ? Color(hex: "C7CCC7") : Color(hex: "E8E8E8"))
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .transition(.blurReplace)
        .onTapGesture(perform: onTap)
    }

    private func detailCopy(for type: CompostTaskType) -> String {
        switch type {
        case .turnPile:
            return "Keep it breathing — turn to distribute heat and moisture."
        case .updateLog:
            return "Your compost grows best when you check in — update today's log."
        case .checkHarvest:
            return "It could be ready! Look for dark, crumbly texture and earthy smell."
        case .balanceRatio:
            return task.note ?? "Your brown/green ratio is off balance. Adjust your materials for faster composting."
        case .compostMilestone:
            return task.note ?? "Your compost has reached a new milestone!"
        }
    }
}





