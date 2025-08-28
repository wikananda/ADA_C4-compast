//
//  NewCompostView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 20/08/25.
//

import SwiftUI
import SwiftData


struct Option: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
}

/// Card row that matches the reference style
struct OptionCard: View {
    let option: Option
    @Binding var selected: Option?

    private var isSelected: Bool { selected == option }
    private var accent: Color { Color("BrandGreen") }

    var body: some View {
        Button {
            selected = option
        } label: {
            HStack(spacing: 14) {
                // Leading icon badge
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(option.tint.opacity(0.25), lineWidth: 2)
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(option.tint.opacity(0.08)))
                    Image(systemName: option.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(option.tint)
                }
                .frame(width: 36, height: 36)

                // Title & subtitle
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(option.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Radio → check
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? accent : .secondary.opacity(0.4))
            }
            .padding(16)
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .background(
                // base card + selected tint like the mock
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? accent.opacity(0.08) : .white)
                    .shadow(color: .black.opacity(0.06), radius: 12, y: 4)
            )
            .overlay(
                // selected border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? accent : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: isSelected)
    }
}


// Convenience to read a named color with fallback
extension Color {
    init(_ name: String, default fallback: Color) {
        self = Color(name, bundle: .main) ?? fallback
    }
}


// Common layout for “list of options” screens
struct OptionListScreen: View {
    let title: String
    let options: [Option]
    var backgroundColor: Color = Color(.systemGroupedBackground)
    var paddingTop: CGFloat = 100
    var paddingBottom: CGFloat = 120
    @Binding var selected: Option?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text(title)
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12)
                
                ForEach(options) { opt in
                    OptionCard(option: opt, selected: $selected)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, paddingTop)
            .padding(.bottom, paddingBottom) // room for sticky button
        }
        .background(backgroundColor)
    }
}

// MARK: New Compost Sub-Onboarding Views
struct NewNameView: View {
    @Binding var name: String?
    var body: some View {
        VStack( spacing: 100) {
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
            
            Image("onboarding/guy-doing-compost")
                .resizable()
                .frame(maxWidth: .infinity, alignment: .center)
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea(.container, edges: .bottom)
        }
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
    @Query private var compostMethods: [CompostMethod]
    
    @State var currentStep: Int = 1
    
    @State var name: String?
    @State var selectedMethod: Option?
    @State var selectedSpace: Option?
    @State var selectedContainer: Option?
    
    private var isNameValid: Bool {
        guard let name = name else { return false }
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var steps: [StepperFlow] {
        [
            StepperFlow(
                title: "New Compost",
                content: AnyView(NewNameView(name: $name))
            ),
        ]
    }
    
    var body: some View {
        ZStack (alignment: .bottom) {
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
                        }
                        .foregroundStyle(Color("BrandGreenDark"))                    }
                    .frame(maxWidth:100, alignment: .leading)
                    
                    Spacer()
                }
                .overlay(
                    Text(steps[currentStep - 1].title)
                        .bold(true)
                        .font(.custom("KronaOne-Regular", size: 16))
                        .foregroundStyle(Color("BrandGreenDark")),
                    alignment: .center
                )
                
                // The progress bar of onboarding
                
                Spacer()
                
                Button(action: ButtonAction) {
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
                .background(isNameValid ? Color("BrandGreenDark") : Color.gray.opacity(0.4))
                .bold(true)
                .foregroundStyle(.white)
                .clipShape(Capsule())
//                .buttonStyle(PlainButtonStyle())
//                .background(
//                    Color.white
//                        .clipShape(Capsule())
//                )
            }
            .padding()
            .padding(.bottom, 25)
        }
        .ignoresSafeArea(.container, edges: .bottom)
        .ignoresSafeArea(.keyboard)
        .background(Color.clear)
    }
    
    // For the button function
    func ButtonAction() {
        if currentStep < steps.count {
            currentStep += 1
            return
        }
        print("Here")
        guard isNameValid else { return }
        print("HEEEREE name valid")
        
        AddNewCompost()
    }
    
    // Saving to SwiftData
    func AddNewCompost() {
        guard
            let writtenName = name
//            let methodName = selectedMethod,
//            let spaceName = selectedSpace,
//            let containerName = selectedContainer
        else {
            return
        }
        print("Hereee adding new compost")
        
        guard let method = compostMethods.first(where: { $0.compostMethodId == 1 }) else {
            print("❌ No predefined compost method found")
            return
        }
        
        let item = CompostItem(
            name: writtenName,
        )
        item.compostMethodId = method // 1 is hot compost (predefined)
        modelContext.insert(item)

        do {
            try modelContext.save()
            print("✅ Successfully saved new compost item with id: \(item.compostItemId)")
            print("item: \(item.name), \(item.temperatureCategory), \(item.moistureCategory)")
            dismiss()
        } catch {
            print("❌ Failed to save: \(error)")
            // Optionally show an alert to the user
        }
    }
}

#Preview {
    NewCompostView()
}
