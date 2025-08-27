//
//  UpdateTemperatureMoisture.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 26/08/25.
//

import SwiftUI


// MARK: - Combined Update Sheet

struct UpdateCompostVitalsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var step: Int = 0 // 0 = temp, 1 = moisture, 2 = success
    @State private var selectedTemp: Option?
    @State private var selectedMoist: Option?
    @State private var showCheck = false

    let compostItem: CompostItem
//    @Bindable var compostItem: CompostItem

    var backgroundColor: Color = Color(.systemGroupedBackground)

    // Reuse your Option model
    private let tempOptions: [Option] = [
        .init(icon: "thermometer.snowflake", title: "Cold",  subtitle: "(< 38°C) Room temperature", tint: .orange),
        .init(icon: "thermometer.medium",    title: "Warm",  subtitle: "(38°C - 65°C) Warm feeling", tint: .green),
        .init(icon: "thermometer.sun",       title: "Hot",   subtitle: "(> 65°C) Feels hot to touch", tint: .red)
    ]

    private let moistOptions: [Option] = [
        .init(icon: "drop.triangle", title: "Dry",   subtitle: "It is not enough damp.", tint: .orange),
        .init(icon: "drop",          title: "Humid", subtitle: "Soft and like a damp sponge", tint: .green),
        .init(icon: "drop.fill",     title: "Wet",   subtitle: "Water seems to be dripping", tint: .blue)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 16) {
                    // Progress indicator

                    if step == 0 {
                        OptionListScreen(
                            title: "How does the temperature feel?",
                            options: tempOptions,
                            backgroundColor: backgroundColor,
                            paddingTop: 0,
                            selected: $selectedTemp
                        )
                    } else if step == 1 {
                        OptionListScreen(
                            title: "Does it feel like a damp sponge (moisture)?",
                            options: moistOptions,
                            backgroundColor: backgroundColor,
                            paddingTop: 0,
                            selected: $selectedMoist
                        )
                    } else {
                        // Success
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 84, weight: .bold))
                                .foregroundStyle(Color("BrandGreenDark"))
                                .scaleEffect(showCheck ? 1.0 : 0.4)
                                .opacity(showCheck ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showCheck)

                            Text("Vitals Updated")
                                .font(.title2).bold()
                            Text("Logged on \(Date().ddMMyyyy())")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    Spacer(minLength: 0)

                    if step < 2 {
                        Button(action: nextOrSave) {
                            Text(step == 1 ? "Save" : "Next")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(isCurrentStepSelected ? Color("BrandGreenDark") : Color.gray.opacity(0.4))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                        .disabled(!isCurrentStepSelected)
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color("BrandGreenDark"))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(Color("BrandGreenDark"))
                }
            }
            .onAppear {
                // reset animation state
                showCheck = false
            }
        }
    }

    private var isCurrentStepSelected: Bool {
        switch step {
        case 0: return selectedTemp != nil
        case 1: return selectedMoist != nil
        default: return true
        }
    }

    private func nextOrSave() {
        if step == 0 {
            step = 1
            return
        }

        compostItem.temperatureCategory = selectedTemp?.title ?? compostItem.temperatureCategory
        compostItem.moistureCategory = selectedMoist?.title ?? compostItem.moistureCategory
        compostItem.lastLogged = Date()
        
        compostItem.recomputeAndStoreETA(in: context) //calculate

        try? context.save()

        // show success
        step = 2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation { showCheck = true }
        }
    }
}


#Preview {
    
    @Previewable @State var selectedTemp: Option?
    @Previewable @State var selectedMoist: Option?
    
    // Dummy for visualization
    let method = CompostMethod(
        compostMethodId: 1,
        name: "Hot Compost",
        descriptionText: "",
        compostDuration1: 30,
        compostDuration2: 180,
        spaceNeeded1: 1,
        spaceNeeded2: 4,
    )
    let compost = CompostItem(
        name: "Makmum Pile",
    )
    compost.compostMethodId = method
    let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)
    compost.creationDate = threeDaysAgo
//    compost.lastTurnedOver = threeDaysAgo
    compost.turnEvents = [TurnEvent(date: threeDaysAgo)]
    
    return UpdateCompostVitalsSheet(compostItem: compost)
}
