//
//  ContentView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 12/08/25.
//

import SwiftUI

struct CompastView: View {
    @State private var selectedTab: Int = 0 // to be inserted to custom tab bar
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                switch selectedTab {
                case 0:
                    Text("Container List")
                case 1:
                    Text("Analyzing...")
                default:
                    Text("Your history")
                }
            }
            .frame(maxWidth:.infinity, maxHeight: .infinity)
            
            // the custom tab bar
            CustomTabView(selectedTab: $selectedTab)
                .padding(.horizontal)
        }
    }
}

#Preview {
    CompastView()
}
