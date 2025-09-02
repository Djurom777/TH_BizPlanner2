//
//  GradientHeader.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct GradientHeader: View {
    let title: String
    let coinBalance: Int32
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.primary.opacity(0.3),
                    Color.primaryVariant.opacity(0.2),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            
            HStack {
                Text(title)
                    .appStyle(.title, color: .inkPrimaryDark)
                
                Spacer()
                
                CoinChip(balance: coinBalance)
            }
            .padding(.horizontal, Layout.spacing20)
            .padding(.top, Layout.spacing16)
        }
    }
}

#Preview {
    ZStack {
        Color.appBackground
            .ignoresSafeArea()
        
        VStack {
            GradientHeader(title: "Planner", coinBalance: 150)
            Spacer()
        }
    }
}