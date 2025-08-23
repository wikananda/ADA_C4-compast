//
//  UpdateCompostView.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 20/08/25.
//

import SwiftUI

struct UpdateCompostView: View {
    @Environment(\.modelContext) private var context
    let compostItem : CompostItem
    @Environment(\.dismiss) private var dismiss
    
    // Navigation
    @State private var tempSheetIsPresented: Bool = false
    @State private var moistureSheetIsPresented: Bool = false
    
    //Compost identity
    @State private var compost_name : String
    @State private var compost_method : String
    @State private var status : Bool
    
    //Compost Stats
    @State private var createdAt : Date
    @State private var currentTemperatureCategory: String
    
    @State private var selectedTemp: Option?
    @State private var selectedMoisture: Option?
    
    init(compostItem: CompostItem) {
        self.compostItem = compostItem
        self.compost_name = compostItem.name
        self.compost_method = compostItem.compostMethodId?.name ?? ""
        self.status = compostItem.isHealthy
        self.createdAt = compostItem.creationDate
        self.currentTemperatureCategory = compostItem.temperatureCategory
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
            
            //Compost Title
            HStack(alignment: .top){
                VStack(alignment: .leading){
                    Text(compost_name)
                    
                    HStack(alignment: .center){
                        Image(systemName: "leaf.arrow.trianglehead.clockwise")
                        Text(compost_method)
                    }
                }
                
                Spacer()
                
                Text(status ? "Healthy" : "Need Action")
            }
            
            //Compost Temperature
            HStack(alignment: .center){
                VStack(alignment: .leading){
                    Text(turned_over == 0 ? "Today" : "\(turned_over) days ago")
                    Text("Last turned")
                }
                
                Spacer()
                
                VStack(alignment: .leading){
                    Text("\(age) Day")
                    Text("Age")
                }
                
                Spacer()
                
                VStack(alignment: .leading){
                    Text("17 Feb 2025")
                    Text("Est. Harvest")
                }
            }.padding(16)
            
            VStack{
                
            }
            
            // placeholder button to mix
            HStack {
                Button(action: {
                    MixCompost()
                }) {
                    Text("Mix")
                        .frame(width: 50, height: 50)
                        .font(.body)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(5)
                        .foregroundStyle(.white)
                }
            }
            
            // placeholder temperature and moisture
            VStack (alignment: .leading, spacing: 50) {
                ZStack(alignment: .trailing) {
                    Text("Temperature: \(currentTemperatureCategory)")
                }
                .frame(maxWidth: .infinity, maxHeight: 100)
                .background(Color.gray)
                .cornerRadius(10)
                .onTapGesture { tempSheetIsPresented.toggle() }
                
                ZStack(alignment: .trailing) {
                    Text("Moisture: \(compostItem.moistureCategory)")
                }
                .frame(maxWidth: .infinity, maxHeight: 100)
                .background(Color.gray.opacity(0.5))
                .cornerRadius(10)
                .onTapGesture { moistureSheetIsPresented.toggle() }
            }
            
            Spacer()
            
            
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $tempSheetIsPresented) {
            UpdateTemperatureView(selectedTemp: $selectedTemp, compostItem: compostItem)
        }
        .sheet(isPresented: $moistureSheetIsPresented) {
            UpdateMoistureView(selectedMoist: $selectedMoisture, compostItem: compostItem)
        }
    }
    
    func MixCompost() {
        compostItem.lastTurnedOver = Date()
        try? context.save()
    }
}

#Preview{
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
        name: "Makmum Pile"
    )
    compost.compostMethodId = method
    let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)
    compost.creationDate = threeDaysAgo
    compost.lastTurnedOver = threeDaysAgo

    return UpdateCompostView(compostItem: compost)
}
