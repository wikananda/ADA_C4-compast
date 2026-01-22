//
//  SettingsViewModel.swift
//  ADA_C4-compast
//
//  Settings Module - ViewModel
//

import SwiftUI

/// ViewModel for the Settings screen.
/// Manages user preferences and app settings.
@Observable
final class SettingsViewModel {

    // MARK: - State

    /// Language preference (false = English, true = Indonesian)
    var isIndonesian: Bool = false

    /// Notification preference
    var notificationsEnabled: Bool = false

    /// App version string
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    // MARK: - Initialization

    init() {
        loadPreferences()
    }

    // MARK: - Actions

    /// Toggles the language preference
    func toggleLanguage(toIndonesian: Bool) {
        isIndonesian = toIndonesian
        savePreferences()
    }

    /// Toggles notification preference
    func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        savePreferences()

        if enabled {
            requestNotificationPermission()
        }
    }

    /// Opens the App Store for rating
    func openAppStoreRating() {
        // App Store URL would go here
        // For now, just a placeholder
    }

    // MARK: - Private Methods

    private func loadPreferences() {
        isIndonesian = UserDefaults.standard.bool(forKey: "isIndonesian")
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }

    private func savePreferences() {
        UserDefaults.standard.set(isIndonesian, forKey: "isIndonesian")
        UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
    }

    private func requestNotificationPermission() {
        Notifications.requestAuthIfNeeded()
    }
}
