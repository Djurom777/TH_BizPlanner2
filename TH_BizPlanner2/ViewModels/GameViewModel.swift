//
//  GameViewModel.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var ballPosition = CGPoint.zero
    @Published var showReward = false
    @Published var lastReward = 0
    @Published var canPlay = true
    
    private let coreDataService = CoreDataService.shared
    private let gameCost: Int32 = 20
    private let possibleRewards = [5, 10, 15, 20, 25, 30, 50, 100]
    
    var appViewModel: AppViewModel?
    
    func playGame() {
        guard canPlay,
              let appViewModel = appViewModel,
              appViewModel.spendCoins(gameCost) else { return }
        
        isPlaying = true
        canPlay = false
        
        // Simulate ball drop animation
        withAnimation(.easeIn(duration: 0.5)) {
            ballPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: 100)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(AppAnimations.gravity) {
                self.ballPosition = CGPoint(
                    x: CGFloat.random(in: 50...(UIScreen.main.bounds.width - 50)),
                    y: UIScreen.main.bounds.height - 200
                )
            }
        }
        
        // Show reward after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            self.displayReward()
        }
    }
    
    private func displayReward() {
        let reward = possibleRewards.randomElement() ?? 10
        lastReward = reward
        
        // Award coins
        appViewModel?.earnCoins(Int32(reward))
        
        // Create game session record
        _ = coreDataService.createGameSession(
            coinsSpent: gameCost,
            coinsEarned: Int32(reward)
        )
        
        showReward = true
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Reset after showing reward
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.resetGame()
        }
    }
    
    private func resetGame() {
        isPlaying = false
        showReward = false
        ballPosition = CGPoint.zero
        canPlay = true
    }
    
    func generatePegs() -> [CGPoint] {
        var pegs: [CGPoint] = []
        let screenWidth = UIScreen.main.bounds.width
        let pegSpacing: CGFloat = 40
        let rowSpacing: CGFloat = 60
        let startY: CGFloat = 200
        
        for row in 0..<8 {
            let y = startY + CGFloat(row) * rowSpacing
            let isEvenRow = row % 2 == 0
            let pegCount = isEvenRow ? 8 : 7
            let totalWidth = CGFloat(pegCount - 1) * pegSpacing
            let startX = (screenWidth - totalWidth) / 2
            
            for col in 0..<pegCount {
                let x = startX + CGFloat(col) * pegSpacing
                pegs.append(CGPoint(x: x, y: y))
            }
        }
        
        return pegs
    }
    
    var canAffordGame: Bool {
        guard let appViewModel = appViewModel else { return false }
        return appViewModel.coinBalance >= gameCost
    }
}