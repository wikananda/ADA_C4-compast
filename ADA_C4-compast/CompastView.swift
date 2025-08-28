//
//  ContentView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 12/08/25.
//

import SwiftUI

struct CompastView: View {
    @State private var selectedTab: Int = 0
    @State private var showingSplash: Bool = true
    @StateObject private var taskStore = CompostTaskStore()

    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case 0:
                    YourCompostsView()
                case 1:
                    CompostToDoListView()
//                    CompostToDoListView(composts: [CompostItem(name: "pile")])
                case 2:
                    SettingsView()
                    
                case 3:
                    SettingsView()
                default:
                    YourCompostsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.spring(response: 0.35, dampingFraction: 0.65), value: selectedTab)
            .allowsHitTesting(!showingSplash)
            .onChange(of: selectedTab) { _, newValue in
                print(">>> selectedTab: %d\n", newValue)
            }

            // Custom tab bar
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
