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
                    title: "Focus Game",
                    starBalance: appViewModel.starBalance
                )
                
                // Game Content
                ScrollView {
                    VStack(spacing: Layout.spacing24) {
                        // Game Description
                        VStack(spacing: Layout.spacing12) {
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 50))
                                .foregroundColor(.accentGold)
                            
                            Text("Focus Challenge")
                                .appStyle(.title, color: .inkPrimaryDark)
                            
                            Text("Test your concentration! Tap the target circles as they appear. The faster you react, the more stars you earn!")
                                .appStyle(.body, color: .inkPrimaryDark.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(Layout.spacing20)
                        .glassCard()
                        
                        // Game Area
                        if gameViewModel.isPlaying {
                            FocusGameBoard()
                                .environmentObject(gameViewModel)
                        } else {
                            // Game Stats
                            VStack(spacing: Layout.spacing16) {
                                HStack(spacing: Layout.spacing20) {
                                    StatCard(
                                        icon: "target",
                                        title: "Best Score",
                                        value: "\(gameViewModel.bestScore)",
                                        color: .success
                                    )
                                    
                                    StatCard(
                                        icon: "timer",
                                        title: "Best Time",
                                        value: String(format: "%.1fs", gameViewModel.bestReactionTime),
                                        color: .primary
                                    )
                                }
                                
                                if gameViewModel.lastScore > 0 {
                                    Text("Last game: \(gameViewModel.lastScore) stars earned!")
                                        .appStyle(.body, color: .success)
                                }
                            }
                            .padding(Layout.spacing20)
                            .glassCard()
                        }
                        
                        // Reward Banner
                        if gameViewModel.showReward {
                            RewardBanner(stars: gameViewModel.lastReward)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, Layout.spacing20)
                    .padding(.top, Layout.spacing16)
                }
                
                // Play Button
                VStack(spacing: Layout.spacing16) {
                    if gameViewModel.isPlaying {
                        VStack(spacing: Layout.spacing8) {
                            Text("Score: \(gameViewModel.currentScore)")
                                .appStyle(.title, color: .accentGold)
                            
                            Text("Time: \(String(format: "%.1f", gameViewModel.gameTimeRemaining))s")
                                .appStyle(.body, color: .inkPrimaryDark.opacity(0.7))
                        }
                    } else {
                        Button {
                            gameViewModel.startGame()
                        } label: {
                            HStack(spacing: Layout.spacing8) {
                                Image(systemName: "play.fill")
                                Text("Start Focus Challenge")
                            }
                        }
                        .primaryButton(isEnabled: !gameViewModel.isPlaying)
                    }
                }
                .padding(.horizontal, Layout.spacing20)
                .padding(.bottom, Layout.spacing24)
            }
        }
        .onAppear {
            gameViewModel.appViewModel = appViewModel
        }
    }
}

struct FocusGameBoard: View {
    @EnvironmentObject var gameViewModel: GameViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: Layout.cornerRadiusCard)
                    .fill(Color.surface.opacity(0.3))
                    .frame(width: geometry.size.width, height: 400)
                
                // Targets
                ForEach(gameViewModel.activeTargets) { target in
                    Circle()
                        .fill(target.color)
                        .frame(width: target.size, height: target.size)
                        .position(target.position)
                        .scaleEffect(target.scale)
                        .opacity(target.opacity)
                        .onTapGesture {
                            gameViewModel.targetTapped(target)
                        }
                        .animation(.easeInOut(duration: 0.3), value: target.scale)
                }
                
                // Miss indicator
                if gameViewModel.showMissIndicator {
                    Text("Missed!")
                        .appStyle(.subtitle, color: .error)
                        .position(gameViewModel.missIndicatorPosition)
                        .transition(.opacity)
                }
            }
            .clipped() // Ensure targets don't go outside bounds
            .onAppear {
                gameViewModel.updateGameArea(size: geometry.size)
            }
            .onChange(of: geometry.size) { newSize in
                gameViewModel.updateGameArea(size: newSize)
            }
        }
        .frame(height: 400)
        .padding(Layout.spacing20)
        .glassCard()
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Layout.spacing8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .appStyle(.subtitle, color: .inkPrimaryDark)
            
            Text(title)
                .appStyle(.caption, color: .inkPrimaryDark.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(Layout.spacing16)
        .glassCard()
    }
}

struct RewardBanner: View {
    let stars: Int
    
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
                
                Text("Great Focus!")
                    .appStyle(.title, color: .inkPrimaryDark)
                
                HStack(spacing: Layout.spacing8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.accentGold)
                        .font(.title2)
                    
                    Text("\(stars) Stars Earned")
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