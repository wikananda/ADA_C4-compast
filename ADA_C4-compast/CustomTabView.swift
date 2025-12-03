//
//  CustomTabView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 13/08/25.
//

import SwiftUI

struct CustomTabView: View {
    @Binding var selectedTab: Int
    @Namespace private var tabNS
    
    var body: some View {
        HStack (alignment: .top) {
            CustomTabItem(
                iconName: "leaf.circle.fill",
                label: "My Compost",
                index: 0,
                selectedIndex: $selectedTab,
                ns: tabNS
            )
            Spacer()
            CustomTabItem(
                iconName: "checklist",
                label: "To Do",
                index: 1,
                selectedIndex: $selectedTab,
                ns: tabNS
            )
//            Spacer()
//            CustomTabItem(
//                iconName: "chart.xyaxis.line",
//                label: "Insight",
//                index: 2,
//                selectedIndex: $selectedTab,
//                ns: tabNS
//            )
            Spacer()
            CustomTabItem(
                iconName: "gearshape.fill",
                label: "Settings",
                index: 3,
                selectedIndex: $selectedTab,
                ns: tabNS
            )

        }
        .frame(maxWidth: 350, maxHeight: 60, alignment: .top)
        .padding(.vertical, 5)
        .padding(.horizontal, 5)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color("BrandGreenDark").opacity(0.1), lineWidth: 1)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: selectedTab)
    }
}

struct CustomTabItem: View {
    var iconName: String
    var label: String
    var index: Int
    
    @Binding var selectedIndex: Int
    var ns: Namespace.ID
    
    // To check current selected index
    private var isSelected: Bool { selectedIndex == index }
    
    var body: some View {
        Button(action: {
           withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                self.selectedIndex = index // changing the selected button
           }
        }) {
            ZStack {
                // Background for each tab item
                if isSelected {
                    Capsule()
                        .fill(Color.white)
                        .matchedGeometryEffect(id: "activeTabBG", in: ns)
                }
                // Layouting the button
               Color.clear
                   .padding(.vertical, 5)
                   .padding(.horizontal)
                
                // Tab item contents
                VStack(alignment: .center, spacing: 5) {
                    Image(systemName: iconName)
                        .font(.system(size: 17))
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
    @Previewable @State var selectedTab = 0
    CustomTabView(selectedTab: $selectedTab)
}
