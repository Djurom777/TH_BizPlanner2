//
//  StarChip.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct StarChip: View {
    let balance: Int32
    
    var body: some View {
        HStack(spacing: Layout.spacing8) {
            Image(systemName: "star.fill")
                .foregroundColor(.accentGold)
                .font(.body)
            
            Text("\(balance)")
                .appStyle(.body, color: .inkPrimaryDark)
        }
        .padding(.horizontal, Layout.spacing12)
        .padding(.vertical, Layout.spacing8)
        .background(
            Capsule()
                .fill(Color.surface.opacity(0.8))
                .overlay(
                    Capsule()
                        .stroke(Color.accentGold.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(
            color: Layout.shadowLevel1.color,
            radius: Layout.shadowLevel1.blur / 2,
            y: Layout.shadowLevel1.y / 2
        )
    }
}

#Preview {
    ZStack {
        Color.appBackground
            .ignoresSafeArea()
        
        StarChip(balance: 150)
    }
}