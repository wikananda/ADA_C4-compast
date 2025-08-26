//
//  ToDoCard.swift
//  ADA_C4-compast
//
//  Created by Olaffiqih Wibowo on 23/08/25.
//

import SwiftUI

// MARK: - Data Models
struct CompostTask: Identifiable {
    let id = UUID()
    let taskType: String
    let compostName: String
    var isCompleted: Bool
    let section: TaskSection
    
    enum TaskSection {
        case today
        case upcoming
    }
}

// MARK: - Main View
struct CompostToDoListView: View {
    @State private var tasks = [
        // Today's tasks
        CompostTask(taskType: "Update Log", compostName: "First Compost", isCompleted: true, section: .today),
        CompostTask(taskType: "Add more Water", compostName: "First Compost", isCompleted: false, section: .today),
        CompostTask(taskType: "Add more brown", compostName: "First Compost", isCompleted: false, section: .today),
        CompostTask(taskType: "Update Log", compostName: "Second Compost", isCompleted: false, section: .today),
        
        // Upcoming tasks
        CompostTask(taskType: "Update Log", compostName: "Third Compost", isCompleted: false, section: .upcoming),
        CompostTask(taskType: "Update Log", compostName: "Second Compost", isCompleted: false, section: .upcoming)
    ]
    
    var todayTasks: [CompostTask] {
        tasks.filter { $0.section == .today }
    }
    
    var upcomingTasks: [CompostTask] {
        tasks.filter { $0.section == .upcoming }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 50) {
                HStack (spacing: 10) {
                    Image("compost/logo-dark-green")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
                    Text("To Do")
                        .font(.custom("KronaOne-Regular", size: 20))
                        .foregroundStyle(Color("BrandGreenDark"))
                }
                
                // Today Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Today", icon: "calendar")
                    
                    VStack(spacing: 12) {
                        ForEach(todayTasks) { task in
                            TaskCard(
                                task: task,
                                onToggle: { toggleTask(task.id) }
                            )
                        }
                    }
                }
                
                // Upcoming Section
                VStack(alignment: .leading, spacing: 16) {
                    SectionHeader(title: "Upcoming", icon: "calendar")
                    
                    VStack(spacing: 12) {
                        ForEach(upcomingTasks) { task in
                            TaskCard(
                                task: task,
                                isUpcoming: true,
                                onToggle: { toggleTask(task.id) }
                            )
                        }
                    }
                }
                Color.clear
                    .frame(height: 75)
            }
            .padding()
        }
        .background(Color(hex: "F5F5F5"))
    }
    
    private func toggleTask(_ id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tasks[index].isCompleted.toggle()
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "2D3E2D"))
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "2D3E2D"))
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Task Card
struct TaskCard: View {
    let task: CompostTask
    var isUpcoming: Bool = false
    let onToggle: () -> Void
    @State private var isTapped = false
    
    var body: some View {
        VStack(spacing: 0) {
            if isTapped && !isUpcoming {
                // TAPPED STATE - Expanded view (only for Today tasks)
                ExpandedTaskCard(
                    task: task,
                    onToggle: onToggle,
                    onTap: { isTapped.toggle() }
                )
            } else {
                // UNTAPPED STATE - Compact view
                CompactTaskCard(
                    task: task,
                    isUpcoming: isUpcoming,
                    onToggle: onToggle,
                    onTap: {
                        if !isUpcoming {
                            isTapped.toggle()
                        }
                    }
                )
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isTapped)
    }
}

// MARK: - Compact Task Card
struct CompactTaskCard: View {
    let task: CompostTask
    let isUpcoming: Bool
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Completion Circle
            Button(action: isUpcoming ? {} : onToggle) {
                ZStack {
                    Circle()
                        .fill(task.isCompleted ? Color(hex: "4A6741") : Color(hex: "D3D3D3"))
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(isUpcoming)
            
            VStack(alignment: .leading, spacing: 10) {
                // Task Type with icon
                HStack(spacing: 10) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 16))
                        .foregroundColor(isUpcoming ? Color.gray.opacity(0.5) : Color(hex: "2D3E2D"))
                    
                    Text(task.taskType)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isUpcoming ? Color.gray.opacity(0.5) : Color(hex: "2D3E2D"))
                }
                
                // Compost Name
                Text(task.compostName)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(isUpcoming ? Color.gray.opacity(0.5) : Color(hex: "4D4D4D"))
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(task.isCompleted ? Color(hex: "C7CCC7") : Color.white)
        )
        .opacity(isUpcoming ? 0.6 : 1.0)
        .onTapGesture(perform: onTap)
        .transition(.blurReplace)
    }
}

// MARK: - Expanded Task Card
struct ExpandedTaskCard: View {
    let task: CompostTask
    let onToggle: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 16) {
                // Large Completion Circle
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .fill(task.isCompleted ? Color(hex: "4A6741") : Color(hex: "D3D3D3"))
                            .frame(width: 24, height: 24)
                        
                        if task.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    // Task Type with icon
                    HStack(spacing: 10) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "2D3E2D"))
                        
                        Text(task.taskType)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "2D3E2D"))
                    }
                    
                    // Compost Name
                    Text(task.compostName)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(Color(hex: "4D4D4D"))
                }
                
                Spacer()
                
                // Close button
                Button(action: onTap) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.gray.opacity(0.5))
                }
            }
            
            // Additional details can be added here
            if task.taskType == "Update Log" {
                Text("Tap to add notes about your compost progress...")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .padding(.top, 10)
            } else if task.taskType == "Add more Water" {
                Text("Your compost needs moisture. Add water until it feels like a wrung-out sponge.")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .padding(.top, 10)
            } else if task.taskType == "Add more brown" {
                Text("Add dry leaves, paper, or cardboard to balance the nitrogen content.")
                    .font(.system(size: 16))
                    .foregroundColor(Color.gray)
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .stroke(style: StrokeStyle(lineWidth: 1))
                .fill(task.isCompleted ? Color(hex: "C7CCC7") : Color(hex: "E8E8E8"))
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .onTapGesture(perform: onTap)
        .transition(.blurReplace)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
struct CompostToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        CompostToDoListView()
    }
}

// MARK: - App Entry Point (if needed)
struct CompostApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                CompostToDoListView()
                    .navigationTitle("Compost Tasks")
                    .navigationBarTitleDisplayMode(.large)
            }
        }
    }
}
