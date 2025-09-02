//
//  GameView.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                GradientHeader(
                    title: "Game",
                    coinBalance: appViewModel.coinBalance
                )
                
                // Game Content
                GeometryReader { geometry in
                    ZStack {
                        // Plinko Board
                        PlinkoBoard()
                        
                        // Ball
                        if gameViewModel.isPlaying {
                            Circle()
                                .fill(Color.accentGold)
                                .frame(width: 12, height: 12)
                                .position(gameViewModel.ballPosition)
                                .shadow(color: .accentGold.opacity(0.5), radius: 8)
                        }
                        
                        // Reward Banner
                        if gameViewModel.showReward {
                            RewardBanner(coins: gameViewModel.lastReward)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
                
                // Play Button
                VStack(spacing: Layout.spacing16) {
                    if !gameViewModel.canAffordGame {
                        Text("Need 20 coins to play")
                            .appStyle(.body, color: .warning)
                    }
                    
                    Button {
                        gameViewModel.playGame()
                    } label: {
                        HStack(spacing: Layout.spacing8) {
                            Image(systemName: "play.fill")
                            Text("Play (20 coins)")
                        }
                    }
                    .primaryButton(isEnabled: gameViewModel.canPlay && gameViewModel.canAffordGame)
                    .padding(.horizontal, Layout.spacing20)
                }
                .padding(.bottom, Layout.spacing24)
            }
        }
        .onAppear {
            gameViewModel.appViewModel = appViewModel
        }
    }
}

struct PlinkoBoard: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Pegs
            ForEach(Array(gameViewModel.generatePegs().enumerated()), id: \.offset) { index, peg in
                Circle()
                    .fill(Color.primaryVariant)
                    .frame(width: 8, height: 8)
                    .position(peg)
                    .shadow(color: Color.primaryVariant.opacity(0.5), radius: 4)
                    .scaleEffect(gameViewModel.isPlaying ? 1.1 : 1.0)
                    .animation(
                        AppAnimations.bounce.delay(Double(index) * 0.02),
                        value: gameViewModel.isPlaying
                    )
            }
            
            // Prize Slots at Bottom
            HStack(spacing: 0) {
                ForEach([5, 10, 25, 50, 100, 25, 10, 5], id: \.self) { prize in
                    VStack(spacing: Layout.spacing4) {
                        Text("\(prize)")
                            .appStyle(.caption, color: .accentGold)
                            .font(.system(size: 12, weight: .bold))
                        
                        Rectangle()
                            .fill(Color.accentGold.opacity(0.3))
                            .frame(height: 40)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.accentGold, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, Layout.spacing20)
            .offset(y: UIScreen.main.bounds.height * 0.35)
        }
    }
}

struct RewardBanner: View {
    let coins: Int
    
    var body: some View {
        ZStack {
            // Confetti
            ConfettiView()
            
            // Banner
            VStack(spacing: Layout.spacing12) {
                Image(systemName: "star.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.accentGold)
                    .pulsing()
                
                Text("You Won!")
                    .appStyle(.title, color: .inkPrimaryDark)
                
                HStack(spacing: Layout.spacing8) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.accentGold)
                        .font(.title2)
                    
                    Text("\(coins) Coins")
                        .appStyle(.subtitle, color: .accentGold)
                }
            }
            .padding(Layout.spacing24)
            .glassCard()
            .scaleEffect(1.1)
            .shadow(
                color: Layout.shadowLevel2.color,
                radius: Layout.shadowLevel2.blur,
                y: Layout.shadowLevel2.y
            )
        }
    }
}

#Preview {
    GameView()
        .environmentObject(GameViewModel())
        .environmentObject(AppViewModel())
}