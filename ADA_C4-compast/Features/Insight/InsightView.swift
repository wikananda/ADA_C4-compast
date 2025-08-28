//
//  InsightView.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 27/08/25.
//

import SwiftUI

struct InsightData {
    var title: String
}

struct InsightView: View {
    
    private var insightData: [InsightData] = [
        InsightData(title: "Compost Harvested"),
        InsightData(title: "Trees Planted"),
        InsightData(title: "CO2e Avoided"),
    ]
    
    var body: some View {
        ZStack(alignment: .topLeading){
            HStack(alignment: .center, spacing: 0) {
                HStack (spacing: 10) {
                    Image("compost/logo-dark-green")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
                    Text("Insight")
                        .font(.custom("KronaOne-Regular", size: 20))
                        .foregroundStyle(Color("BrandGreenDark"))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            VStack(alignment: .leading, spacing: 32) {
                HStack(alignment: .center, spacing: 20) {
                    HStack(alignment: .center, spacing: 20){
                        ZStack(alignment: .center){
                            
                            Image(systemName: "arrow.3.trianglepath")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 24))
                            
                        }.frame(width: 58, height: 58)
                            .background(
                                Circle()
                                    .fill(Color("BrandGreenDark"))
                            )
                        
                        Text("Organic waste rescued from landfills")
                    }
                    
                    Spacer()
                    
                    VStack(){
                        VStack(alignment: .leading, spacing: 5){
                            Text("200 kg")
                                .font(.custom("KronaOne-Regular", size: 24))
                                .foregroundStyle(Color("BrandGreenDark"))
                                
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("Status/AddCompostBG"))
                .cornerRadius(20)
                
                VStack (spacing: 32){
                    HStack(){
                        Text("That's equivalent to")
                            .fontWeight(.bold)
                        
                        Spacer()
                    }.frame(maxWidth: .infinity)
                    
                    VStack(spacing: 20){
                        InsightCard()
                        InsightCard()
                        InsightCard()
                    }
                    
                    Button(action: {
                        
                    }) {
                        HStack(alignment: .center, spacing: 16){
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 18))
                                .foregroundStyle(Color.white)
                            
                            Text("Share Result")
                                .fontWeight(.bold)
                                .foregroundStyle(Color.white)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, maxHeight: 70)
                    .background(Color("BrandGreenDark"))
                    .clipShape(Capsule())
                }
            }
            .padding()
            .frame(maxHeight: .infinity)
        }
    }
}

struct InsightCard: View {
    
    @State var icon: String = "questionmark.circle"
    @State var title: String = "Insight"
    @State var data: String = "data"
    @State var measurement: String = "kg"
    
    var body: some View {
    
        HStack {
            HStack(alignment: .center, spacing: 20){
                ZStack(alignment: .center){
                    
                    Image(systemName: icon)
                        .foregroundStyle(Color.white)
                        .font(.system(size: 24))
                    
                }.frame(width: 58, height: 58)
                    .background(
                        Circle()
                            .fill(Color("BrandGreenDark"))
                    )
                
                Text(title)
            }
            Spacer()
            HStack(){
                Text(data)
                    .font(.custom("KronaOne-Regular", size: 24))
                    .foregroundStyle(Color("BrandGreenDark"))
                Text(measurement)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color("Status/AddCompostBG2"))
        .cornerRadius(20)
    
    }
    
}

#Preview {
    InsightView()
}
