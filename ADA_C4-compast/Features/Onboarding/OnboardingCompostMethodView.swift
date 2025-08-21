//
//  OnboardingView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 12/08/25.
//

import SwiftUI


struct OnboardingTest: View {
    var text: String = "Onboarding test"
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        VStack {
            Text(text)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.5))
    }
}

struct StepperFlowCompostMethodView: View {
    @State var currentStep: Int = 1
    private let steps: [StepperFlow] = [
        StepperFlow(
            title: "Test 1",
            content: AnyView(OnboardingTest("This is onboarding test 1"))
            ),
        StepperFlow(
            title: "Test 2",
            content: AnyView(OnboardingTest("This is second view test of onboarding"))
            ),
        StepperFlow(
            title: "Test 3",
            content: AnyView(OnboardingTest("The third"))
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
                        .foregroundStyle(.blue)
                    }
                    .frame(maxWidth:100, alignment: .leading)
                    Text(steps[currentStep - 1].title)
                        .bold(true)
                        .frame(maxWidth: .infinity, alignment: .center)
                    // Ensure Text is at center (mind the maxWidth with the button's maxWidth)
                    Color.clear
                        .frame(maxWidth: 100, maxHeight: 1)
                }
                
                // The progress bar of onboarding
                StepperFlowProgressView(currentStep: $currentStep, totalSteps: steps.count)
                
                Spacer()
                
                Button(action: {
                    if currentStep < steps.count {
                        currentStep += 1
                    }
                }) {
                    if (currentStep == steps.count){
                        Text("Let's Go")
                    } else {
                        Text("Next")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .bold(true)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding()
        }
    }
}


#Preview {
    StepperFlowCompostMethodView()
}
