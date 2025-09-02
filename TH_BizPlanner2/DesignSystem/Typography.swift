//
//  Typography.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

extension Font {
    // MARK: - Typography Scale
    static let display = Font.system(size: 28, weight: .semibold, design: .default)
    static let title = Font.system(size: 22, weight: .semibold, design: .default)
    static let subtitle = Font.system(size: 17, weight: .medium, design: .default)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let caption = Font.system(size: 13, weight: .regular, design: .default)
}

// MARK: - Text Styles
struct AppTextStyle: ViewModifier {
    let style: TextStyle
    let color: Color
    
    enum TextStyle {
        case display
        case title
        case subtitle
        case body
        case caption
        
        var font: Font {
            switch self {
            case .display: return .display
            case .title: return .title
            case .subtitle: return .subtitle
            case .body: return .body
            case .caption: return .caption
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .foregroundColor(color)
    }
}

extension Text {
    func appStyle(_ style: AppTextStyle.TextStyle, color: Color = .inkPrimaryDark) -> some View {
        self.modifier(AppTextStyle(style: style, color: color))
    }
}