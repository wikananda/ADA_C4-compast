//
//  ToDoMain.swift
//  ADA_C4-compast
//
//  Created by Olaffiqih Wibowo on 22/08/25.
//

import SwiftUI

// MARK: - DATA MODELS
struct ToDoItem: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
}

// New struct to group tasks by a specific date
struct DailyTasks: Identifiable {
    let id = UUID()
    var date: Date
    var tasks: [ToDoItem]
}


// MARK: - MAIN TO-DO VIEW
struct ToDoMainView: View {
    @State var dailyTaskGroups: [DailyTasks]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            HStack {
                Image(systemName: "safari.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.accentColor)
                Spacer()
                Text("To Do")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemBackground)) // Give header a solid background

            // MARK: - Conditional Content
            if dailyTaskGroups.isEmpty {
                // Show empty state if there are no task groups
                Spacer()
                EmptyStateView()
                Spacer()
            } else {
                // Show the list of daily task cards
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach($dailyTaskGroups) { $dailyTasks in
                            DailyTaskCardView(dailyTasks: $dailyTasks)
                        }
                    }
                    .padding()
                }
            }
            
            // MARK: - Navigation Bar
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "leaf.arrow.circlepath")
                    Text("My Compost")
                }
                .padding(.horizontal, 20)
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("To Do")
                }
                .foregroundColor(.green)
                .padding(.horizontal, 20)
                VStack {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .padding(.horizontal, 20)
                Spacer()
            }
            .foregroundColor(.gray)
            .padding(.vertical, 5)
            .background(Color(.systemBackground).shadow(radius: 1))
        }
        .background(Color(.systemGray6)) // Set a background for the whole screen
        .edgesIgnoringSafeArea(.bottom)
    }
}


// MARK: - COLLAPSIBLE DAILY TASK CARD
struct DailyTaskCardView: View {
    @Binding var dailyTasks: DailyTasks
    @State private var isExpanded: Bool = true // Each card manages its own state

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Card Header (Date & Collapse Button)
            HStack {
                Text(formatDate(dailyTasks.date))
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .contentShape(Rectangle()) // Makes the whole HStack tappable
            .onTapGesture {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }
            
            // MARK: - Collapsible Task List
            if isExpanded {
                Divider()
                VStack(spacing: 0) {
                    ForEach($dailyTasks.tasks) { $task in
                        TaskRowView(task: $task)
                        // Add a divider unless it's the last item
                        if task.id != dailyTasks.tasks.last?.id {
                            Divider().padding(.leading)
                        }
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // Helper function to format the date display
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d" // e.g., "Saturday, Aug 26"
            return formatter.string(from: date)
        }
    }
}


// MARK: - TASK ROW VIEW
struct TaskRowView: View {
    @Binding var task: ToDoItem
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: {
                withAnimation {
                    task.isCompleted.toggle()
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(task.title)
                .strikethrough(task.isCompleted, color: .gray)
                .foregroundColor(task.isCompleted ? .gray : .primary)
            
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
    }
}


// MARK: - EMPTY STATE VIEW
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150)
                .foregroundColor(.gray.opacity(0.5))
            
            Text("You Have No Task")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("There's nothing you can do today, you can rest for the rest of the day")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}


// MARK: - PREVIEWS
struct ToDoMainView_Previews: PreviewProvider {
    
    // Create dummy data with different dates
    static let dummyDailyTasks: [DailyTasks] = [
        // Tasks for Today
        DailyTasks(date: Date(), tasks: [
            ToDoItem(title: "Turn the compost pile"),
            ToDoItem(title: "Add kitchen scraps (greens)", isCompleted: true)
        ]),
        // Tasks for Tomorrow
        DailyTasks(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, tasks: [
            ToDoItem(title: "Check moisture level"),
            ToDoItem(title: "Add shredded newspaper (browns)")
        ]),
        // Tasks for 3 days from now
        DailyTasks(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, tasks: [
            ToDoItem(title: "Measure temperature of the pile"),
            ToDoItem(title: "Sift finished compost")
        ])
    ]
    
    static var previews: some View {
        ToDoMainView(dailyTaskGroups: dummyDailyTasks)
            .previewDisplayName("Daily Tasks")
        
        ToDoMainView(dailyTaskGroups: [])
            .previewDisplayName("Empty State")
    }
}
