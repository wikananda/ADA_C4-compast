//
//  NewCompostView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 20/08/25.
//

import SwiftUI
import SwiftData

// Option, OptionCard, and OptionListScreen are now in Shared/Components

// MARK: New Compost Sub-Onboarding Views
struct NewNameView: View {
    @Binding var name: String?
    var body: some View {
        VStack( spacing: 150) {
            VStack(alignment: .leading){
                Text("Compost Name")
                    .font(.headline)
                    .foregroundStyle(Color("BrandGreenDark"))
                TextField("Name your compost...", text: Binding(
                    get: { name ?? "" },
                    set: { name = $0.isEmpty ? nil : $0 }
                ))
                .padding()
//                .border(Color.black.opacity(0.1), width: 2)
                .background(Color.white)
                .cornerRadius(20)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("BrandGreenDark").opacity(0.25), lineWidth: 2)
                        .fill(Color("BrandGreenDark"))
                }
            }
            .padding(.horizontal, 32)
            
            Image("onboarding/guys-doing-compost")
                .resizable()
                .frame(maxWidth: .infinity, alignment: .center)
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

struct NewCompostReadyView: View {
    var name: String?
    var body: some View {
        VStack(spacing: 100) {
            VStack(alignment: .center, spacing: 20){
                Text("Your \(name ?? "") compost is ready!")
                    .frame(width: 300)
                    .multilineTextAlignment(.center)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color("BrandGreenDark"))
                Text("Start composting today!")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 32)
            
            Image("onboarding/guys-making-compost")
                .resizable()
                .frame(maxWidth: .infinity, alignment: .center)
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea(.container, edges: .bottom)
                
        }
        .ignoresSafeArea(.container, edges:.bottom)
    }
}

struct OnboardingCompostOption: View {
    var icon: String = "sun.max"
    var title: String = "Sunny"
    var description: String = "Sunny day"
    @State var isSelected: Bool = false
    
    init(_ icon: String, _ title: String, _ description: String) {
        self.icon = icon
        self.title = title
        self.title = description
    }
    
    var body: some View {
        HStack{
            
            Image(systemName: icon)
            
            VStack(alignment: .leading){
                Text(title).font(.headline)
                Text(description).font(.caption)
            }
        }
    }
}

struct NewMethodView: View {
    @Binding var selectedMethod: Option?
    
    private let options: [Option] = [
           .init(icon: "sun.max.fill",
                 title: "Everyday",
                 subtitle: "Faster compost, but requires more effort",
                 tint: .yellow),
           .init(icon: "arrow.3.trianglepath",
                 title: "Every 3 Days",
                 subtitle: "Slower compost, but less effort",
                 tint: .green),
           .init(icon: "calendar",
                 title: "Once a week",
                 subtitle: "Slowest compost, but minimal effort",
                 tint: .blue)
       ]
    
    var body: some View {
        
        OptionListScreen(
                    title: "How much time will you spend composting?",
                    options: options,
                    selected: $selectedMethod
                )
    }
}


struct NewSpaceView: View {
    @Binding var selectedSpace: Option?
    private let options: [Option] = [
        .init(icon: "square.split.bottomrightquarter.fill",
              title: "Tiny spot",
              subtitle: "< 1m² (e.g., Balcony, small yard corner)",
              tint: .orange),
        .init(icon: "square.dashed.inset.filled",
              title: "Room to grow",
              subtitle: "1m² – 2m² (e.g., small garden bed)",
              tint: .green),
        .init(icon: "ruler",
              title: "Plenty of land",
              subtitle: "> 3m² (e.g., Backyard, field)",
              tint: .blue)
    ]
    var body: some View {
        OptionListScreen(
            title: "How much space do you have for composting?",
            options: options,
            selected: $selectedSpace
        )
    }
}

struct NewContainerView: View {
    @Binding var selectedContainer: Option?
    private let options: [Option] = [
        .init(icon: "shippingbox",
              title: "Barrel",
              subtitle: "Closed barrel with aeration holes",
              tint: .green),
        .init(icon: "trash",
              title: "Trash stack",
              subtitle: "Layered bin with browns & greens",
              tint: .orange),
        .init(icon: "leaf",
              title: "Open field",
              subtitle: "Windrow or open pile",
              tint: .blue)
    ]
    var body: some View {
        OptionListScreen(
            title: "Choose your container type",
            options: options,
            selected: $selectedContainer
        )
    }
}


// MARK: Main views holder
struct NewCompostView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - ViewModel
    @State private var viewModel: NewCompostViewModel

    init() {
        // ViewModel will be properly initialized in onAppear with modelContext
        _viewModel = State(initialValue: NewCompostViewModel(
            modelContext: ModelContext(try! ModelContainer(for: CompostItem.self))
        ))
    }

    // Legacy computed properties delegating to ViewModel
    private var isNameValid: Bool { viewModel.isNameValid }

    private var steps: [StepperFlow] {
        [
            StepperFlow(
                title: "New Compost",
                content: AnyView(NewNameView(name: $viewModel.name))
            ),
            StepperFlow(
                title: "", content: AnyView(NewCompostReadyView(name: viewModel.name))
            )
        ]
    }
    
    var body: some View {
        ZStack (alignment: .bottom) {
            steps[viewModel.currentStep - 1].content // Onboarding content
            VStack(alignment: .leading) {
                // Header Titles and Back buttons
                HStack {
                    Button(action: {
                        if viewModel.goBack() {
                            dismiss()
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                        }
                        .foregroundStyle(Color("BrandGreenDark"))
                    }
                    .frame(maxWidth:100, alignment: .leading)

                    Spacer()
                }
                .overlay(
                    Text(viewModel.stepTitle)
                        .bold(true)
                        .font(.custom("KronaOne-Regular", size: 16))
                        .foregroundStyle(Color("BrandGreenDark")),
                    alignment: .center
                )

                // The progress bar of onboarding

                Spacer()

                Button(action: {
                    if viewModel.handleButtonAction() {
                        dismiss()
                    }
                }) {
                    Text(viewModel.buttonTitle)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isNameValid ? Color("BrandGreenDark") : Color.gray.opacity(0.4))
                .bold(true)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
            .padding()
            .padding(.bottom, 25)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .ignoresSafeArea(.keyboard)
        .background(Color.clear)
        .onAppear {
            // Re-initialize with correct context
            viewModel = NewCompostViewModel(modelContext: modelContext)
        }
    }
}

#Preview {
    NewCompostView()
}
