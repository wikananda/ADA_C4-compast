//
//  YourCompostsView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 15/08/25.
//

import SwiftUI

struct YourCompostsView: View {
    var body: some View {
        VStack (spacing: 25) {
            HStack(spacing: 50) {
                Button(action: {} ) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                Button(action: {} ) {
                    Image(systemName: "trash")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            PileCard()
        }
    }
}

struct PileCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack (alignment: .leading) {
                    Text("Timbunan Pertama")
                        .font(.system(size: 24, weight: .bold))
                    Text("Kompos Putar")
                }
                Spacer()
                ZStack {
                    Text("Healthy")
                        .font(.caption)
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 10)
                .background(Color.gray)
                .clipShape(Capsule())
            }
                
        }
        .frame(width: 300, height: 200)
        .padding()
        .background(Color.white)
//        .border(Color.black)
        .cornerRadius(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black, lineWidth: 2)
        )
    }
}

#Preview {
    YourCompostsView()
}
