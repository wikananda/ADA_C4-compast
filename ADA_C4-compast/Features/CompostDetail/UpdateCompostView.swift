//
//  UpdateCompostView.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 20/08/25.
//

import SwiftUI

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
    
    init(compostItem: CompostItem, navigationPath: Binding<NavigationPath>) {
        self._compostItem = Bindable(compostItem)
        self.compostItem = compostItem
        self.compost_name = compostItem.name
//        self.compost_method = compostItem.compostMethodId?.name ?? ""
        self.status = compostItem.isHealthy
        self.createdAt = compostItem.creationDate
        self.currentTemperatureCategory = compostItem.temperatureCategory
        self._navigationPath = navigationPath

    }
    
    // Calculated variables
    private var turned_over: Int {
        Calendar.current.dateComponents([.day], from: compostItem.lastTurnedOver, to: Date()).day ?? 0
    }
    private var age: Int {
        Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24){
            
            //Header
            HStack{
                Button(action: {
                    dismiss()
                }){
                    Image(systemName: "chevron.left")
                }
                .foregroundStyle(Color("BrandGreenDark"))
                
                Spacer()
                
                Text("Update Compost")
                    .font(.custom("KronaOne-Regular", size: 16))
                    .foregroundStyle(Color("BrandGreenDark"))
                
                Spacer()
                
                Button(action: {
                }){
                    Image(systemName: "ellipsis.circle")
                }
                .foregroundStyle(Color("BrandGreenDark"))
            }
            
            ZStack (alignment: .bottom){
                ScrollView{
                    //Compost Title
                    HStack(alignment: .center){
                        Text(compost_name)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(status ? "Healthy" : "Need Action")
                            .padding(.horizontal,18)
                            .padding(.vertical,8)
                            .background(
                                RoundedRectangle(cornerRadius: 100)
                                    .fill(status ? Color("Status/Success") : Color("Status/Warning"))
                            )
                            .foregroundStyle(Color.white)
                            .font(.caption)
                    }
                    .padding(.top, 12)
                    
                    //Compost Temperature
                    VStack(spacing: 24){
                        HStack(alignment: .center){
                            VStack(alignment: .center){
                                Image(systemName: "arrow.trianglehead.2.clockwise")
                                    .foregroundStyle(Color("Status/Success"))
                                Text(turned_over == 0 ? "Today" : "\(turned_over) days ago")
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
                                Text("17 Feb 2025") //still a placeholder
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
                                    Text("Turn Compost")
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
                        

                        // Current status tiles (tap to open the combined sheet)
        //                ZStack(alignment: .trailing) {
        //                    Text("Temperature: \(compostItem.temperatureCategory)")
        //                        .frame(maxWidth: .infinity, maxHeight: 60)
        //                }
        //                .background(Color.gray.opacity(0.15))
        //                .cornerRadius(12)
        //                .onTapGesture { vitalsSheetPresented.toggle() }
        //
        //                ZStack(alignment: .trailing) {
        //                    Text("Moisture: \(compostItem.moistureCategory)")
        //                        .frame(maxWidth: .infinity, maxHeight: 60)
        //                }
        //                .background(Color.gray.opacity(0.1))
        //                .cornerRadius(12)
        //                .onTapGesture { vitalsSheetPresented.toggle() }

                        // Actionable advice
                        VStack(alignment: .leading, spacing: 16){
                            let items = CompostKnowledge.advice(for: compostItem)
                            if items.isEmpty {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                                    Text("All good! Your compost looks healthy.")
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.top, 6)
                                
                            } else {

                                ForEach(items) { issue in
                                   AdviceCard(issue: issue)
                                }
                            }
                            
                            
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
                }
                

                Spacer()
                
                
                Button(action: {
                }) {
                    HStack(){
                        Text("SAVE")
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(Color.white)
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: 60)
                .background(Color("BrandGreenDark"))
                .clipShape(Capsule())
            }
            
            
            
        }
        .padding(.horizontal, 24)
        .background(Color("Status/Background"))
        .navigationBarHidden(true)
        .sheet(isPresented: $vitalsSheetPresented) {
            UpdateCompostVitalsSheet(compostItem: compostItem)
        }

//        .sheet(isPresented: $tempSheetIsPresented) {
//            UpdateTemperatureView(selectedTemp: $selectedTemp, compostItem: compostItem)
//        }
//        .sheet(isPresented: $moistureSheetIsPresented) {
//            UpdateMoistureView(selectedMoist: $selectedMoisture, compostItem: compostItem)
//        }
    }
      
    
    func MixCompost() {
        compostItem.lastTurnedOver = Date()
        try? context.save()
    }
}

// MARK: - Advice Card

struct AdviceCard: View {
    let issue: CompostProblem
    var body: some View {
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
        .padding(.bottom, 24)
//        .padding(16)
//        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
//        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
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
    compost.lastTurnedOver = threeDaysAgo
    
    return UpdateCompostView(compostItem: compost, navigationPath: $navigationPath)
}

