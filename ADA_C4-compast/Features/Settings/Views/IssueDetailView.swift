//
//  IssueDetailView.swift
//  ADA_C4-compast
//
//  Settings Module - Issue Detail View
//

import SwiftUI

/// Detailed view for a specific compost issue.
/// Shows symptoms, causes, and solutions.
struct IssueDetailView: View {
    let issue: CompostIssue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                issueImage
                symptomsSection
                causesSection
                solutionsSection
            }
        }
        .navigationTitle(issue.title)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Subviews

    private var issueImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 200)

            Image(systemName: issue.imageSymbol)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.horizontal)
    }

    private var symptomsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                icon: "exclamationmark.triangle.fill",
                title: "SYMPTOMS",
                color: .orange
            )

            ForEach(issue.symptoms, id: \.self) { symptom in
                bulletPoint(text: symptom, color: .orange)
            }
        }
        .padding(.horizontal)
    }

    private var causesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                icon: "questionmark.circle.fill",
                title: "Possible Cause",
                color: .yellow
            )

            ForEach(issue.causes, id: \.self) { cause in
                bulletPoint(text: cause, color: .yellow)
            }
        }
        .padding(.horizontal)
    }

    private var solutionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                icon: "checkmark.circle.fill",
                title: "Solution",
                color: .green
            )

            ForEach(issue.solutions, id: \.self) { solution in
                bulletPoint(text: solution, color: .green)
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }

    // MARK: - Helper Views

    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.headline)
                .foregroundColor(color)
        }
    }

    private func bulletPoint(text: String, color: Color) -> some View {
        HStack(alignment: .top) {
            Text("•")
                .foregroundColor(color)
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    NavigationView {
        IssueDetailView(issue: compostData[0].issues[0])
    }
}
