//
//  CustomTabView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 13/08/25.
//

import SwiftUI

struct CustomTabView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack (alignment: .top) {
            CustomTabItem(
                iconName: "leaf.circle.fill",
                label: "My Compost",
                index: 0,
                selectedIndex: $selectedTab,
            )
            Spacer()
            CustomTabItem(
                iconName: "checklist",
                label: "To Do",
                index: 1,
                selectedIndex: $selectedTab,
            )
            Spacer()
            CustomTabItem(
                iconName: "gearshape.fill",
                label: "Settings",
                index: 2,
                selectedIndex: $selectedTab,
            )

        }
        .frame(maxWidth: 300, maxHeight: 60, alignment: .top)
        .padding(.vertical, 9)
        .padding(.horizontal, 10)
        .background(
            .ultraThinMaterial
        )
        .clipShape(Capsule())
    }
}

struct CustomTabItem: View {
    var iconName: String
    var label: String
    var index: Int
    
    @Binding var selectedIndex: Int
    
    // To check current selected index
    private var isSelected: Bool {
        selectedIndex == index
    }
    
    var body: some View {
        Button(action: {
            self.selectedIndex = index // changing the selected button
        }) {
            ZStack {
                // Background for each tab item
                Color.clear
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background(isSelected ? .white : .clear)
                    .clipShape(Capsule())
                
                // Tab item contents
                VStack(alignment: .center, spacing: 5) {
                    Image(systemName: iconName)
                        .font(.system(size: 17))
                    Text(label)
                        .frame(maxWidth: 75)
                        .multilineTextAlignment(.center)
                        .font(.caption2)
                }
            }
            .foregroundStyle(isSelected ? .black : .gray)
        }
    }
}

#Preview {
    @State var selectedTab = 0
    CustomTabView(selectedTab: $selectedTab)
}
