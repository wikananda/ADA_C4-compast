//
//  YearlyInsightView.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 27/08/25.
//

import SwiftUI


struct YearlyInsightView: View {
    
    
    var body: some View {
        ZStack(alignment: .topLeading){
            HStack(alignment: .center, spacing: 0) {
                HStack (spacing: 10) {
                    Image("compost/logo-dark-green")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
                    Text("Yearly Insight")
                        .font(.custom("KronaOne-Regular", size: 20))
                        .foregroundStyle(Color("BrandGreenDark"))
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            VStack(alignment: .leading, spacing: 32) {
                
                VStack(){
                    
                }
                
                VStack (spacing: 32){
                    HStack(){
                        Text("May 2025 details")
                            .foregroundStyle(Color.black.opacity(0.7))
                        
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

#Preview {
    YearlyInsightView()
}
