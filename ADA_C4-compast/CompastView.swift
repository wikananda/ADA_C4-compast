//
//  ContentView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 12/08/25.
//

import SwiftUI

struct CompastView: View {
    @State private var selectedTab: Int = 0 // to be inserted to custom tab bar
    @State private var showingSplash: Bool = true
    
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
            .background(Color.clear)
            .allowsHitTesting(!showingSplash)
            
            // the custom tab bar
            CustomTabView(selectedTab: $selectedTab)
                .padding(.horizontal)
                .padding(.bottom, 25)
                .opacity(showingSplash ? 0 : 1)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .background(Color.clear)
        .overlay(
            Group {
                if showingSplash {
                    SplashView()
//                        .transition(
//                            .slide.animation(.easeInOut(duration: 2).delay(1))
//                        )
                        .transition(
                            .opacity.animation(.easeInOut(duration: 0.5).delay(0.7))
                        )
                        .zIndex(1)
                }
            }
        )
        .task {
            // Simulate any startup work here (load persisted state, request permissions, etc.)
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            withAnimation(.easeOut(duration: 0.5)) {
                showingSplash = false
            }
        }
//        .safeAreaInset(edge: .bottom, spacing: 0) {
//            Color.clear.frame(height: 0)
//        }
    }
}

#Preview {
    CompastView()
}
