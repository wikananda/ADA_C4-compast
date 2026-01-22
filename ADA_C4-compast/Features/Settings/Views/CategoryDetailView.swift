//
//  CategoryDetailView.swift
//  ADA_C4-compast
//
//  Settings Module - Category Detail View
//

import SwiftUI

/// View displaying all issues within a specific category.
struct CategoryDetailView: View {
    let category: IssueCategory

    var body: some View {
        List {
            ForEach(category.issues) { issue in
                NavigationLink(destination: IssueDetailView(issue: issue)) {
                    issueRow(issue)
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Subviews

    private func issueRow(_ issue: CompostIssue) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: issue.imageSymbol)
                    .foregroundColor(.orange)
                    .frame(width: 24)
                Text(issue.title)
                    .font(.headline)
            }
            Text(issue.shortDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        CategoryDetailView(category: compostData[0])
    }
}
