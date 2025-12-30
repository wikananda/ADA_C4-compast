//
//  ToDoMain.swift
//  ADA_C4-compast
//
//  Created by Olaffiqih Wibowo on 22/08/25.
//

import SwiftUI
import SwiftData

// ToDoItem and DailyTasks are defined in ToDoViewModel.swift

// MARK: - MAIN TO-DO VIEW
struct ToDoMainView: View {
    @Query private var compostItems: [CompostItem]
    @Environment(\.modelContext) private var modelContext

    // MARK: - ViewModel
    @State private var viewModel: ToDoViewModel

    init() {
        // ViewModel will be properly initialized in onAppear with modelContext
        _viewModel = State(initialValue: ToDoViewModel(
            modelContext: ModelContext(try! ModelContainer(for: CompostItem.self))
        ))
    }

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
            if !viewModel.hasTasks {
                // Show empty state if there are no task groups
                Spacer()
                EmptyStateView()
                Spacer()
            } else {
                // Show the list of daily task cards
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(Array(viewModel.dailyTaskGroups.enumerated()), id: \.element.id) { groupIndex, dailyTasks in
                            DailyTaskCardView(
                                dailyTasks: Binding(
                                    get: { viewModel.dailyTaskGroups[groupIndex] },
                                    set: { viewModel.dailyTaskGroups[groupIndex] = $0 }
                                ),
                                viewModel: viewModel,
                                groupIndex: groupIndex
                            )
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
        .onAppear {
            // Re-initialize with correct context
            viewModel = ToDoViewModel(modelContext: modelContext)
            viewModel.updateCompostItems(compostItems)
        }
        .onChange(of: compostItems) { _, newItems in
            viewModel.updateCompostItems(newItems)
        }
    }
}


// MARK: - COLLAPSIBLE DAILY TASK CARD
struct DailyTaskCardView: View {
    @Binding var dailyTasks: DailyTasks
    var viewModel: ToDoViewModel
    var groupIndex: Int
    @State private var isExpanded: Bool = true // Each card manages its own state

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Card Header (Date & Collapse Button)
            HStack {
                Text(viewModel.formatDate(dailyTasks.date))
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
                    ForEach(Array(dailyTasks.tasks.enumerated()), id: \.element.id) { taskIndex, task in
                        TaskRowView(
                            task: task,
                            onToggle: {
                                withAnimation {
                                    viewModel.toggleTaskCompletion(groupIndex: groupIndex, taskIndex: taskIndex)
                                }
                            }
                        )
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
}


// MARK: - TASK ROW VIEW
struct TaskRowView: View {
    var task: ToDoItem
    var onToggle: () -> Void

    var body: some View {
        HStack(spacing: 15) {
            Button(action: onToggle) {
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
#Preview("Daily Tasks") {
    ToDoMainView()
}

#Preview("Empty State") {
    ToDoMainView()
}
