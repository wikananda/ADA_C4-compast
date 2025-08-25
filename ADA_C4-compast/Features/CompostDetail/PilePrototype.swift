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
//struct PileBand: Identifiable {
//    let id = UUID()
//    let type: MaterialType
//    var isShredded: Bool = false
//}


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
    let isShredded: Bool

    var body: some View {
        let base = type == .green ? Color("compost/PileGreen", default: Color.green.opacity(0.6))
                                  : Color("compost/PileBrown", default: Color.brown.opacity(0.7))

        ZStack {
            base
            LinearGradient(colors: [Color.white.opacity(0.5), .clear],
                           startPoint: .topLeading, endPoint: .bottomTrailing)

            // Shredded texture overlay (masked to the same wavy shape)
            if isShredded {
                Image("compost/shredded-overlay")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .opacity(1)
                    .mask(WavyTopShape(phase: phase))
                    .allowsHitTesting(false)
            }
        }
        .mask(WavyTopShape(phase: phase))
        .overlay(
            WavyTopShape(phase: phase)
                .stroke(Color.white.opacity(1), lineWidth: 8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct BandView: View {
    let band: PileBand
    let index: Int
    let bandHeight: CGFloat
    let overlap: CGFloat
    let totalBands: Int
    let onTap: () -> Void

    var body: some View {
        let z = Double(totalBands - index)
        let materialType = MaterialType(rawValue: band.materialType) ?? .green

        PileBandView(
            type: materialType,
            phase: CGFloat(index).truncatingRemainder(dividingBy: 2) * .pi/2,
            isShredded: band.isShredded
        )
        .frame(height: bandHeight)
        .frame(maxWidth: .infinity)
        .offset(y: -CGFloat(index) * (bandHeight - overlap))
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        .zIndex(Double(totalBands - index))
        .onTapGesture(perform: onTap)
    }
}


// The canvas that stacks bands from bottom up
struct CompostCanvas: View {
    @Binding var bands: [PileBand]

    private let bandBaseHeight: CGFloat = 120
    private let overlapFactor: CGFloat = 0.7

    var body: some View {
        GeometryReader { geo in
            let overlap = bandBaseHeight * overlapFactor
            let contentHeight = CGFloat(bands.count) * (bandBaseHeight - overlap) + overlap // bandBaseHeight + (N - 1) * (bandBaseHeight - overlap)

            ScrollView(.vertical, showsIndicators: true) {
                ZStack(alignment: .bottom) {
                    ForEach(Array(bands.enumerated()), id: \.element.pileBandId) { idx, band in
                        BandView(
                            band: band,
                            index: idx,
                            bandHeight: bandBaseHeight,
                            overlap: overlap,
                            totalBands: bands.count,
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                    bands[idx].isShredded.toggle()
                                }
                            }
                        )
                    }
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .bottom
                )
                .frame(height: max(geo.size.height, contentHeight), alignment: .bottom)
//                .frame(
//                    maxWidth: .infinity,
//                    minHeight: geo.size.height,
//                    idealHeight: contentHeight,
//                    alignment: .bottom
//                )
                .padding(.vertical, 16)
            }
        }
    }
}

    

struct PilePrototype: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let compostItem: CompostItem
    
    @State private var ratio: CGFloat = 0.0
    @State private var greenAmount: Int = 0
    @State private var brownAmount: Int = 0
    @State private var initialStackCount = 0
    
    @State private var dropZoneArea: CGRect = .zero
    
    @State var recommendation: String = "This is a recommendation"
    
    @State private var bands: [PileBand] = []
    
    private var hasAnyMaterial: Bool { !bands.isEmpty }

//    private let maxPerType = 10
    private func addMaterial(_ type: MaterialType) {
//        let countForType = bands.filter { $0.materialType == type.rawValue }.count
//        guard countForType < maxPerType else { return }
        
        let pileBand = PileBand(
            materialType: type.rawValue,
            isShredded: false,
            order: bands.count,
        )
        bands.append(pileBand)
//        bands.insert(pileBand, at: 0)
        print("bands count: \(bands.count)")
        if type == .green { greenAmount += 1 } else { brownAmount += 1 }
        ratio = calculateRatio()
    }

    private func loadExistingStacks() {
        let stacks = compostItem.compostStacks.sorted { $0.createdAt < $1.createdAt }
        bands = stacks.enumerated().map { idx, s in
            PileBand(
                materialType: s.greenAmount == 1 ? "green" : "brown",
                isShredded: s.isShredded,
                order: idx
            )
        }
        initialStackCount = bands.count

        greenAmount = stacks.reduce(0) { $0 + $1.greenAmount }
        brownAmount = stacks.reduce(0) { $0 + $1.brownAmount }
        ratio = calculateRatio()
    }

    private func saveCompostStacks() {
        // let existingStacks = compostItem.compostStacks
        // existingStacks.forEach { modelContext.delete($0)}
        guard bands.count > initialStackCount else { return }
        for band in bands[initialStackCount...] {
            let stack = CompostStack(
                brownAmount: band.materialType == "brown" ? 1 : 0,
                greenAmount: band.materialType == "green" ? 1 : 0, 
                createdAt: Date(),
                isShredded: band.isShredded,
            )
            stack.compostItemId = compostItem
            modelContext.insert(stack)
        }
        try? modelContext.save()
        print("Saving...")
    }
    
    // To calculate ratio of brown and green wastes
    func calculateRatio() -> CGFloat {
        var ratio: CGFloat = 0.0
        if greenAmount == 0 && brownAmount == 0 {
            ratio = 0.0
            
            recommendation = "Hendy is happy with your current waste ratio!"
            
        } else {
            ratio = CGFloat(brownAmount) / CGFloat(greenAmount + brownAmount)
            
            recommendation = "Your current waste ratio is \(Int(ratio * 100))%. Try to reduce your green waste."
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
                
                
//                Button(action: {
//                }){
//                    Image(systemName: "book.pages")
//                        .resizable()
//                        .frame(width: 20, height: 28)
//                }
//                .foregroundStyle(Color("BrandGreenDark"))
                
                
                Button(action: {
                    // do finish action
                    saveCompostStacks()
                    dismiss()
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
            .overlay(
                Text("Add Material")
                    .bold(true)
                    .font(.custom("KronaOne-Regular", size: 16))
                    .foregroundStyle(Color("BrandGreenDark")),
                alignment: .center
            )
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
                    )
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .top))
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
            
            VStack {
                // Pile canvas
                CompostCanvas(bands: $bands)   // <-- binding
                    .frame(maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
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
                        withAnimation(){
                            bands.removeAll()
                            brownAmount = 0
                            greenAmount = 0
                            ratio = calculateRatio()
                        }
                    }) {
                        Text("Reset")
                            .frame(width: 50, height: 10)
                            .font(.body)
                            .padding()
                            .foregroundStyle(Color.white).background(Color("Status/Danger"))
                            .cornerRadius(100)
                    }
                    
                    
                }
                HStack(spacing: 25) {
                    
                    WasteCard(
                        dropZoneArea: $dropZoneArea,
                        label: "+ Green",
                        color: Color("BrandGreenDark", default: Color.green),
                        actions: { withAnimation(){addMaterial(.green)} }
                    )
                    
                    WasteCard(
                        dropZoneArea: $dropZoneArea,
                        label: "+ Brown",
                        color: Color("compost/PileBrown"),
                        actions: { withAnimation(){addMaterial(.brown)} }
                    )
                }
            }
            .padding()
            .background(.white)
        }
        .background(Color("Status/AddCompostBG"))
        .navigationBarHidden(true)
        .onAppear {
            loadExistingStacks()
        }
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
    // Dummy for visualization
    let method = CompostMethod(
        compostMethodId: 1,
        name: "Hot Compost",
        descriptionText: "",
        compostDuration1: 30,
        compostDuration2: 180,
        spaceNeeded1: 1,
        spaceNeeded2: 4,
    )
    let compost = CompostItem(
        name: "Makmum Pile"
    )
    compost.compostMethodId = method
    let threeDaysAgo = Date().addingTimeInterval(-3 * 24 * 60 * 60)
    compost.creationDate = threeDaysAgo
    compost.lastTurnedOver = threeDaysAgo
    
    return PilePrototype(compostItem: compost)
}
