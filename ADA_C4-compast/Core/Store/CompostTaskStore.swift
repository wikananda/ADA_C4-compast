//
//  Untitled.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 27/08/25.
//

import SwiftUI
import Combine

final class CompostTaskStore: ObservableObject {
    @Published private(set) var allTasks: [CompostTask] = []

    /// Rebuild tasks from the latest compost list
    func regenerate(from composts: [CompostItem]) {
        allTasks = CompostTaskEngine.buildTasks(for: composts)
        Notifications.scheduleAll(for: allTasks)
    }

    func markCompleted(_ task: CompostTask) {
        guard let idx = allTasks.firstIndex(of: task) else { return }
        allTasks[idx].isCompleted = true
        allTasks[idx].completedAt = Date()
        Notifications.remove(for: task)
    }
}
