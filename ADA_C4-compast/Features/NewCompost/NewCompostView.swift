//
//  NewCompostView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 20/08/25.
//

import SwiftUI
import SwiftData

// MARK: New Compost Sub-Onboarding Views
struct NewNameView: View {
    @Binding var name: String?
    var body: some View {
        TextField("Name your compost", text: Binding(
            get: { name ?? "" },
            set: { name = $0.isEmpty ? nil : $0 }
        ))
        .padding()
        .border(Color.secondary, width: 2)
    }
}

struct NewMethodView: View {
    @Binding var selectedMethod: String?
    var body: some View {
        VStack(spacing: 20) {
            Button(action: { selectedMethod = "Hot Compost" }) {
                Text("Hot Compost")
            }
            Button(action: { selectedMethod = "Cold Compost" }) {
                Text("Cold Compost")
            }
            Button(action: { selectedMethod = "Tumblr" }) {
                Text("Tumblr")
            }
        }
    }
}

struct NewSpaceView: View {
    @Binding var selectedSpace: String?
    var body: some View {
        VStack(spacing: 20) {
            Button(action: { selectedSpace = "Tiny spot" }) {
                Text("Tiny spot")
            }
            Button(action: { selectedSpace = "Room to grow" }) {
                Text("Room to grow")
            }
            Button(action: { selectedSpace = "Plenty of land" }) {
                Text("Plenty of land")
            }
        }
    }
}

struct NewContainerView: View {
    @Binding var selectedContainer: String?
    var body: some View {
        VStack(spacing: 20) {
            Button(action: { selectedContainer = "Barrel" }) {
                Text("Barrel")
            }
            Button(action: { selectedContainer = "Trash Stack" }) {
                Text("Trash Stack")
            }
            Button(action: { selectedContainer = "Open Field" }) {
                Text("Open Field")
            }
        }
    }
}


// MARK: Main views holder
struct NewCompostView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State var currentStep: Int = 1
    
    @State var name: String?
    @State var selectedMethod: String?
    @State var selectedSpace: String?
    @State var selectedContainer: String?
    
    private var steps: [StepperFlow] {
        [
            StepperFlow(
                title: "New Compost",
                content: AnyView(NewNameView(name: $name))
            ),
            StepperFlow(
                title: "Methods",
                content: AnyView(NewMethodView(selectedMethod: $selectedMethod))
            ),
            StepperFlow(
                title: "Spaces",
                content: AnyView(NewSpaceView(selectedSpace: $selectedSpace))
            ),
            StepperFlow(
                title: "Containers",
                content: AnyView(NewContainerView(selectedContainer: $selectedContainer))
            ),
        ]
    }
    
    var body: some View {
        ZStack {
            steps[currentStep - 1].content // Onboarding content
            VStack(alignment: .leading) {
                // Header Titles and Back buttons
                HStack {
                    Button(action: {
                        if currentStep > 1 {
                            currentStep -= 1
                            return
                        }
                        dismiss()
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
                
                Button(action: ButtonAction) {
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
    
    // For the button function
    func ButtonAction() {
        if currentStep < steps.count {
            currentStep += 1
            return
        }
        AddNewCompost()
    }
    
    // Saving to SwiftData
    func AddNewCompost() {
        guard
            let writtenName = name,
            let methodName = selectedMethod,
            let spaceName = selectedSpace,
            let containerName = selectedContainer
        else {
            return
        }
        
        let methodId = Int(Date().timeIntervalSince1970)
        
        let method = CompostMethod(
            compostMethodId: methodId,
            name: methodName,
            descriptionText: "\(spaceName) - \(containerName)",
            compostDuration1: 30,
            compostDuration2: 180,
            spaceNeeded1: 1,
            spaceNeeded2: 4,
        )
        
        let item = CompostItem(
            name: writtenName,
            temperature: 27,
            moisture: 40,
        )
        item.compostMethodId = method // update method
        modelContext.insert(method)
        modelContext.insert(item)
        
        print("Created new compost item with id: \(item.compostItemId)")
        print("method: \(method.name), \(method.descriptionText)")
        print("item: \(item.name), \(item.temperature), \(item.moisture)")
        
        dismiss()
    }
}

#Preview {
    NewCompostView()
}
