//
//  OptionListScreen.swift
//  ADA_C4-compast
//
//  Shared Component - Reusable Option List Layout
//

import SwiftUI

/// A reusable screen layout for displaying a list of selectable options.
/// Used in wizard flows and onboarding screens.
struct OptionListScreen: View {
    let title: String
    let options: [Option]
    var backgroundColor: Color = Color(.systemGroupedBackground)
    var paddingTop: CGFloat = 100
    var paddingBottom: CGFloat = 120
    @Binding var selected: Option?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12)

                ForEach(options) { option in
                    OptionCard(option: option, selected: $selected)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, paddingTop)
            .padding(.bottom, paddingBottom)
        }
        .background(backgroundColor)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: Option?

        private let options: [Option] = [
            .init(icon: "sun.max.fill", title: "Everyday", subtitle: "Faster compost, more effort", tint: .yellow),
            .init(icon: "arrow.3.trianglepath", title: "Every 3 Days", subtitle: "Slower compost, less effort", tint: .green),
            .init(icon: "calendar", title: "Once a week", subtitle: "Slowest compost, minimal effort", tint: .blue)
        ]

        var body: some View {
            OptionListScreen(
                title: "How much time will you spend composting?",
                options: options,
                paddingTop: 60,
                paddingBottom: 80,
                selected: $selected
            )
        }
    }

    return PreviewWrapper()
}
