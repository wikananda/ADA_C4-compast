//
//  YourCompostsView.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 15/08/25.
//

import SwiftUI
import SwiftData

struct YourCompostsView: View {
    @Query private var compostItems: [CompostItem]
    @State private var showingNewCompost: Bool = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack (spacing: 25) {
            HStack(spacing: 50) {
                Button(action: { showingNewCompost = true} ) {
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
//            PileCard()
            if compostItems.isEmpty {
                Text("No composts yet. Tap + to add one.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(compostItems) { item in
                    PileCard(item: item)
                        .contextMenu {
                            Button(role: .destructive) {
                                modelContext.delete(item)
                                try? modelContext.save()
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $showingNewCompost) {
            NewCompostView()
        }
    }
}

struct PileCard: View {
    var item: CompostItem?
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack (alignment: .top) {
                VStack (alignment: .leading) {
                    Text("\(item?.name ?? "Nama Kompos")")
                        .font(.system(size: 24, weight: .bold))
                    Text(item?.compostMethodId?.name ?? "")
                }
                Spacer()
                ZStack {
                    Text(item?.healthy ?? true ? "Healthy" : "Need Action")
                        .font(.caption)
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 10)
                .background(Color.gray)
                .clipShape(Capsule())
            }
            HStack {
                VStack {
                    Image(systemName: "thermometer.variable")
                    Text("\(item?.temperature ?? 0)°C")
                }
                Spacer()
                VStack {
                    Image(systemName: "humidity.fill")
                    Text("\(item?.moisture ?? 0)%")
                }
                Spacer()
                VStack {
                    Image(systemName: "calendar")
                    let dateAdded = item?.dateAdded ?? Date()
                    let age = Calendar.current.dateComponents([.day], from: dateAdded, to: Date()).day ?? 0
                    Text("\(age) days")
                }
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
