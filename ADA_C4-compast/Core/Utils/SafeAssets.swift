//
//  SafeAssets.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 27/08/25.
//

import SwiftUI

// Safe color lookup
extension Color {
    init(_ name: String, fallback: Color) {
        if let uiColor = UIColor(named: name) {
            self = Color(uiColor)
        } else {
            self = fallback
            #if DEBUG
            print("⚠️ Missing color asset: \(name). Using fallback.")
            #endif
        }
    }
}

// Safe image lookup
extension Image {
    static func named(_ name: String, fallback: Image = Image(systemName: "exclamationmark.triangle.fill")) -> Image {
        if UIImage(named: name) != nil {
            return Image(name)
        } else {
            #if DEBUG
            print("⚠️ Missing image asset: \(name). Using fallback.")
            #endif
            return fallback
        }
    }
}
