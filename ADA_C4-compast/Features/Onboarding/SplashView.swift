//
//  SplashView.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 25/08/25.
//

import SwiftUI

struct SplashView: View {
    // Animation states
    @State private var logoRotation: Double = -175
    @State private var logoYOffset: CGFloat = 64
    @State private var showText: Bool = false

    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                // MARK: Logo
                Image("brand/logo-light-green")
                    .rotationEffect(.degrees(logoRotation))
                    .offset(y: logoYOffset)
                    .animation(.spring(response: 1, dampingFraction: 0.85), value: logoRotation)
                    .animation(.easeOut(duration: 0.8), value: logoYOffset)

                // MARK: Text stack
                VStack(spacing: 8) {
                    Image("brand/logotext-light-green")

                    Text("Your Compost Assistant")
                        .font(.system(size: 20))
                        .fontWeight(.light)
                        .foregroundColor(Color("BrandLightGreen"))
                }
                // fade + slide up
                .opacity(showText ? 1 : 0)
                .offset(y: showText ? 0 : 32)
                .animation(.easeOut(duration: 0.8).delay(0.8), value: showText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.19, green: 0.37, blue: 0.23), location: 0.00),
                    .init(color: Color(red: 0.10, green: 0.22, blue: 0.13), location: 1.00),
                ],
                startPoint: UnitPoint(x: 1, y: 1.01),
                endPoint: UnitPoint(x: 0.5, y: 0)
            )
        )
        .task {
            // 1) Spin the logo to normal
            withAnimation {
                logoRotation = 0
            }

            // Wait until near the end of the spin
            try? await Task.sleep(nanoseconds: 750_000_000)

            // 2) Shift logo up to make room for text
            withAnimation {
                logoYOffset = -40
            }

            // Small overlap makes it feel snappier
            try? await Task.sleep(nanoseconds: 100_000_000)

            // 3) Reveal text with fade + slide
            withAnimation {
                showText = true
            }
        }
    }
}

#Preview {
    SplashView()
}
