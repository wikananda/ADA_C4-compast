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
                iconName: "arrow.up.bin.fill",
                label: "Your Containers",
                index: 0,
                selectedIndex: $selectedTab,
            )
            Spacer()
            CustomTabItem(
                iconName: "rectangle.and.text.magnifyingglass",
                label: "Analyze",
                index: 1,
                selectedIndex: $selectedTab,
            )
            Spacer()
            CustomTabItem(
                iconName: "text.document.fill",
                label: "History",
                index: 2,
                selectedIndex: $selectedTab,
            )
        }
        .frame(maxWidth: .infinity, maxHeight: 60)
        .padding(.vertical, 5)
        .padding(.horizontal)
        .background(Color.gray.opacity(0.2))
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
                    .background(isSelected ? .gray.opacity(0.5) : .clear)
                    .clipShape(Capsule())
                
                // Tab item contents
                VStack(alignment: .center, spacing: 5) {
                    Image(systemName: iconName)
                        .font(.system(size: 20))
                    Text(label)
                        .frame(maxWidth: 75)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 10))
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
