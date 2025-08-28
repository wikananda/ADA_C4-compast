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

func gcd(_ a: Int, _ b: Int) -> Int {
    guard a != 0 && b != 0 else {
        return 0
    }
    
    let remainder = abs(a) % abs(b)
    if remainder != 0 {
        return gcd(abs(b), remainder)
    } else {
        return abs(b)
    }
}

func simplifyRatio(_ numerator: Int, _ denominator: Int) -> (Int, Int) {
    let commonDivisor = gcd(numerator, denominator)
    guard commonDivisor > 0 else {
        return (0, 0)
    }
    return (numerator / commonDivisor, denominator / commonDivisor)
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
    let isShredded: Bool

    var body: some View {
        let base = (type == .green)
            ? Color("compost/PileGreen", fallback: Color.green.opacity(0.6))
            : Color("compost/PileBrown", fallback: Color.brown.opacity(0.7))

        ZStack {
            base

            // Shredded texture overlay (masked to the same wavy shape)
            if isShredded {
                Image.named("compost/shredded-overlay")
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
                .stroke(Color.white.opacity(1), lineWidth: 3)
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
    @Environment(\.modelContext) private var modelContext

    let compostItem: CompostItem

    private let bandBaseHeight: CGFloat = 120
    private let overlapFactor: CGFloat = 0.7
    private let initialOffset: CGFloat = 240
    
    var body: some View {
        GeometryReader { geo in
            let overlap = bandBaseHeight * overlapFactor
            let contentHeight = CGFloat(bands.count) * (bandBaseHeight - overlap) + overlap

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
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
                                        compostItem.recomputeAndStoreETA(in: modelContext)
                                    }
                                }
                            )
                        }
                    }
                    if !bands.isEmpty {
                        Color.clear.frame(height: initialOffset)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .bottom)
                .frame(height: max(geo.size.height, contentHeight + initialOffset), alignment: .bottom)
                .padding(.vertical, 16)
            }
        }
    }
}

