//
//  ToDoCard.swift
//  ADA_C4-compast
//
//  Created by Olaffiqih Wibowo on 23/08/25.


import SwiftUI
import SwiftData

struct SimpleSection: Identifiable {
    let id = UUID()
    let title: String          // "Today", "Tomorrow", "Upcoming"
    let tasks: [CompostTask]
}


// MARK: - Grouping: Month -> Day -> Tasks

struct MonthSection: Identifiable {
    let id = UUID()
    let monthStart: Date               // first day of month at 00:00
    let title: String                  // e.g., "August 2025"
    let days: [DaySection]
}

struct DaySection: Identifiable {
    let id = UUID()
    let date: Date                     // day at 00:00
    let title: String                  // e.g., "Today", "Tomorrow", or "Wed, 27 Aug"
    let tasks: [CompostTask]
}

enum GroupUse {
    case current    // use task.dueDate
    case history    // use task.completedAt ?? dueDate
}

func groupTasksByMonthThenDay(_ tasks: [CompostTask], use: GroupUse) -> [MonthSection] {
    let cal = Calendar.current

    // 1) Choose the date key we’re grouping by
    func keyDate(_ t: CompostTask) -> Date {
        switch use {
        case .current:
            return cal.startOfDay(for: t.dueDate)
        case .history:
            return cal.startOfDay(for: t.completedAt ?? t.dueDate)
        }
    }

    // 2) First, group by Day
    let byDay = Dictionary(grouping: tasks, by: { keyDate($0) })
        .map { (day, tasks) -> DaySection in
            DaySection(date: day, title: dayTitle(day), tasks: tasks.sorted { $0.dueDate < $1.dueDate })
        }
        .sorted { $0.date < $1.date }

    // 3) Now, group day-sections by Month
    let byMonth = Dictionary(grouping: byDay, by: { firstOfMonth($0.date) })
        .map { (monthStart, days) -> MonthSection in
            MonthSection(monthStart: monthStart, title: monthYearTitle(monthStart), days: days.sorted { $0.date < $1.date })
        }
        .sorted { $0.monthStart < $1.monthStart }

    return byMonth
}

// MARK: - Date helpers

func firstOfMonth(_ date: Date) -> Date {
    let cal = Calendar.current
    let comps = cal.dateComponents([.year, .month], from: date)
    return cal.date(from: comps) ?? date
}

func monthYearTitle(_ date: Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "LLLL yyyy"    // e.g., August 2025
    return f.string(from: date)
}

func dayTitle(_ date: Date) -> String {
    let cal = Calendar.current
    if cal.isDateInToday(date) { return "Today" }
    if cal.isDateInTomorrow(date) { return "Tomorrow" }
    if cal.isDateInYesterday(date) { return "Yesterday" }

    let f = DateFormatter()
    f.dateFormat = "EEE, dd MMM"
    return f.string(from: date)
}
// MARK: - Main To-Do View (with tabs, month/year, per-day sections)

struct CompostToDoListView: View {
   
    @Query(sort: \CompostItem.creationDate, order: .reverse) private var compostItems: [CompostItem]
    
//    let composts: [CompostItem]

    @State private var allTasks: [CompostTask] = []
    @State private var selectedTab: Tab = .current

    enum Tab: String, CaseIterable { case current = "Current", history = "History" }
    
    // Grouped sections
    var currentBuckets: [SimpleSection] {
        let current = allTasks.filter { !$0.isCompleted }
        return bucketizeCurrentTasks(current)
    }
    var historySections: [MonthSection] {
        let past = allTasks.filter { $0.isCompleted }
        return groupTasksByMonthThenDay(past, use: .history)
    }

