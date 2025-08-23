//
//  PilePrototype.swift
//  ADA_C4-compast
//
//  Created by Komang Wikananda on 14/08/25.
//

import SwiftUI



// Which material was added
enum MaterialType: String, Identifiable, Hashable {
    case green, brown
    var id: String { rawValue }
}

// One band = one bucket
struct PileBand: Identifiable {
    let id = UUID()
    let type: MaterialType
}

// A wavy shape for the band top
struct WavyTopShape: Shape {
    var phase: CGFloat = 0
    var amplitude: CGFloat = 20
    var baseline: CGFloat = 0.5

    func path(in rect: CGRect) -> Path {
        func topY(_ x: CGFloat) -> CGFloat {
            let mid = rect.height * baseline
            return mid - sin((x / rect.width) * .pi * 2 + phase) * amplitude
        }

        var path = Path()
        // bottom edge
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        // right edge up to top
        path.addLine(to: CGPoint(x: rect.width, y: topY(rect.width)))

        // wavy top from right -> left
        let steps = 50
        for i in stride(from: steps, through: 0, by: -1) {
            let x = CGFloat(i) / CGFloat(steps) * rect.width
            path.addLine(to: CGPoint(x: x, y: topY(x)))
        }

        // close on the left edge
        path.closeSubpath()
        return path
    }
}


// One visual band (color + subtle pattern)
struct PileBandView: View {
    let type: MaterialType
    let phase: CGFloat
    
    var body: some View {
        let base = type == .green ? Color("compost/PileGreen", default: Color.green.opacity(0.6))
                                  : Color("compost/PileBrown", default: Color.brown.opacity(0.7))
        
        ZStack {
            base
            // light organic texture suggestion (optional)
            LinearGradient(colors: [Color.white.opacity(0.5), .clear],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        .mask(WavyTopShape(phase: phase))
        .overlay(
            WavyTopShape(phase: phase)
                .stroke(Color.white.opacity(1), lineWidth: 8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// The canvas that stacks bands from bottom up
struct CompostCanvas: View {
    let bands: [PileBand]

    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let n = max(bands.count, 1)

            // Overlap as a fraction of each band’s height
            let overlapFactor: CGFloat = 0.65  // 0.0 = no overlap, 0.35 = nice strata
            // Solve for bandH so the stack exactly fills the canvas height:
            // totalHeight = bandH + (n-1) * (bandH * (1 - overlapFactor)) = h
            let bandH = h / (1 + CGFloat(n - 1) * (1 - overlapFactor))
            let overlap = bandH * overlapFactor

            ZStack(alignment: .bottom) {
                Color("BrandSoil", default: Color(red: 0.25, green: 0.18, blue: 0.14))
                    .ignoresSafeArea()

                // Draw in original order; zIndex ensures older sit on top.
                ForEach(Array(bands.enumerated()), id: \.element.id) { idx, band in
                    let z = Double(n - idx) // oldest highest z
                    PileBandView(type: band.type,
                                 phase: CGFloat(idx).truncatingRemainder(dividingBy: 2) * .pi/2)
                        .frame(height: bandH)
                        .frame(maxWidth: .infinity)
                        .offset(y: -CGFloat(idx) * (bandH - overlap))
                        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                        .zIndex(z)
                }
            }
        }
    }
}
    

struct PilePrototype: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var ratio: CGFloat = 0.0
    @State private var greenAmount: Int = 0
    @State private var brownAmount: Int = 0
    
    @State private var dropZoneArea: CGRect = .zero
    
    @State private var recommendation: String = "This is a recommendation"
    
    @State private var bands: [PileBand] = []
    
    private var hasAnyMaterial: Bool { !bands.isEmpty }


    private let maxPerType = 5
    private func addMaterial(_ type: MaterialType) {
        let countForType = bands.filter { $0.type == type }.count
        guard countForType < maxPerType else { return }
        bands.append(.init(type: type))  // newest goes to bottom visually via zIndex above
        if type == .green { greenAmount += 1 } else { brownAmount += 1 }
        ratio = calculateRatio()
    }


    
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
            
            //Header
            HStack{
                Button(action: {
                    dismiss()
                }){
                    Image(systemName: "chevron.left")
                }
                .foregroundStyle(Color("BrandGreenDark"))
                
                Spacer()
                
                Image("navigation/nav-AddMaterial")
                
                Spacer()
                
//                Button(action: {
//                }){
//                    Image(systemName: "book.pages")
//                        .resizable()
//                        .frame(width: 20, height: 28)
//                }
//                .foregroundStyle(Color("BrandGreenDark"))
                
                
                Button(action: {
                    // do finish action
                }) {
                    Text("Finish")
                        .font(.headline.weight(.semibold))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .foregroundStyle(.white)
                }
                .background(hasAnyMaterial
                            ? Color("BrandGreenDark", default: Color(red: 0.10, green: 0.28, blue: 0.20))
                            : Color.gray.opacity(0.35))
                .clipShape(Capsule())
                .disabled(!hasAnyMaterial)

                
            }
            .padding()
            
            HStack(alignment: .center, spacing: 20){
                Image("compost/add-material-logo")
                Text(recommendation)
                    .padding(16)
                    .foregroundStyle(Color.black.opacity(0.8)   )
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .stroke(Color.black.opacity(0.1))
                    ).frame(maxWidth: .infinity)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            
            VStack {
                // Pile canvas
                CompostCanvas(bands: bands)
                    .frame(height: 400)      // adjust to your layout
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    .padding(.horizontal, 0)
                    .padding(.bottom, 8)
                
                // Drop zone icon (kept; we still capture its frame)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            
            Spacer()
            
            VStack(spacing: 32){
                HStack{
                    
                    Text("RATIO: \(Int(greenAmount)) / \(Int(brownAmount))")
                        .fontWeight(.bold)
                        .padding(.trailing, 16)
                    
                    Button(action:{}){
                        Image(systemName: "questionmark")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                    }
                    .frame(width: 38, height: 38)
                    .background(Color("BrandGreenDark"))
                    .cornerRadius(100)
                        
                    
                    Spacer()
                    
                    


                    Button(action: {
                        bands.removeAll()
                        brownAmount = 0
                        greenAmount = 0
                        ratio = calculateRatio()
                    }) {
                        Text("Reset")
                            .frame(width: 50, height: 10)
                            .font(.body)
                            .padding()
                            .foregroundStyle(Color.white).background(Color("Status/Danger"))
                            .cornerRadius(100)
                    }
                    
                    
                }
                HStack {
                    
                    WasteCard(
                        dropZoneArea: $dropZoneArea,
                        label: "+ Green",
                        color: Color("BrandGreenDark", default: Color.green),
                        actions: { addMaterial(.green) }
                    )
                    
                    WasteCard(
                        dropZoneArea: $dropZoneArea,
                        label: "+ Brown",
                        color: Color("compost/PileBrown"),
                        actions: { addMaterial(.brown) }
                    )
                }
            }
            .padding()
            .background(.white)
        }
        .background(Color("Status/AddCompostBG"))
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
            RoundedRectangle(cornerRadius: 100)
                .fill(color)
                .scaleEffect(isPressed ? 1.25 : 1)
                .overlay {
                    Text(label)
                        .foregroundStyle(.white)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, maxHeight: 80)
        }
        .frame(maxWidth: .infinity)
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
