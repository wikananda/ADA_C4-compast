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
            
            HStack{
                Button(action: {
                    dismiss()
                }){
                    Image(systemName: "chevron.left")
                }
                .foregroundStyle(Color("BrandGreenDark"))
                
                Spacer()
                
//                Text("Update Compost")
                Image("navigation/nav-UpdateCompost")
                
                Spacer()
                
                Button(action: {
                }){
                    Image(systemName: "ellipsis.circle")
                }
                .foregroundStyle(Color("BrandGreenDark"))
            }
            
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
                        Text("17 Feb 2025")
                            .font(.headline)
                            .padding(.top, 4)
                        Text("Est. Harvest")
                            .font(.subheadline)

                    }
                }
                
                HStack(){
                    Button(action: {}) {
                        HStack(){
                            Image(systemName: "arrow.trianglehead.2.clockwise")
                                Text("Turn Compost")
                                    .font(.caption)
                        }
                        .foregroundStyle(Color.white)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.black.opacity(0.5))
                    )
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack(){
                            Image(systemName: "plus")
                            Text("Add Material")
                                .font(.caption)
                        }
                        .foregroundStyle(Color.white)
                    }
                    .padding(16)
                    .frame(width: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color("BrandGreen"))
                    )
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
            )
                
            
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
        .padding(.horizontal, 24) .background(Color("Status/Background"))
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