    func bucketizeCurrentTasks(_ tasks: [CompostTask]) -> [SimpleSection] {
        let cal = Calendar.current
        let now = Date()
        let todayKey = cal.startOfDay(for: now)
        guard let tomorrowKey = cal.date(byAdding: .day, value: 1, to: todayKey) else {
            // Fallback: put everything in Upcoming if we can’t compute tomorrow
            return [
                SimpleSection(title: "Today", tasks: tasks.filter { cal.isDateInToday($0.dueDate) }.sorted { $0.dueDate < $1.dueDate }),
                SimpleSection(title: "Tomorrow", tasks: tasks.filter { cal.isDateInTomorrow($0.dueDate) }.sorted { $0.dueDate < $1.dueDate }),
                SimpleSection(title: "Upcoming", tasks: tasks.filter { !cal.isDateInToday($0.dueDate) && !cal.isDateInTomorrow($0.dueDate) }.sorted { $0.dueDate < $1.dueDate })
            ]
        }

        let todayTasks = tasks.filter { cal.isDate($0.dueDate, inSameDayAs: todayKey) }
                              .sorted { $0.dueDate < $1.dueDate }

        let tomorrowTasks = tasks.filter { cal.isDate($0.dueDate, inSameDayAs: tomorrowKey) }
                                 .sorted { $0.dueDate < $1.dueDate }

        let upcomingTasks = tasks.filter {
            let d0 = cal.startOfDay(for: $0.dueDate)
            return d0 > tomorrowKey
        }.sorted { $0.dueDate < $1.dueDate }

        return [
            SimpleSection(title: "Today", tasks: todayTasks),
            SimpleSection(title: "Tomorrow", tasks: tomorrowTasks),
            SimpleSection(title: "Upcoming", tasks: upcomingTasks)
        ]
    }


    
    var body: some View {
        VStack(spacing: 12) {
            // Tabs and title
            VStack(alignment: .leading, spacing: 20) {
                HStack (spacing: 10) {
                    Image("compost/logo-dark-green")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
                    Text("To Do")
                        .font(.custom("KronaOne-Regular", size: 20))
                        .foregroundStyle(Color("BrandGreenDark"))
                    
                    Spacer()
                    
                    Button(action: {
                        regenerateTasks()
                    }) {
                        Text("\(Image(systemName: "arrow.clockwise"))")
                            .font(.system(size: 24))
                            .foregroundStyle(Color("BrandGreenDark"))
                    }
                }
                .padding()
                
                Picker("", selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.self) { t in Text(t.rawValue) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }
            

            ZStack(alignment: .bottom){
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if selectedTab == .current {
                            // Simplified: Today / Tomorrow / Upcoming
                            ForEach(currentBuckets) { bucket in
                                SectionHeaderDate(title: bucket.title, icon: "calendar")
                                    .padding(.horizontal)

                                VStack(spacing: 12) {
                                    ForEach(bucket.tasks) { task in
                                        TaskCard(
                                            task: task,
                                            isUpcoming: (bucket.title == "Upcoming") || (bucket.title == "Tomorrow"),
                                            onToggle: { markCompleted(task) }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            // History: keep Month -> Day sections
                            ForEach(historySections) { month in
                                MonthHeader(title: month.title)
                                    .padding(.horizontal)

                                ForEach(month.days) { day in
                                    SectionHeaderDate(title: day.title, icon: "calendar")
                                        .padding(.horizontal)

                                    VStack(spacing: 12) {
                                        ForEach(day.tasks) { task in
                                            TaskCard(
                                                task: task,
                                                isUpcoming: false,
                                                onToggle: { /* no-op or toggle if you want to allow undo */ }
                                            )
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }

            }
        }
        .background(Color(hex: "F5F5F5"))
        .onAppear {
            regenerateTasks()
            Notifications.requestAuthIfNeeded()
            Notifications.scheduleAll(for: allTasks)
        }
    }

    private func regenerateTasks() {
        print("refreshing task...")
        allTasks = CompostTaskEngine.buildTasks(for: compostItems)
    }

    private func markCompleted(_ task: CompostTask) {
        guard let idx = allTasks.firstIndex(of: task) else { return }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            allTasks[idx].isCompleted = true
            allTasks[idx].completedAt = Date()
        }
        Notifications.remove(for: task)
    }
}

// MARK: - Headers & Cards (kept from your old design, with date variant)

struct MonthHeader: View {
    let title: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar.circle.fill")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(Color(hex: "2D3E2D"))
            Text(title)
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(hex: "2D3E2D"))
        }
        .padding(.top, 4)
    }
}

struct SectionHeaderDate: View {
    let title: String
    let icon: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(hex: "2D3E2D"))
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "2D3E2D"))
            
            Spacer()
        }
        .padding(.top, 6)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Color Extension (as in your file)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Preview

struct CompostToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        // Dummy composts (use your SwiftData models in-app)
        let method = CompostMethod(
            compostMethodId: 1,
            name: "Hot Compost",
            descriptionText: "Fast composting",
            compostDuration1: 30,
            compostDuration2: 180,
            spaceNeeded1: 1,
            spaceNeeded2: 4
        )
        let a = CompostItem(name: "First pile")
        a.compostMethodId = method
        a.creationDate = Date().addingTimeInterval(-14*86400)
        let b = CompostItem(name: "Second pile")
        b.compostMethodId = method
        b.creationDate = Date().addingTimeInterval(-7*86400)
        let c = CompostItem(name: "Third pile")
        c.compostMethodId = method
        c.creationDate = Date().addingTimeInterval(-35*86400)
        return NavigationView {
//            CompostToDoListView(composts: [a,b,c])
            CompostToDoListView()
//                .navigationTitle("To Do")
        }
    }
}
