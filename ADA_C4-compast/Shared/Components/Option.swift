//
//  Option.swift
//  ADA_C4-compast
//
//  Shared Component - Reusable Option Model
//

import SwiftUI

/// A selectable option model used throughout the app
/// for wizard flows and selection screens.
struct Option: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color
}
