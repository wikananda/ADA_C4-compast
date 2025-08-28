//
//  UpdateCompostView.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 20/08/25.
//

import SwiftUI

enum CompostRoute: Hashable {
    case pilePrototype(Int)   // compostItemId
}

extension Date {
    func daysUntil(_ targetDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: targetDate)
        return components.day ?? 0
    }
}

func daysRemainingText(from currentDate: Date, to targetDate: Date?) -> String {
    guard let targetDate = targetDate else { return "—" }
    
    let daysRemaining = currentDate.daysUntil(targetDate)
    
    if daysRemaining > 0 {
        return "\(daysRemaining) days left"
    } else if daysRemaining == 0 {
        return "Today"
    } else {
        return "\(abs(daysRemaining)) days overdue"
    }
}

import SwiftUI

struct UpdateCompostView: View {
    @Environment(\.modelContext) private var context
    @Bindable var compostItem: CompostItem
    @Environment(\.dismiss) private var dismiss
    
    // Navigation
    @State private var vitalsSheetPresented: Bool = false
    
    // Compost identity
    @State private var compost_name: String
    @State private var status: Bool
    
    // Compost stats
    @State private var createdAt: Date
    @State private var currentTemperatureCategory: String
    
    @State private var selectedTemp: Option?
    @State private var selectedMoisture: Option?
    
    @Binding private var navigationPath: NavigationPath
    
    // Menu states
    @State private var showRenameAlert = false
    @State private var renameText = ""
    @State private var showDeleteConfirm = false
    
    // Alerts
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    init(compostItem: CompostItem, navigationPath: Binding<NavigationPath>) {
        self._compostItem = Bindable(compostItem)
        self.compostItem = compostItem
        self._navigationPath = navigationPath
        _compost_name = State(initialValue: compostItem.name)
        _status = State(initialValue: compostItem.isHealthy)
        _createdAt = State(initialValue: compostItem.creationDate)
        _currentTemperatureCategory = State(initialValue: compostItem.temperatureCategory)
    }
    
    // MARK: - Light helpers to reduce type-checking load ✅
    private var ageDays: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
    private var turnedOverText: String {
        if let days = compostItem.daysSinceLastTurn {
            return days == 0 ? "Today" : "\(days) days ago"
        } else {
            return "Never"
        }
    }
    private var isRecentlyUpdated: Bool {
        compostItem.lastLogged > Date().addingTimeInterval(-60*60*24)
    }
    private var chipType: StatusChip.ChipType {        // ✅ no inline switch in the view tree
        switch compostItem.compostStatus {
        case .healthy:   return .healthy
        case .needAction:return .needAction
        case .harvested: return .harvested
        }
    }
    private var isPileEmpty: Bool {                    // ✅ block Mix if empty
        compostItem.compostStacks.isEmpty
    }
    
    private var hasBeenTurnedToday: Bool {
        guard let lastTurnedDate = compostItem.lastTurnedOver else { return false }
        
        let calendar = Calendar.current
        return calendar.isDate(Date(), inSameDayAs: lastTurnedDate)
    }
    
