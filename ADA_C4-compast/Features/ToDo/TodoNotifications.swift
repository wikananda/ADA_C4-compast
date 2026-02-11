//
//  TodoNotifications.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 27/08/25.
//

import SwiftUI

// MARK: - Local Notifications
enum Notifications {
    static func requestAuthIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus != .authorized else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        }
    }

    static func id(for task: CompostTask) -> String {
        "compost.task.\(task.type.rawValue).\(task.compostId)"
    }

    static func scheduleAll(for tasks: [CompostTask]) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        for t in tasks where !t.isCompleted {
            let content = UNMutableNotificationContent()
            content.title = notificationTitle(for: t.type)
            content.body  = notificationBody(for: t.type, compostName: t.compostName)
            content.sound = .default

            let triggerDate = max(t.dueDate, Date()) // never schedule in the past
            let comps = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)

            let req = UNNotificationRequest(identifier: id(for: t), content: content, trigger: trigger)
            center.add(req)
        }
    }

    static func remove(for task: CompostTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id(for: task)])
    }

    // Copy based on your table
    private static func notificationTitle(for type: CompostTaskType) -> String {
        switch type {
        case .turnPile: return "Time to Turn Your Compost"
        case .updateLog: return "Update Your Compost Log"
        case .checkHarvest: return "Check for Harvest Readiness"
        case .balanceRatio: return "Your Compost Ratio Needs Attention"
        case .compostMilestone: return "Compost Milestone Reached!"
        }
    }
    private static func notificationBody(for type: CompostTaskType, compostName: String) -> String {
        switch type {
        case .turnPile:
            return "Keep it breathing — give \"\(compostName)\" a stir."
        case .updateLog:
            return "It's been a while! Log today's temperature & moisture."
        case .checkHarvest:
            return "\"\(compostName)\" may be finished — look for rich, crumbly compost."
        case .balanceRatio:
            return "\"\(compostName)\" brown/green ratio is off — check what to add."
        case .compostMilestone:
            return "Your compost \"\(compostName)\" hit a new milestone!"
        }
    }
}

