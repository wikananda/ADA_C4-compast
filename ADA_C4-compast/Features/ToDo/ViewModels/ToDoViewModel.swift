//
//  ToDoViewModel.swift
//  ADA_C4-compast
//
//  ToDo Module - ViewModel
//

import SwiftUI
import SwiftData

/// A single to-do item
struct ToDoItem: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
    var compostName: String?
}

/// Tasks grouped by date
struct DailyTasks: Identifiable {
    let id = UUID()
    var date: Date
    var tasks: [ToDoItem]
}

/// ViewModel for the ToDoMainView.
/// Manages task lists, grouping, and completion.
@Observable
final class ToDoViewModel {

    // MARK: - Dependencies

    private let compostService: CompostServiceProtocol
    private let modelContext: ModelContext

    // MARK: - Task State

    /// All compost items from the database
    var compostItems: [CompostItem] = []

    /// Daily task groups
    var dailyTaskGroups: [DailyTasks] = []

    // MARK: - Initialization

    init(
        compostService: CompostServiceProtocol = CompostService.shared,
        modelContext: ModelContext
    ) {
        self.compostService = compostService
        self.modelContext = modelContext
    }

    // MARK: - Computed Properties

    /// Whether there are any tasks
    var hasTasks: Bool {
        !dailyTaskGroups.isEmpty && dailyTaskGroups.contains { !$0.tasks.isEmpty }
    }

    /// Total task count
    var totalTaskCount: Int {
        dailyTaskGroups.reduce(0) { $0 + $1.tasks.count }
    }

    /// Completed task count
    var completedTaskCount: Int {
        dailyTaskGroups.reduce(0) { count, group in
            count + group.tasks.filter { $0.isCompleted }.count
        }
    }

    /// Today's tasks
    var todayTasks: [ToDoItem] {
        let calendar = Calendar.current
        return dailyTaskGroups
            .first { calendar.isDateInToday($0.date) }?
            .tasks ?? []
    }

    // MARK: - Actions

    /// Updates the task list from current compost items
    func updateCompostItems(_ items: [CompostItem]) {
        compostItems = items
        regenerateTasks()
    }

    /// Regenerates tasks from compost items
    func regenerateTasks() {
        var groups: [DailyTasks] = []
        let calendar = Calendar.current

        // Generate tasks for each active compost
        for compost in compostItems where compost.harvestedAt == nil {
            // Check if compost needs turning (example: every 3 days)
            if let lastTurned = compost.turnEvents.last?.date {
                let daysSinceTurn = calendar.dateComponents([.day], from: lastTurned, to: Date()).day ?? 0
                if daysSinceTurn >= 3 {
                    // Add turn task for today
                    addTaskToGroup(&groups, date: Date(), task: ToDoItem(
                        title: "Turn the \(compost.name) pile",
                        compostName: compost.name
                    ))
                }
            } else {
                // Never turned, suggest turning today
                addTaskToGroup(&groups, date: Date(), task: ToDoItem(
                    title: "Turn the \(compost.name) pile",
                    compostName: compost.name
                ))
            }

            // Check moisture update needed
//            if let lastUpdate = compost.compostVitals.last?.logDate {
//                let daysSinceUpdate = calendar.dateComponents([.day], from: lastUpdate, to: Date()).day ?? 0
//                if daysSinceUpdate >= 2 {
//                    addTaskToGroup(&groups, date: Date(), task: ToDoItem(
//                        title: "Check moisture level of \(compost.name)",
//                        compostName: compost.name
//                    ))
//                }
//            }
        }

        // Sort groups by date
        dailyTaskGroups = groups.sorted { $0.date < $1.date }
    }

    /// Adds a task to the appropriate date group
    private func addTaskToGroup(_ groups: inout [DailyTasks], date: Date, task: ToDoItem) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        if let index = groups.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }) {
            groups[index].tasks.append(task)
        } else {
            groups.append(DailyTasks(date: startOfDay, tasks: [task]))
        }
    }

    /// Marks a task as completed
    func toggleTaskCompletion(groupIndex: Int, taskIndex: Int) {
        guard groupIndex < dailyTaskGroups.count,
              taskIndex < dailyTaskGroups[groupIndex].tasks.count else { return }
        dailyTaskGroups[groupIndex].tasks[taskIndex].isCompleted.toggle()
    }

    /// Formats section title based on date
    func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
    }
}
