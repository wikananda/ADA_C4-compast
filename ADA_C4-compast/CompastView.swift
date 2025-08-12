//
//  ContentView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 12/08/25.
//

import SwiftUI

struct CompastView: View {
    
    var body: some View {
        ZStack {
            TabView {
                Tab("Your Containers", systemImage: "arrow.up.bin.fill") {
                    Text("Container List")
                }
                
                Tab("Analyze", systemImage: "rectangle.and.text.magnifyingglass") {
                    Text("Analyzing composts")
                }
                
                Tab("History", systemImage: "text.document.fill") {
                    Text("Your composts history")
                }
            }
        }
    }
}

#Preview {
    CompastView()
}
