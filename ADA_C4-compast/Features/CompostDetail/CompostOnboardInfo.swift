//
//  UpdateTemperature.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 22/08/25.
//

import SwiftUI

struct CompostOnboardInfo: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var backgroundColor: Color = Color(.systemGroupedBackground)
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Button(action: {
                    
                    dismiss()
                    }) {
                        Text("Next")
                    }
                
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color("BrandGreenDark"))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .padding(.horizontal, 16)
                .padding(.bottom, 50)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Close")
                            .foregroundStyle(Color("BrandGreenDark"))
                    }
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .background(backgroundColor)
        }
    }
}


#Preview {
    CompostOnboardInfo()
}
