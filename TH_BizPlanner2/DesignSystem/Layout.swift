//
//  Layout.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

// MARK: - Layout Constants
struct Layout {
    // MARK: - Corner Radius
    static let cornerRadiusCard: CGFloat = 16
    static let cornerRadiusInput: CGFloat = 12
    static let cornerRadiusButton: CGFloat = 24
    
    // MARK: - Spacing
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    
    // MARK: - Shadow Levels
    static let shadowLevel1 = Shadow(blur: 12, y: 8, opacity: 0.25)
    static let shadowLevel2 = Shadow(blur: 24, y: 16, opacity: 0.35)
    
    struct Shadow {
        let blur: CGFloat
        let y: CGFloat
        let opacity: Double
        
        var color: Color {
            Color.black.opacity(opacity)
        }
    }
}

// MARK: - Glass Card Style
struct GlassCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusCard)
                    .fill(Color.surface.opacity(0.8))
                    .background(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.cornerRadiusCard)
                            .stroke(Color.border.opacity(0.8), lineWidth: 1.5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.cornerRadiusCard)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.15), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: Layout.shadowLevel1.color,
                radius: Layout.shadowLevel1.blur,
                y: Layout.shadowLevel1.y
            )
    }
}

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool
    
    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.subtitle)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusButton)
                    .fill(
                        isEnabled
                            ? (configuration.isPressed ? Color.primaryVariant : Color.primary)
                            : Color.surface
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .disabled(!isEnabled)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary)
            .font(.subtitle)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusButton)
                    .stroke(Color.primary, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func glassCard() -> some View {
        self.modifier(GlassCardStyle())
    }
    
    func primaryButton(isEnabled: Bool = true) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
    }
    
    func secondaryButton() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
}