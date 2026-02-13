//
//  SettingsMain.swift
//  ADA_C4-compast
//
//  Created by Olaffiqih Wibowo on 21/08/25.
//
//  Refactored to MVVM Architecture
//  - Data models moved to Settings/Data/CompostIssueData.swift
//  - ViewModels in Settings/ViewModels/
//  - Sub-views in Settings/Views/
//

import SwiftUI

// MARK: - Settings View

/// Main settings view with MVVM architecture.
struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerSection
            settingsOptions
            Spacer()
//            footerSection
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(spacing: 10) {
            Image("compost/logo-dark-green")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 32)
            Text("My Compost")
                .font(.custom("KronaOne-Regular", size: 20))
                .foregroundStyle(Color("BrandGreenDark"))
        }
        .padding()
        .padding(.bottom, 20)
    }

    // MARK: - Settings Options

    private var settingsOptions: some View {
        VStack(spacing: 0) {
            contactLink
            Divider()
            helpLink
            Divider()
            languageToggle
            Divider()
            notificationToggle
            Divider()
            feedbackLink
            Divider()
            rateAppRow
        }
    }

    private var helpLink: some View {
        NavigationLink(destination: HelpView()) {
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.secondary)
                Text("Compost Help")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .accentColor(.black)
    }

    private var languageToggle: some View {
        HStack {
            Image(systemName: "globe")
                .foregroundColor(.secondary)
            Text("Language")
            Spacer()
            languageSelector
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var languageSelector: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 138, height: 36)

            HStack(spacing: 0) {
                languageButton(flag: "🇬🇧", code: "EN", isSelected: !viewModel.isIndonesian) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleLanguage(toIndonesian: false)
                    }
                }

//                Spacer()

                languageButton(flag: "🇮🇩", code: "ID", isSelected: viewModel.isIndonesian) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.toggleLanguage(toIndonesian: true)
                    }
                }
            }
            .frame(width: 140)
        }
    }

    private func languageButton(flag: String, code: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Text("\(flag) \(code)")
            .font(.system(size: 14, weight: .medium))
            .frame(width: 60, height: 30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white : Color.clear)
            )
            .foregroundColor(isSelected ? .black : .gray)
            .onTapGesture(perform: action)
            .padding(.horizontal, 4)
    }

    private var notificationToggle: some View {
        HStack {
            Image(systemName: "bell")
                .foregroundColor(.secondary)
            Text("Notification")
            Spacer()
            Toggle("", isOn: Binding(
                get: { viewModel.notificationsEnabled },
                set: { viewModel.toggleNotifications($0) }
            ))
            .labelsHidden()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var feedbackLink: some View {
        NavigationLink(destination: FeedbackView()) {
            HStack {
                Image(systemName: "bubble.left")
                    .foregroundColor(.secondary)
                Text("Feedback")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .accentColor(.black)
        }
    }

    private var rateAppRow: some View {
        Button(action: viewModel.openAppStoreRating) {
            HStack {
                Image(systemName: "star")
                    .foregroundColor(.secondary)
                Text("Rate Compost")
                    .foregroundColor(.primary)
                Spacer()
                Text("Version \(viewModel.appVersion)")
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(alignment: .center) {
            Link("Contact us <3", destination: URL(string: "https://linktr.ee/compast_ada")!)
                .font(.body)
                .foregroundStyle(Color("BrandGreen"))
                .underline()
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 110)
    }
    private var contactLink: some View {
        Link(destination: URL(string: "https://linktr.ee/compast_ada")!) {
            HStack {
                Image(systemName: "phone")
                    .foregroundColor(.secondary)
                Text("Contact Compast Team")
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .accentColor(.black)
    }

}

// MARK: - Previews

#Preview {
    NavigationView {
        SettingsView()
    }
}
