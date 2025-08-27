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

struct UpdateCompostView: View {
    @Environment(\.modelContext) private var context
//    let compostItem : CompostItem
    @Bindable var compostItem: CompostItem
    @Environment(\.dismiss) private var dismiss
    
    // Navigation
//    @State private var tempSheetIsPresented: Bool = false
//    @State private var moistureSheetIsPresented: Bool = false
    @State private var vitalsSheetPresented: Bool = false
    
    //Compost identity
    @State private var compost_name : String
//    @State private var compost_method : String
    @State private var status : Bool
    
    //Compost Stats
    @State private var createdAt : Date
    @State private var currentTemperatureCategory: String
    
    @State private var selectedTemp: Option?
    @State private var selectedMoisture: Option?
    
    @Binding private var navigationPath: NavigationPath
//    var estimatedHarvestDate: Date?
    
    init(compostItem: CompostItem, navigationPath: Binding<NavigationPath>) {
        self._compostItem = Bindable(compostItem)
        self.compostItem = compostItem
        self.compost_name = compostItem.name
//        self.compost_method = compostItem.compostMethodId?.name ?? ""
        self.status = compostItem.isHealthy
        self.createdAt = compostItem.creationDate
        self.currentTemperatureCategory = compostItem.temperatureCategory
        self._navigationPath = navigationPath
//        self.estimatedHarvestDate = compostItem.harvestedAt
    }
    
    // Calculated variables
//    private var turned_over: Int {
//        Calendar.current.dateComponents([.day], from: compostItem.lastTurnedOver, to: Date()).day ?? 0
//    }
    private var age: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
    
//    private var estimatedHarvestDay: Int {
//        if let estimatedHarvestDate = self.estimatedHarvestDate {
//            return Calendar.current.dateComponents([.day], from: Date(), to: estimatedHarvestDate).day ?? 0
//        } else {
//            return 0
//        }
//    }
    
    // Menu states
    @State private var showRenameAlert = false
    @State private var renameText = ""
    @State private var showDeleteConfirm = false
    @State private var isMarkingHarvested = false

    
    private func markAsHarvested() {
        compostItem.harvestedAt = Date()
        try? context.save()
    }

    private func renameCompost() {
        let trimmed = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        compostItem.name = trimmed
        compost_name = trimmed  // keep your local state in sync
        try? context.save()
    }

    private func deleteCompost() {
        context.delete(compostItem)
        try? context.save()
        dismiss()
    }

    private var turned_over_text: String {
        if let days = compostItem.daysSinceLastTurn {
            return days == 0 ? "Today" : "\(days) days ago"
        } else {
            return "Never"
        }
    }
    
