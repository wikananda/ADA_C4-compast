//
//  UpdateTemperature.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 22/08/25.
//

import SwiftUI

struct UpdateMoistureView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Binding var selectedMoist: Option?
    let compostItem: CompostItem
    
    var backgroundColor: Color = Color(.systemGroupedBackground)
    
    private var anySelected: Bool {
        return !((selectedMoist?.title.isEmpty) == nil)
    }
    
    private let options: [Option] = [
        .init(icon: "square.split.bottomrightquarter.fill",
              title: "Dry",
              subtitle: "It is not enough damp.",
              tint: .orange),
        .init(icon: "square.dashed.inset.filled",
              title: "Humid",
              subtitle: "Soft and like a damp sponge",
              tint: .green),
        .init(icon: "ruler",
              title: "Wet",
              subtitle: "Water seems to be dripping",
              tint: .blue)
    ]
    var body: some View {
        NavigationStack {
            VStack {
                OptionListScreen(
                    title: "Does it feel like a damp sponge (moisture)?",
                    options: options,
                    backgroundColor: backgroundColor,
                    paddingTop: 25,
                    selected: $selectedMoist,
                )
                Spacer()
                Button(action: {
                    compostItem.moistureCategory = selectedMoist?.title ?? "Dry"
                    compostItem.lastLogged = Date()
                    try? context.save()
                    dismiss()
                }) {
                    Text("Next")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(anySelected ? Color("BrandGreenDark") : Color.gray.opacity(0.4))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding(.horizontal, 16)
                .padding(.bottom, 50)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .foregroundStyle(Color("BrandGreenDark"))
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .background(backgroundColor)
        }
    }
}

struct UpdateTemperatureView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Binding var selectedTemp: Option?
    let compostItem: CompostItem
    
    var backgroundColor: Color = Color(.systemGroupedBackground)
    
    private var anySelected: Bool {
        return !((selectedTemp?.title.isEmpty) == nil)
    }
    
    private let options: [Option] = [
        .init(icon: "square.split.bottomrightquarter.fill",
              title: "Cold",
              subtitle: "(< 38°C) Room temperature",
//              subtitle: "(< 38°C) Still in room temperature. Not good.",
              tint: .orange),
        .init(icon: "square.dashed.inset.filled",
              title: "Warm",
              subtitle: "(38°C - 65°C) Warm feeling",
//              subtitle: "(38°C - 65°C) Bacteria is thriving at this temperature",
              tint: .green),
        .init(icon: "ruler",
              title: "Hot",
              subtitle: "(> 65°C) Feels hot to touch",
//              subtitle: "(> 65°C) Bacteria will die! Add more brown waste, or add more water",
              tint: .blue)
    ]
    var body: some View {
        NavigationStack {
            VStack {
                OptionListScreen(
                    title: "How does the temperature feel?",
                    options: options,
                    backgroundColor: backgroundColor,
                    paddingTop: 25,
                    selected: $selectedTemp
                )
                
                Spacer()
                Button(action: {
                    compostItem.temperatureCategory = selectedTemp?.title ?? "Warm"
                    compostItem.lastLogged = Date()
                    try? context.save()
                    dismiss()
                }) {
                    Text("Next")
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(anySelected ? Color("BrandGreenDark") : Color.gray.opacity(0.4))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding(.horizontal, 16)
                .padding(.bottom, 50)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .foregroundStyle(Color("BrandGreenDark"))
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .background(backgroundColor)
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
    compost.lastTurnedOver = threeDaysAgo
    
    return UpdateTemperatureView(selectedTemp: $selectedTemp, compostItem: compost)
//    return UpdateMoistureView(selectedMoist: $selectedMoist, compostItem: compost)
}
