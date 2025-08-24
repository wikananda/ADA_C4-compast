//
//  ContentView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 12/08/25.
//

import SwiftUI

struct CompastView: View {
    @State private var selectedTab: Int = 0 // to be inserted to custom tab bar
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                switch selectedTab {
                case 0:
                    YourCompostsView()
//                        .modelContainer(previewContainer)
                case 1:
                    Text("Your tasks")
                default:
                    SettingsView()
                }
            }
            .frame(maxWidth:.infinity, maxHeight: .infinity)
            
            // the custom tab bar
            CustomTabView(selectedTab: $selectedTab)
                .padding(.horizontal)
                .padding(.bottom, 25)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color.clear)
//        .safeAreaInset(edge: .bottom, spacing: 0) {
//            Color.clear.frame(height: 0)
//        }
    }
}

#Preview {
    CompastView()
}
