//
//  HelpViewModel.swift
//  ADA_C4-compast
//
//  Settings Module - Help ViewModel
//

import SwiftUI

/// ViewModel for the Help screen.
/// Manages search and filtering of compost issues.
@Observable
final class HelpViewModel {

    // MARK: - State

    /// Search text for filtering issues
    var searchText: String = ""

    /// All available categories
    let categories: [IssueCategory] = compostData

    // MARK: - Computed Properties

    /// Filtered categories based on search text
    var filteredCategories: [IssueCategory] {
        guard !searchText.isEmpty else { return categories }

        let lowercasedSearch = searchText.lowercased()

        return categories.compactMap { category in
            let filteredIssues = category.issues.filter { issue in
                issue.title.lowercased().contains(lowercasedSearch) ||
                issue.shortDescription.lowercased().contains(lowercasedSearch) ||
                issue.symptoms.contains { $0.lowercased().contains(lowercasedSearch) } ||
                issue.causes.contains { $0.lowercased().contains(lowercasedSearch) } ||
                issue.solutions.contains { $0.lowercased().contains(lowercasedSearch) }
            }

            if filteredIssues.isEmpty && !category.name.lowercased().contains(lowercasedSearch) {
                return nil
            }

            if filteredIssues.isEmpty {
                return category
            }

            return IssueCategory(
                name: category.name,
                icon: category.icon,
                issues: filteredIssues
            )
        }
    }

    /// Total number of issues across all categories
    var totalIssueCount: Int {
        categories.reduce(0) { $0 + $1.issues.count }
    }

    /// Whether search is active
    var isSearching: Bool {
        !searchText.isEmpty
    }

    // MARK: - Actions

    /// Clears the search text
    func clearSearch() {
        searchText = ""
    }

    /// Gets issues for a specific category
    func issues(for category: IssueCategory) -> [CompostIssue] {
        if isSearching {
            return filteredCategories.first { $0.id == category.id }?.issues ?? []
        }
        return category.issues
    }
}
