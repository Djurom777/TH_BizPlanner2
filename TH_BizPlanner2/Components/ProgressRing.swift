//
//  ProgressRing.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    
    init(progress: Double, size: CGFloat = 60, lineWidth: CGFloat = 6) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.border, lineWidth: lineWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [Color.primary, Color.primaryVariant, Color.accentGreen],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(AppAnimations.medium, value: progress)
            
            // Progress text
            Text("\(Int(progress * 100))%")
                .appStyle(.caption, color: .inkPrimaryDark)
                .font(.system(size: size * 0.2, weight: .semibold))
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color.appBackground
            .ignoresSafeArea()
        
        VStack(spacing: Layout.spacing20) {
            ProgressRing(progress: 0.0)
            ProgressRing(progress: 0.3)
            ProgressRing(progress: 0.7)
            ProgressRing(progress: 1.0)
        }
    }
}