struct PilePrototype: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isInfoVisible = false
    
    let compostItem: CompostItem
    
    @State private var ratio: CGFloat = 0.0
    @State private var greenAmount: Int = 0
    @State private var brownAmount: Int = 0
    @State private var initialStackCount = 0
    
    @State private var dropZoneArea: CGRect = .zero
    
    @State private var rec: BalanceRecommendation = computeBalanceRecommendation(browns: 0, greens: 0)

    @discardableResult
    func refreshBalance() -> CGFloat {
        let total = max(greenAmount + brownAmount, 1)
        let brownShare = CGFloat(brownAmount) / CGFloat(total)
        rec = computeBalanceRecommendation(browns: brownAmount, greens: greenAmount)
        return brownShare
    }
    
    @State private var bands: [PileBand] = []
    private var hasAnyMaterial: Bool { !bands.isEmpty }

    private func addMaterial(_ type: MaterialType) {
        let pileBand = PileBand(
            materialType: type.rawValue,
            isShredded: false,
            order: bands.count
        )
        bands.append(pileBand)
        if type == .green { greenAmount += 1 } else { brownAmount += 1 }
        ratio = refreshBalance()
        compostItem.recomputeAndStoreETA(in: modelContext)
    }

    private func removeLastBand() {
        guard let last = bands.popLast() else { return }
        if last.materialType == "green" {
            greenAmount = max(0, greenAmount - 1)
        } else {
            brownAmount = max(0, brownAmount - 1)
        }
        ratio = refreshBalance()
        compostItem.recomputeAndStoreETA(in: modelContext)
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
        ratio = refreshBalance()
    }

    private func saveCompostStacks() {
        guard bands.count > initialStackCount else { return }
        for band in bands[initialStackCount...] {
            let stack = CompostStack(
                brownAmount: band.materialType == "brown" ? 1 : 0,
                greenAmount: band.materialType == "green" ? 1 : 0,
                createdAt: Date(),
                isShredded: band.isShredded
            )
            stack.compostItemId = compostItem
            modelContext.insert(stack)
        }
        try? modelContext.save()
    }
    
    var body: some View {
        VStack {
            // Header
            HStack{
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                }
                .foregroundStyle(Color("BrandGreenDark", fallback: Color(red: 0.10, green: 0.28, blue: 0.20)))
                
                Spacer()
                
                Button(action: {
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
                            ? Color("BrandGreenDark", fallback: Color(red: 0.10, green: 0.28, blue: 0.20))
                            : Color.gray.opacity(0.35))
                .clipShape(Capsule())
                .disabled(!hasAnyMaterial)
            }
            .overlay(
                Text("Add Material")
                    .bold(true)
                    .font(.custom("KronaOne-Regular", size: 16))
                    .foregroundStyle(Color("BrandGreenDark", fallback: Color(red: 0.10, green: 0.28, blue: 0.20))),
                alignment: .center
            )
            .padding()
            
            ZStack(alignment: .top) {
                ZStack(alignment: .bottom) {
                    // Pile canvas
                    CompostCanvas(bands: $bands, compostItem: compostItem)
                        .frame(maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        .overlay(alignment: .topTrailing) {
                            if !bands.isEmpty {
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        removeLastBand()
                                    }
                                }) {
//                                    Text("\(Image(systemName: "minus"))")
                                    Image(systemName: "minus")
                                        .frame(width: 32, height: 32)
                                        .font(.system(size: 28))
                                        .bold(true)
                                        .padding()
                                        .background(Color.black.opacity(0.5))
                                        .foregroundStyle(.white)
                                        .clipShape(Circle())
                                }
                                .padding()
                            }
                        }
                    
                    // Controls
                    VStack(spacing: 32){
                        HStack{
                            let simplifiedRatio = simplifyRatio(greenAmount, brownAmount)
                            HStack(spacing: 0) {
                                Text("RATIO")
                                    .fontWeight(.bold)
                                    .padding(.trailing, 16)
                                Text("\(simplifiedRatio.0) : \(simplifiedRatio.1)")
                                    .fontWeight(.bold)
                                    .padding(.trailing, 16)
                            }
                            
                            Button(action:{
                                isInfoVisible.toggle()
                                
                            }){
                                Image(systemName: "questionmark")
                                    .foregroundStyle(.white)
                                    .fontWeight(.bold)
                            }
                            .frame(width: 38, height: 38)
                            .background(Color("BrandGreenDark", fallback: Color(red: 0.10, green: 0.28, blue: 0.20)))
                            .cornerRadius(100)
                                
                            Spacer()
                            
                            Button(action: {
                                withAnimation(){
                                    bands.removeAll()
                                    brownAmount = 0
                                    greenAmount = 0
                                    ratio = refreshBalance()
                                }
                            }) {
                                Text("Reset")
                                    .frame(width: 50, height: 10)
                                    .font(.body)
                                    .padding()
                                    .foregroundStyle(Color.white)
                                    .background(Color.red)
                                    .cornerRadius(100)
                            }
                        }
                        HStack(spacing: 25) {
                            WasteCard(
                                dropZoneArea: $dropZoneArea,
                                label: "+ Green",
                                color: Color("BrandGreenDark", fallback: Color.green),
                                actions: { withAnimation(){ addMaterial(.green) } }
                            )
                            
                            WasteCard(
                                dropZoneArea: $dropZoneArea,
                                label: "+ Brown",
                                color: Color("compost/PileBrown", fallback: Color.brown),
                                actions: { withAnimation(){ addMaterial(.brown) } }
                            )
                        }
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("BrandGreenDark", fallback: Color(red: 0.10, green: 0.28, blue: 0.20)).opacity(0.5), lineWidth: 2)
                    )
                    .padding()
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)
                .padding(.top, 150)
                
                HStack(alignment: .top, spacing: 20){
                    Image.named("compost/add-material-logo")
                    BalanceRecommendationView(rec: rec)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.move(edge: .top))
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .background(Color("Status/AddCompostBG", fallback: .gray.opacity(0.06)))
        .navigationBarHidden(true)
        .onAppear { loadExistingStacks() }
        .sheet(isPresented: $isInfoVisible) {
            CompostOnboardInfo()
        }
//        .sheet
    }
}

// MARK: Custom Components

struct WasteCard: View {
    @State private var offset: CGSize = .zero
    @State private var isPressed: Bool = false
    @Binding var dropZoneArea: CGRect
    
    var label: String = "btn"
    var color: Color = .gray
    var actions: () -> Void
    
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
        .onTapGesture { actions() }
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    withAnimation(.spring(duration: 0.25, bounce: 0.35)) {
                        offset = value.translation
                        isPressed = true
                    }
                }
                .onEnded { value in
                    if dropZoneArea.contains(value.location) {
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
        ZStack(alignment: .leading) {
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
    compost.turnEvents = [TurnEvent(date: threeDaysAgo)]
    
    return PilePrototype(compostItem: compost)
}