    // MARK: - Actions
    private func markAsHarvested() {
        compostItem.harvestedAt = Date()
        try? context.save()
    }
    private func renameCompost() {
        let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        compostItem.name = trimmed
        compost_name = trimmed
        try? context.save()
    }
    private func deleteCompost() {
        context.delete(compostItem)
        try? context.save()
        dismiss()
    }
    private func daysRemainingText(from start: Date, to end: Date?) -> String {
        guard let end else { return "—" }
        let d = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
        return d >= 0 ? "\(d) days" : "—"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            headerBar
            
            ScrollView {
                VStack(alignment: .center, spacing: 24) {
                    // Title row
                    titleRow
                    
                    // Stats + Actions card
                    statsAndActionsCard
                    
                    // Advice / Log card
                    adviceAndLogCard
                        .padding(.bottom, 100)
                }
                
                // Bottom Save (kept)
                bottomSaveBar
            }
        }
        .padding(.horizontal, 24)
        .background(Color("Status/Background"))
        .navigationBarHidden(true)
        .sheet(isPresented: $vitalsSheetPresented) {
            UpdateCompostVitalsSheet(compostItem: compostItem)
        }
        .alert("Rename Compost", isPresented: $showRenameAlert) {
            TextField("Compost name", text: $renameText)
            Button("Cancel", role: .cancel) {}
            Button("Rename") { renameCompost() }
        } message: {
            Text("Enter a new name for this compost pile.")
        }
        .confirmationDialog("Delete Compost",
                            isPresented: $showDeleteConfirm,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteCompost() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this compost? This action cannot be undone.")
        }
    }
    
    // MARK: - Extracted subviews (smaller trees = faster type-check) ✅
    
    private var headerBar: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22))
            }
            .foregroundStyle(Color("BrandGreenDark"))
            
            Spacer()
            Text("Update Compost")
                .font(.custom("KronaOne-Regular", size: 16))
                .foregroundStyle(Color("BrandGreenDark"))
            Spacer()
            
            Menu {
                Button { markAsHarvested() } label: {
                    Label("Mark As Harvested", systemImage: "checkmark.circle")
                }
                Button {
                    renameText = compostItem.name
                    showRenameAlert = true
                } label: {
                    Label("Rename Compost", systemImage: "pencil")
                }
                Button(role: .destructive) { showDeleteConfirm = true } label: {
                    Label("Delete Compost", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundStyle(Color("BrandGreenDark"))
            }
        }
    }
    
    private var titleRow: some View {
        HStack(alignment: .center) {
            Text(compost_name)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
            StatusChip(type: chipType)
        }
        .padding(.top, 12)
    }
    
    private var statsAndActionsCard: some View {
        VStack(spacing: 24) {
            // Three stats
            HStack(alignment: .center) {
                statTile(icon: "arrow.trianglehead.2.clockwise",
                         value: turnedOverText,
                         label: "Last turned")
                Spacer()
                statTile(icon: "calendar",
                         value: "\(ageDays) day",
                         label: "Age")
                Spacer()
                statTile(icon: "checkmark.circle",
                         value: daysRemainingText(from: Date(), to: compostItem.estimatedHarvestAt),
                         label: "Est. Harvest")
            }
            
            // Actions row
            HStack(spacing: 0) {
                // Mix — disabled if pile empty ✅
                Button(action: { MixCompost() }) {
                    HStack {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                        Text(hasBeenTurnedToday ? "Already mixed!" : "Mix")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(isPileEmpty ? Color.gray.opacity(0.35) : (hasBeenTurnedToday ? Color.gray.opacity(0.35) : Color("compost/PileDirt")))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(hasBeenTurnedToday ? Color.gray : Color.clear, lineWidth: 2)
                )
                .disabled(isPileEmpty)                             // ✅
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("Ok", role: .cancel) {
                        Text("Ok")
                    }
                } message: {
                    Text(alertMessage)
                }
                
                Spacer()
                
                // Add Material
                Button(action: {
                    navigationPath.append(CompostNavigation.pilePrototype(compostItem.compostItemId))
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Material")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(Color("BrandGreenDark"))
                .clipShape(Capsule())
            }
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
    }
    
    private func statTile(icon: String, value: String, label: String) -> some View {
        VStack(alignment: .center) {
            Image(systemName: icon)
                .foregroundStyle(Color("Status/Success"))
            Text(value)
                .font(.headline)
                .padding(.top, 4)
            Text(label)
                .font(.subheadline)
        }
    }
    
    private var adviceAndLogCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Compost Log :  \(compostItem.lastLogged.ddMMyyyy())")
                    .font(.headline)
                    .foregroundStyle(Color("BrandGreenDark"))
                Spacer()
                Text(isRecentlyUpdated ? "Updated" : "Not Updated")
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 100)
                            .fill(isRecentlyUpdated ? Color("Status/Success") : Color("Status/Warning"))
                    )
                    .foregroundStyle(.white)
                    .font(.caption)
            }
            
            // Advice / empty state
            if isPileEmpty {
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "questionmark.app.dashed")
                        .font(.system(size: 32)) // ✅ was .font(system(size: 32))
                        .foregroundStyle(Color.black.opacity(0.5))
                    Text("No data yet. Please add your compost material to get started!")
                        .foregroundStyle(Color.black.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical)
            } else {
                let items = CompostKnowledge.advice(for: compostItem)
                let tempIssue = items.first(where: { $0.category == .temperature })
                AdviceCard(category: .temperature, issue: tempIssue)
                let moistureIssue = items.first(where: { $0.category == .moisture })
                AdviceCard(category: .moisture, issue: moistureIssue)
            }
            
            Button(action: { vitalsSheetPresented.toggle() }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Update Log")
                        .font(.caption)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: 50)
            .background(Color("BrandGreenDark"))
            .clipShape(Capsule())
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color.white))
    }
    
    private var bottomSaveBar: some View {
        VStack {
            Button(action: {}) {
                Text(compostItem.harvestedAt != nil ? "SAVED" : "SAVE")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .foregroundStyle(.white)
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(Color("BrandGreenDark"))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 0)
        .background(
            LinearGradient(
                stops: [
                    .init(color: .white, location: 0.00),
                    .init(color: .white.opacity(0), location: 1.00),
                ],
                startPoint: .init(x: 0.5, y: 1),
                endPoint: .init(x: 0.5, y: 0)
            )
        )
    }
    
    // MARK: - Mix Compost (blocked when empty, only once a day)
    func MixCompost() {
        guard !isPileEmpty else {
            showAlert = true
            alertTitle = "Pile is still empty"
            alertMessage = "Fill your pile first before you can start mixing it."
            return
        } // hard block if empty
        guard !hasBeenTurnedToday else {
            showAlert = true
            alertTitle = "Pile already mixed"
            alertMessage = "You just need to mix the pile once a day."
            return
        } // hard block if already turneed today
        
        compostItem.turnNow(in: context)
        try? context.save()
        
        showAlert = true
        alertTitle = "You mixed the compost!"
        alertMessage = "Very great! Keep up the good work!"
    }
}

