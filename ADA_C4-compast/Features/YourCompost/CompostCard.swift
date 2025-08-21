//
//  CompostCard.swift
//  ADA_C4-compast
//
//  Created by Olaffiqih Wibowo on 21/08/25.
//

import SwiftUI

// MARK: - Content View (Main Screen)
struct ContentView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Scenario 1: Healthy Compost
                    CompostCard(
                        name: "First Compost",
                        method: "Tumbler Compost",
                        temperature: 75,
                        userInputs: ["green vegetables", "brown paper", "coffee grounds"],
                        creationDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                        isHealthy: true,
                        alerts: []
                    )
                    
                    // Scenario 2: Need Action - Too Wet & Cold
                    CompostCard(
                        name: "Backyard Pile",
                        method: "Open Pile Compost",
                        temperature: 45,
                        userInputs: ["green vegetables", "green grass", "fruit scraps", "vegetable peels"],
                        creationDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                        isHealthy: false,
                        alerts: [
                            CompostAlert(
                                title: "Too Wet",
                                solution: "Add brown materials to reduce moisture",
                                icon: "drop.fill",
                                color: .blue
                            ),
                            CompostAlert(
                                title: "Too Cold",
                                solution: "Add more green materials or turn the pile to increase temperature",
                                icon: "thermometer",
                                color: .red
                            )
                        ]
                    )
                    
                    // Scenario 3: Need Action - Too Dry
                    CompostCard(
                        name: "Kitchen Scraps",
                        method: "Bin Compost",
                        temperature: 68,
                        userInputs: ["brown paper", "brown cardboard", "dried leaves"],
                        creationDate: Calendar.current.date(byAdding: .day, value: -21, to: Date())!,
                        isHealthy: false,
                        alerts: [
                            CompostAlert(
                                title: "Too Dry",
                                solution: "Add water or green materials to increase moisture",
                                icon: "drop",
                                color: .orange
                            )
                        ]
                    )
                    
                    // Scenario 4: Need Action - Multiple Issues
                    CompostCard(
                        name: "Garden Waste",
                        method: "Worm Compost",
                        temperature: 55,
                        userInputs: ["green vegetables", "green grass clippings"],
                        creationDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
                        isHealthy: false,
                        alerts: [
                            CompostAlert(
                                title: "Needs Turning",
                                solution: "Turn the compost to improve aeration and speed decomposition",
                                icon: "arrow.3.trianglepath",
                                color: .purple
                            ),
                            CompostAlert(
                                title: "Add Brown Materials",
                                solution: "Balance with brown materials like dry leaves or paper",
                                icon: "leaf",
                                color: .brown
                            ),
                            CompostAlert(
                                title: "pH Imbalance",
                                solution: "Test pH levels and add lime if too acidic",
                                icon: "testtube.2",
                                color: .green
                            )
                        ]
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .navigationTitle("Compost Tracker")
            .background(Color(.systemGray6))
        }
    }
}

// MARK: - Compost Card View
struct CompostCard: View {
    @State private var compostName: String
    @State private var isEditing: Bool = false
    @State private var showAlerts: Bool = false
    @State private var longPressWorkItem: DispatchWorkItem?
    
    let compostMethod: String
    let temperature: Int
    let moisture: Int
    let creationDate: Date
    let userInputs: [String]
    let isHealthy: Bool
    let alerts: [CompostAlert]
    
    // Computed properties
    private var age: Int {
        Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 0
    }
    
    private var statusText: String {
        isHealthy ? "Healthy" : "Need Action"
    }
    
    private var statusColor: Color {
        isHealthy ? .green : .orange
    }
    
    init(name: String, method: String, temperature: Int, userInputs: [String], creationDate: Date, isHealthy: Bool, alerts: [CompostAlert]) {
        self._compostName = State(initialValue: name)
        self.compostMethod = method
        self.temperature = temperature
        self.userInputs = userInputs
        self.creationDate = creationDate
        self.isHealthy = isHealthy
        self.alerts = alerts
        
        // Calculate moisture based on user inputs
        let greenMaterials = userInputs.filter { $0.contains("green") || $0.contains("vegetable") }.count
        let brownMaterials = userInputs.filter { $0.contains("brown") || $0.contains("paper") }.count
        self.moisture = min(90, max(30, 60 + (greenMaterials * 10) - (brownMaterials * 5)))
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
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isEditing = false
                                    }
                                }
                        } else {
                            HStack {
                                Text(compostName)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .onTapGesture(count: 2) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            isEditing = true
                                        }
                                    }
                                    .onLongPressGesture(minimumDuration: 0.1, maximumDistance: 50) {
                                        // Start 5-second timer for long press
                                        let workItem = DispatchWorkItem {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                isEditing = true
                                            }
                                        }
                                        longPressWorkItem = workItem
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: workItem)
                                    } onPressingChanged: { pressing in
                                        if !pressing {
                                            longPressWorkItem?.cancel()
                                            longPressWorkItem = nil
                                        }
                                    }
                                
                                Image(systemName: "pencil")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .opacity(0.6)
                            }
                        }
                        
                        // Fixed Method
                        HStack {
                            Image(systemName: "arrow.3.trianglepath")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            Text(compostMethod)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    Text(statusText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                
                // Metrics Section
                HStack(spacing: 20) {
                    MetricView(
                        icon: "thermometer",
                        value: "\(temperature)°F",
                        label: "Temperature"
                    )
                    
                    MetricView(
                        icon: "drop.fill",
                        value: "\(moisture)%",
                        label: "Moisture"
                    )
                    
                    MetricView(
                        icon: "calendar",
                        value: "\(age) Day\(age != 1 ? "s" : "")",
                        label: "Age"
                    )
                }
                
                // Update Button
                Button(action: {
                    // Navigate to detail page
                    print("Navigate to compost detail page for: \(compostName)")
                }) {
                    Text("Update Compost")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(red: 0.2, green: 0.5, blue: 0.3), Color(red: 0.15, green: 0.4, blue: 0.25)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
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
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(height: 24)
            
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
        .frame(maxWidth: .infinity)
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

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
        
        ContentView()
            .preferredColorScheme(.dark)
    }
}
