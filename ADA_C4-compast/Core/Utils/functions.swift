//
//  functions.swift
//  ADA_C4-compast
//
//  Created by Gede Reva Prasetya Paramarta on 26/08/25.
//

import SwiftUI
import Foundation

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yyyy"
    return formatter
}()


// MARK: - Math helpers
@inlinable func clamp<T: Comparable>(_ x: T, _ lo: T, _ hi: T) -> T {
    min(max(x, lo), hi)
}

@inlinable func safeDiv(_ a: Double, _ b: Double, fallback: Double = 0) -> Double {
    b == 0 ? fallback : a / b
}

