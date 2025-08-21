//
//  UpdateCompostView.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 20/08/25.
//

import SwiftUI

struct UpdateCompostView: View {
    
    //Compost identity
    private var compost_name : String = "Makmum Pile"
    private var compost_method : String = "Hot Compost"
    private var status : String = "Need Action"
    
    //Compost Stats
    private var turned_over : Int = 2
    private var createdAt : Date = Date()
    private var duration : Date = Date()
    
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
                
                Text(status)
            }
            //Compost Temperature
            HStack(alignment: .center){
                VStack(alignment: .leading){
                    Text(String(turned_over))
                    Text("Last turned")
                }
                
                Spacer()
                
                VStack(alignment: .leading){
                    Text("3 Day")
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
            
            Spacer()
            
            
        }
        .padding(.horizontal, 24)
    }
}

#Preview{
    UpdateCompostView()
}
