//
//  UpdateTemperature.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 22/08/25.
//

import SwiftUI

struct CompostOnboardInfo: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State var currentStep: Int = 1
    
    var backgroundColor: Color = Color(.systemGroupedBackground)
    
    
    
    private let steps: [StepperFlow] = [
        StepperFlow(
            title: "Brown + Green = Compost",
            content: AnyView(CompostOnboardInfoItem("Brown + Green = Compost", "Compost needs a mix of brown (carbon-rich) and green (nitrogen-rich) materials. Aim for about 3 parts brown to 1 part green for best results.", "compost/onboarding-compost-1"))
            ),
        StepperFlow(
            title: "What Are Browns?",
            content: AnyView(CompostOnboardInfoItem("What Are Browns?", "Browns are dry, carbon-rich items that give compost structure.\n\nDry Leaves\nTwigs\nCardboard\nShredded paper\nSawdust", "compost/onboarding-compost-2"))
            ),
        StepperFlow(
            title: "What Are Greens?",
            content: AnyView(CompostOnboardInfoItem("What Are Greens?", "Greens are fresh, nitrogen-rich items that fuel decomposition.\n\n", "compost/onboarding-compost-3"))
            ),
        StepperFlow(
            title: "Tap Material Layer to Shred it",
            content: AnyView(CompostOnboardInfoItem("Tap Material Layer to Shred it", "Smaller pieces decompose faster. Chop food scraps, shred cardboard, or break twigs before adding them. This gives microbes more surface to work on, meaning quicker and smoother composting.", "compost/onboarding-compost-4"))
            ),
        StepperFlow(
            title: "Press 􀁝 at right",
            content: AnyView(CompostOnboardInfoItem("Press 􀁝 at right side to show the description again.", "Let’s get started!", "compost/onboarding-compost-5"))
            ),
    ]
    
    
    var body: some View {
        NavigationStack {
            VStack {
                
                steps[currentStep - 1].content // Onboarding content
                
                Spacer()
                
                // The progress bar of onboarding
                StepperFlowProgressView(currentStep: $currentStep, totalSteps: steps.count)
                
                
                
                    if (currentStep == steps.count){
                        
                        HStack{
                            Button(action: {
                                if currentStep > 1  {
                                    currentStep -= 1
                                }
                            }) {
                                Text("Back")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .bold(true)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            
                            Button(action: {
                                
                                dismiss()
                                }) {
                                    Text("Let's Go")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("BrandGreenDark"))
                                .bold(true)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        
                        
                    } else {
                        
                        HStack{
                                
                            Button(action: {
                                if currentStep > 1  {
                                    currentStep -= 1
                                }
                            }) {
                                Text("Back")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .bold(true)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            
                            Button(action: {
                                if currentStep < steps.count {
                                    currentStep += 1
                                }
                            }) {
                                Text("Next")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("BrandGreenDark"))
                            .bold(true)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                            
                        }
                    }
                
                
                
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .foregroundStyle(Color("BrandGreenDark"))
                    }
                }
            }
            .padding()
            .background(backgroundColor)
        }
    }
}


#Preview {
    CompostOnboardInfo()
}


struct CompostOnboardInfoItem: View {
    var title: String = "Title"
    var description : String = "Description"
    var image : String = "image"
    
    init(_ title: String, _ description: String, _ image: String) {
        self.title = title
        self.description = description
        self.image = image
    }
    
    var body: some View {
            VStack(spacing: 0) {

                VStack(spacing: 24) {
                    Text(title).multilineTextAlignment(.leading)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    
                    Image(image)
                        .resizable()
                        .scaledToFit()
                    
                    Text(description).multilineTextAlignment(.leading)
                        .foregroundStyle(Color.black.opacity(0.6))
                }
            }
            .padding(.top, 24)

    }
}


