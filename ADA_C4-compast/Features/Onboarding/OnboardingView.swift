//
//  OnboardingView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 12/08/25.
//

import SwiftUI

struct StepperFlow {
    let id = UUID()
    let title: String
    let content: AnyView
}

struct OnboardingInfo: View {
    var title: String = "Title"
    var description : String = "Description"
    var image : String = "image"
    
    init(_ title: String, _ description: String, _ image: String) {
        self.title = title
        self.description = description
        self.image = image
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Foreground content only
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.0),
                                    Color.white.opacity(1.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 300)               // height only
                        .frame(maxWidth: .infinity)       // stretch horizontally

                    Image("onboarding/compast-logo-dark-green")
                        .padding(.bottom, 24)
                }

                VStack(spacing: 16) {
                    Text(title).multilineTextAlignment(.center)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text(description).multilineTextAlignment(.center)
                }
                .padding(.top, 12)
                .padding(.horizontal, 32)
                .background(Color.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack(alignment: .bottom){
                    Image(image)
                        .resizable()
                        .scaledToFill()           // fill screen under safe areas
                Rectangle()
                    .fill(Color.white)
                    .frame(width: .infinity, height: 300)
                   
            }
                .ignoresSafeArea()
        )

    }
}

struct StepperFlowView: View {
    @State var currentStep: Int = 1
    
    
    private let steps: [StepperFlow] = [
        StepperFlow(
            title: "Test 1",
            content: AnyView(OnboardingInfo("What is Composting?", "Composting transforms food scraps and garden waste into rich, fertile soil.", "onboarding/what-is-composting"))
            ),
        StepperFlow(
            title: "Test 2",
            content: AnyView(OnboardingInfo("What is Composting?", "Composting transforms food scraps and garden waste into rich, fertile soil.", "onboarding/why-compost"))
            ),
        StepperFlow(
            title: "Test 3",
            content: AnyView(OnboardingInfo("What is Composting?", "Composting transforms food scraps and garden waste into rich, fertile soil.", "onboarding/how-it-works"))
            ),
    ]
    
    var body: some View {
        ZStack {
                
            steps[currentStep - 1].content // Onboarding content
            VStack(alignment: .leading) {
                // Header Titles and Back buttons
                HStack {
                    Button(action: {
                        if currentStep > 1 {
                            currentStep -= 1
                        }
                    } ) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundStyle(Color.white)
                    }
                    .frame(maxWidth:100, alignment: .leading)
                    Text(steps[currentStep - 1].title)
                        .bold(true)
                        .frame(maxWidth: .infinity, alignment: .center)
                    // Ensure Text is at center (mind the maxWidth with the button's maxWidth)
                    Color.clear
                        .frame(maxWidth: 100, maxHeight: 1)
                }
                
                Spacer()
                
                // The progress bar of onboarding
                StepperFlowProgressView(currentStep: $currentStep, totalSteps: steps.count)
                
//                Spacer()
                
                Button(action: {
                    if currentStep < steps.count {
                        currentStep += 1
                    }
                }) {
                    if (currentStep == steps.count){
                        Text("Let's Go")
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("BrandGreenDark"))
                .bold(true)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding()
        }
    }
}

struct StepperFlowInfoProgressView: View {
    @Binding var currentStep: Int
    var totalSteps: Int
    
    var body: some View {
        HStack(alignment: .center , spacing: 8){
            ForEach(1...totalSteps, id: \.self) { step in
                Rectangle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(step <= currentStep ? Color("BrandGreen") : .gray)
                    .clipShape(Capsule())
            }
        }
        .padding(.bottom, 24)
        .padding(.horizontal, 24)
    }
}

#Preview {
    StepperFlowView()
    
}
