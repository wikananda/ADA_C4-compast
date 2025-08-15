//
//  PilePrototype.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 14/08/25.
//

import SwiftUI

struct PilePrototype: View {
    @State private var ratio: CGFloat = 0.0
    @State private var greenAmount: Int = 0
    @State private var brownAmount: Int = 0
    
    @State private var dropZoneArea: CGRect = .zero
    
    // To calculate ratio of brown and green wastes
    func calculateRatio() -> CGFloat {
        var ratio: CGFloat = 0.0
        if greenAmount == 0 && brownAmount == 0 {
            ratio = 0.0
        } else {
            ratio = CGFloat(brownAmount) / CGFloat(greenAmount + brownAmount)
        }
        return ratio
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack(spacing: 20) {
                    Text("Green: \(greenAmount)")
                    Text("Brown: \(brownAmount)")
                    Text("Ratio: \(ratio)")
                }
                RatioBar(ratio: $ratio)
                VStack {
                    Image(systemName: "arrow.up.bin.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                }
                .padding(50)
                .border(Color.green)
                // Calculate VStack frame area
                // GeometryReader in overlay so not disrupt current layout
                .overlay(
                    GeometryReader { geo in
                        Color.clear
                            .onChange(of: geo.frame(in: .global), initial: true){ oldFrame, newFrame in
                                dropZoneArea = newFrame
                            }
                    }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
            
            HStack {
                Button(action: {}) {
                    Text("Mix")
                        .frame(width: 50, height: 50)
                        .font(.body)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(5)
                        .foregroundStyle(.white)
                }
                
                WasteCard(
                    dropZoneArea: $dropZoneArea,
                    label: "Green",
                    color: .green,
                    actions: {
                        greenAmount += 1
                        ratio = calculateRatio()
                    }
                )
                WasteCard(
                    dropZoneArea: $dropZoneArea,
                    label: "Brown",
                    color: .brown,
                    actions: {
                        brownAmount += 1
                        ratio = calculateRatio()
                    }
                )

                Button(action: {
                    brownAmount = 0
                    greenAmount = 0
                    ratio = calculateRatio()
                }) {
                    Text("Reset")
                        .frame(width: 50, height: 50)
                        .font(.body)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(5)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
    }
}


// MARK: Custom Components

struct WasteCard: View {
    @State private var offset: CGSize = .zero // Calculating offset when button being dragged
    @State private var isPressed: Bool = false
    @Binding var dropZoneArea: CGRect
    
    var label: String = "btn"
    var color: Color = .gray
    var actions: () -> Void // For accepting custom functions
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(color)
                .frame(width: 75, height: 50)
                .scaleEffect(isPressed ? 1.25 : 1)
                .overlay {
                    Text(label)
                        .foregroundStyle(.white)
                        .font(.body)
                }
        }
        .offset(offset)
        .onTapGesture {
            actions()
        }
        .gesture(
            // For dragging the card
            DragGesture(coordinateSpace: .global)
                // Capturing the offset when still being dragged
                .onChanged{ value in
                    withAnimation(.spring(duration: 0.25, bounce: 0.35)) {
                        offset = value.translation
                        isPressed = true
                    }
                }
                // Checking if the final location is inside dropzone
                .onEnded { value in
                    let endPoint = value.location
                    if dropZoneArea.contains(endPoint) {
                        actions()
                    }

                    withAnimation(.spring(duration: 0.25, bounce: 0.35)) {
                        offset = .zero
                        isPressed = false
                    }
                }
        )
    }
}

struct RatioBar: View {
    @Binding var ratio: CGFloat
    
    var body: some View {
        ZStack (alignment: .leading) {
            Rectangle()
                .frame(maxWidth: 400, maxHeight: 15)
                .clipShape(Capsule())
                .foregroundStyle(Color.green)
            Rectangle()
                .frame(maxHeight: 15)
                .frame(width: 400 * ratio)
                .clipShape(Capsule())
                .foregroundStyle(Color.brown)
            
        }
    }
}

#Preview {
    PilePrototype()
}