    private var turn_count_text: String {
        "\(compostItem.turnCount)"
    }

    
    var body: some View {
        VStack(alignment: .leading, spacing: 24){
            
            //Header
            HStack{
                Button(action: {
                    dismiss()
                }){
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22))
                }
                .foregroundStyle(Color("BrandGreenDark"))
                
                Spacer()
                
                Text("Update Compost")
                    .font(.custom("KronaOne-Regular", size: 16))
                    .foregroundStyle(Color("BrandGreenDark"))
                
                Spacer()
                
//                Button(action: {
//                }){
//                    Image(systemName: "ellipsis.circle")
//                        .font(.system(size: 22))
//                }
//                .foregroundStyle(Color("BrandGreenDark"))
                
                Menu {
                    Button {
                        markAsHarvested()
                    } label: {
                        Label("Mark As Harvested", systemImage: "checkmark.circle")
                    }

                    Button {
                        renameText = compostItem.name
                        showRenameAlert = true
                    } label: {
                        Label("Rename Compost", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete Compost", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 22))
                        .foregroundStyle(Color("BrandGreenDark"))
                }

            }
            
            ZStack (alignment: .bottom){
                ScrollView{
                    //Compost Title
                    HStack(alignment: .center){
                        Text(compost_name)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        StatusChip(type: {
                            switch compostItem.compostStatus {
                            case .healthy: return .healthy
                            case .needAction: return .needAction
                            case .harvested: return .harvested
                            }
                        }())
                        
                    }
                    .padding(.top, 12)
                    
                    //Compost Temperature
                    VStack(spacing: 24){
                        HStack(alignment: .center){
                            VStack(alignment: .center){
                                Image(systemName: "arrow.trianglehead.2.clockwise")
                                    .foregroundStyle(Color("Status/Success"))
                                Text(turned_over_text)          // "Today" / "3 days ago" / "Never"
                                    .font(.headline)
                                    .padding(.top, 4)
                                Text("Last turned")
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .center){
                                Image(systemName: "calendar")
                                    .foregroundStyle(Color("Status/Success"))
                                Text("\(age) day")
                                    .font(.headline)
                                    .padding(.top, 4)
                                Text("Age")
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .center){
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(Color("Status/Success"))
//                                Text("17 Feb 2025") //still a placeholder
                                Text(daysRemainingText(from: Date(), to: compostItem.estimatedHarvestAt))
                                    .font(.headline)
                                    .padding(.top, 4)

                                Text("Est. Harvest")
                                    .font(.subheadline)
                                
                            }
                        }
                        
                        HStack(spacing: 0){
                            Button(action: {
                                MixCompost()
                            }) {
                                HStack(){
                                    Image(systemName: "arrow.trianglehead.2.clockwise")
                                    Text("Mix")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .foregroundStyle(Color.white)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity ,maxHeight: 50)
                            .background(Color("compost/PileDirt"))
                            .clipShape(Capsule())
                            
                            Spacer()
                            
                            
                            Button(action: {
                                navigationPath.append(CompostNavigation.pilePrototype(compostItem.compostItemId))

                            }) {
                                HStack(){
                                    Image(systemName: "plus")
                                    Text("Add Material")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .foregroundStyle(Color.white)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity ,maxHeight: 50)
                            .background(Color("BrandGreenDark"))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                    )
                    
                    // placeholder temperature and moisture
                    VStack(alignment: .leading, spacing: 12) {
                        
                        // Header with formatted log date
                        HStack{
                            Text("Compost Log :  \(compostItem.lastLogged.ddMMyyyy())")
                                .font(.headline)
                                .foregroundStyle(Color("BrandGreenDark"))
                            
                            Spacer()
                            
                            Text(compostItem.lastLogged > Date().addingTimeInterval(-60*60*24) ? "Updated" : "Not Updated")
                                .padding(.horizontal,18)
                                .padding(.vertical,8)
                                .background(
                                    RoundedRectangle(cornerRadius: 100)
                                        .fill(compostItem.lastLogged > Date().addingTimeInterval(-60*60*24) ? Color("Status/Success"): Color("Status/Warning"))
                                )
                                .foregroundStyle(Color.white)
                                .font(.caption)
                        }
                        .padding(.top, 24)
                        
                        // Actionable advice
                        VStack(alignment: .leading, spacing: 16){
                            let items = CompostKnowledge.advice(for: compostItem)

                            let tempIssue = items.first(where: { $0.category == .temperature } )
                            AdviceCard(category: .temperature, issue: tempIssue)

                            let moistureIssue = items.first(where: { $0.category == .moisture })
                            AdviceCard(category: .moisture, issue: moistureIssue)
                            
                            Button(action: {
                                navigationPath.append(CompostNavigation.pilePrototype(compostItem.compostItemId))
                            }) {
                                HStack(){
                                    Image(systemName: "plus")
                                    Text("Update Log")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                }
                                .foregroundStyle(Color.white).onTapGesture { vitalsSheetPresented.toggle() }
                                
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity ,maxHeight: 50)
                            .background(Color("BrandGreenDark"))
                            .clipShape(Capsule())
                        }
                        
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                        )
                    }
                    .padding(.bottom, 100)
                }
                
                
                Spacer()
                
                
                VStack{
                    Button(action: {
                        
                    }) {
                        Text(compostItem.harvestedAt != nil ? "SAVED" : "SAVE")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, maxHeight: 60)
                            .foregroundStyle(Color.white)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .background(Color("BrandGreenDark"))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 10)
                .padding(.top, 48)
                .padding(.bottom, 0)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .white, location: 0.00),
                            Gradient.Stop(color: .white.opacity(0), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 1),
                        endPoint: UnitPoint(x: 0.5, y: 0)
                    )
                )
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

        // Delete confirmation
        .confirmationDialog("Delete Compost",
                            isPresented: $showDeleteConfirm,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteCompost() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this compost? This action cannot be undone.")
        }


//        .sheet(isPresented: $tempSheetIsPresented) {
//            UpdateTemperatureView(selectedTemp: $selectedTemp, compostItem: compostItem)
//        }
//        .sheet(isPresented: $moistureSheetIsPresented) {
//            UpdateMoistureView(selectedMoist: $selectedMoisture, compostItem: compostItem)
//        }
    }
      
    
    func MixCompost() {
        compostItem.turnNow(in: context)

        try? context.save()
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

