//
//  CompostCard.swift
//  ADA_C4-compast
//
//  Created by Olaffiqih Wibowo on 21/08/25.
//

import SwiftUI


// MARK: - Compost Card View
struct CompostCard: View {
    @Environment(\.modelContext) var context

    @State private var compostName: String
    @State private var isEditing: Bool = false
    @State private var showAlerts: Bool = false
    @State private var longPressWorkItem: DispatchWorkItem?
    @Binding private var navigationPath: NavigationPath
    
    let compostItem: CompostItem
    
//    private let compostMethod: String
    private let temperatureCategory: String
    private let moistureCategory: String
    private let creationDate: Date
//    let userInputs: [String]
    private let isHealthy: Bool
    let alerts: [CompostAlert]
    
    // Computed properties
    private var age: Int {
        Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 0
    }
    
    private var statusText: String {
        isHealthy ? "Healthy" : "Need Action"
    }
    
    private var statusColor: Color {
        isHealthy ? Color("Status/Success") : Color("Status/Danger")
    }
    
    
    // Empty pile?
    private var isPileEmpty: Bool { compostItem.compostStacks.isEmpty }
    
    // Display strings with empty-state fallback
    private var tempDisplay: String { isPileEmpty ? "—" : temperatureCategory }
    private var moistDisplay: String { isPileEmpty ? "—" : moistureCategory }
    
    init(compostItem: CompostItem, alerts: [CompostAlert], navigationPath: Binding<NavigationPath>) {
        self.compostItem = compostItem
        self.alerts = alerts
//        self.compostMethod = compostItem.compostMethodId?.name ?? ""
        self.temperatureCategory = compostItem.temperatureCategory
        self.creationDate = compostItem.creationDate
        self.isHealthy = compostItem.isHealthy
        self.moistureCategory = compostItem.moistureCategory
        self.compostName = compostItem.name
        self._navigationPath = navigationPath
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Card Content
            VStack(spacing: 16) {
                // Header Section
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // Editable Title
                        if isEditing {
                            TextField("Compost Name", text: $compostName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    compostItem.name = compostName
                                    do {
                                        try context.save()
                                    } catch {
                                        print("Error saving compost item: \(error.localizedDescription)")
                                    }
                                    
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isEditing = false
                                    }
                                }
                        } else {
                            HStack {
                                Text(compostName)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .onTapGesture(count: 1) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isEditing = true
                                        }
                                    }
                                
                                Image(systemName: "pencil")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .opacity(0.75)
                            }
                        }
                        
                        // Fixed Method
//                        HStack {
//                            Image(systemName: "arrow.3.trianglepath")
//                                .foregroundColor(.secondary)
//                                .font(.caption)
//                            Text(compostMethod)
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    StatusChip(type: {
                        switch compostItem.compostStatus {
                        case .healthy: return .healthy
                        case .needAction: return .needAction
                        case .harvested: return .harvested
                        }
                    }())
                }
                
                // Metrics Section (preserved layout + empty state)
               HStack(spacing: 12) {
                   MetricView(
                       icon: "thermometer",
                       value: tempDisplay,
                       label: "Temperature",
                       isEmpty: isPileEmpty
                   )
                   
                   MetricView(
                       icon: "drop.fill",
                       value: moistDisplay,
                       label: "Moisture",
                       isEmpty: isPileEmpty
                   )
                   
                   MetricView(
                       icon: "calendar",
                       value: "\(age) Day\(age == 1 ? "" : "s")",
                       label: "Age",
                       isEmpty: false
                   )
               }
                
                // Update Button
                Button(action: {
                    // Navigate to detail page
                    navigationPath.append(CompostNavigation.updateCompost(compostItem.compostItemId))
                }) {
                    Text("Update Compost")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color("BrandGreenDark"))
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(20)
            .background(Color(.systemBackground))
            
            // Conditional Alerts Section (Only show if not healthy)
            if !isHealthy && !alerts.isEmpty {
                VStack(spacing: 0) {
                    // Dropdown Toggle
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAlerts.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Compost Issues")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: showAlerts ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .rotationEffect(.degrees(showAlerts ? 0 : 0))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                    }
                    .foregroundColor(.primary)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Alerts Content
                    if showAlerts {
                        VStack(spacing: 12) {
                            ForEach(alerts.indices, id: \.self) { index in
                                AlertRow(alert: alerts[index])
                            }
                        }
                        .padding(20)
                        .background(Color(.systemGray6))
                        .transition(.slide)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onDisappear {
            longPressWorkItem?.cancel()
        }
    }
}

// MARK: - Metric View
struct MetricView: View {
    let icon: String
    let value: String
    let label: String
    var isEmpty: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("Status/Success"))
                .frame(height: 24)
            
            VStack(spacing: 0) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(6)
        .background(
            // Keep your card’s flat white look by default,
            // while showing a dotted outline only for the empty state.
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: isEmpty ? [5, 5] : []))
                        .foregroundColor(isEmpty ? Color.secondary.opacity(0.6) : .clear)
                )
        )
    }
}

// MARK: - Alert Row
struct AlertRow: View {
    let alert: CompostAlert
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: alert.icon)
                .foregroundColor(alert.color)
                .font(.title3)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(alert.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(alert.solution)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Data Models
struct CompostAlert {
    let title: String
    let solution: String
    let icon: String
    let color: Color
}
