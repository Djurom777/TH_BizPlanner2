//
//  Colors.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

extension Color {
    // MARK: - Primary Colors
    static let primary = Color(hex: "#0052CC")
    static let primaryVariant = Color(hex: "#2E6DD8")
    
    // MARK: - Accent Colors
    static let accentGold = Color(hex: "#FFD700")
    static let accentOrange = Color(hex: "#FF7A00")
    static let accentGreen = Color(hex: "#00A86B")
    
    // MARK: - Ink Colors
    static let inkPrimary = Color(hex: "#0B1020")
    static let inkPrimaryDark = Color(hex: "#EAF1FF")
    
    // MARK: - Surface Colors
    static let surfaceHigh = Color(hex: "#0F1426")
    static let surface = Color(hex: "#151B2E")
    static let surfaceLow = Color(hex: "#1D2440")
    static let border = Color(hex: "#24305A")
    
    // MARK: - Status Colors
    static let success = Color(hex: "#27AE60")
    static let warning = Color(hex: "#F2994A")
    static let error = Color(hex: "#EB5757")
    
    // MARK: - Gradients
    static let appBackground = LinearGradient(
        colors: [
            Color.inkPrimary,
            Color.surface,
            Color.inkPrimary
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let primaryGlow = RadialGradient(
        colors: [
            Color.primary.opacity(0.35),
            Color.primaryVariant.opacity(0.20),
            Color.clear
        ],
        center: .center,
        startRadius: 0,
        endRadius: 100
    )
    
    static let goldSheen = LinearGradient(
        colors: [
            Color.accentGold,
            Color.white.opacity(0.7)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}