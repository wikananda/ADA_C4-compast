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

    /// Regenerates tasks from compost items using the CompostTaskEngine
    func regenerateTasks() {
        var groups: [DailyTasks] = []
        let tasks = CompostTaskEngine.buildTasks(for: compostItems)

        for task in tasks {
            let title: String
            switch task.type {
            case .turnPile:
                title = "Turn the \(task.compostName) pile"
            case .updateLog:
                title = "Update log for \(task.compostName)"
            case .checkHarvest:
                title = "Check if \(task.compostName) is ready to harvest"
            case .balanceRatio:
                title = task.note ?? "Adjust ratio for \(task.compostName)"
            case .compostMilestone:
                title = task.note ?? "Milestone for \(task.compostName)"
            }

            addTaskToGroup(&groups, date: task.dueDate, task: ToDoItem(
                title: title,
                compostName: task.compostName
            ))
        }

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
