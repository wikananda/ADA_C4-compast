//
//  HelpView.swift
//  ADA_C4-compast
//
//  Settings Module - Help View
//

import SwiftUI

/// Help view displaying compost issue categories and search.
struct HelpView: View {
    @State private var viewModel = HelpViewModel()

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            categoriesSection
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hello there,")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Is there anything we can help you with about composting?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                helpIcon
            }

            searchBar
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
    }

    private var helpIcon: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                .frame(width: 60, height: 60)
            Text("?")
                .font(.title)
                .fontWeight(.bold)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search Issues", text: $viewModel.searchText)

            if viewModel.isSearching {
                Button(action: viewModel.clearSearch) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Categories")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            List {
                ForEach(viewModel.filteredCategories) { category in
                    NavigationLink(destination: CategoryDetailView(category: category)) {
                        HStack {
                            Image(systemName: category.icon)
                                .frame(width: 24)
                            Text(category.name)
                            Spacer()
                            Text("\(category.issues.count)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

#Preview {
    NavigationView {
        HelpView()
    }
}