// MARK: - Advice Card

struct AdviceCard: View {
    let category: CompostCategory
    let issue: CompostProblem?

    var body: some View {
        if let issue {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: iconFor(issue.category))
    //                    .foregroundStyle(Color("Status/Danger"))
                        .foregroundStyle(.red)
                    Text(issue.title)
                        .font(.headline)
    //                    .foregroundStyle(Color("Status/Danger"))
                        .foregroundStyle(.red)
                }
    //            Text(issue.issue)
    //                .font(.subheadline)
    //                .foregroundStyle(.secondary)

                Divider().opacity(0.5)

                Label {
                    Text(issue.solution)
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true) // allow wrapping
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: "lightbulb")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let tip = issue.tip, !tip.isEmpty {
                    Label(tip, systemImage: "info.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 10)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: iconFor(category))
                        .foregroundStyle(Color("Status/Success"))
                    Text(goodTitle(for: category))
                        .font(.headline)
                        .foregroundStyle(Color("Status/Success"))
                }
                Divider().opacity(0.5)
                Text(goodMessage(for: category))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 10)
        }
//        .padding(16)
//        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
//        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
    
    private func goodTitle(for cat: CompostCategory) -> String {
        switch cat {
            case .temperature: return "Good temperature (warm)"
            case .moisture: return "Good moisture (humid)"
            case .balance: return "Good carbon/nitrogen balance"
            case .sizing: return "Good material sizing"
            case .aeration: return "Good aeration"
        }
    }

    private func iconFor(_ cat: CompostCategory) -> String {
        switch cat {
        case .moisture: return "drop"
        case .temperature: return "thermometer"
        case .balance: return "scalemass"
        case .sizing: return "scissors"
        case .aeration: return "wind"
        }
    }

    private func goodMessage(for cat: CompostCategory) -> String {
        switch cat {
            case .temperature: return "Temperature is healthy, keep it up!"
            case .moisture: return "Moisture level looks good, keep it up!"
            case .balance: return "Carbon/Nitrogen balance looks good."
            case .sizing: return "Material sizing looks good!"
            case .aeration: return "Aeration looks healthy!"
        }
    }
}

struct StatusChip: View {
    enum ChipType {
        case healthy, needAction, harvested
    }

    let type: ChipType

    var body: some View {
        Text(label)
            .padding(.horizontal,18)
            .padding(.vertical,8)
            .background(RoundedRectangle(cornerRadius: 100).fill(color))
            .foregroundStyle(.white)
            .font(.caption)
    }

    private var label: String {
        switch type {
        case .healthy: return "Healthy"
        case .needAction: return "Need Action"
        case .harvested: return "Harvested"
        }
    }

    private var color: Color {
        switch type {
        case .healthy: return Color("Status/Success")
        case .needAction: return Color("Status/Warning")
        case .harvested: return .blue
        }
    }
}



#Preview{
    // Dummy for visualization
    @Previewable @State var navigationPath = NavigationPath()
    // Dummy for visualization
    let method = CompostMethod(
        compostMethodId: 1,
        name: "Hot Compost",
        descriptionText: "Fast composting method for active gardeners",
        compostDuration1: 30,
        compostDuration2: 180,
        spaceNeeded1: 1,
        spaceNeeded2: 4
    )
    
    let compost = CompostItem(
        name: "Makmum Pile"
    )
    compost.compostMethodId = method // 1 is hot compost (predefined)
    let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)
    compost.creationDate = threeDaysAgo
//    compost.lastTurnedOver = threeDaysAgo
    compost.turnEvents = [TurnEvent(date: threeDaysAgo)]
    
    return UpdateCompostView(compostItem: compost, navigationPath: $navigationPath)
}

