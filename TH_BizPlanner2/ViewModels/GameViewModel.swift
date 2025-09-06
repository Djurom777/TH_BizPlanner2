//
//  GameViewModel.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI
import Combine

// MARK: - Target Model
struct GameTarget: Identifiable {
    let id = UUID()
    var position: CGPoint
    var size: CGFloat
    var color: Color
    var scale: CGFloat = 1.0
    var opacity: Double = 1.0
    var appearTime: Date
}

class GameViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var activeTargets: [GameTarget] = []
    @Published var currentScore = 0
    @Published var lastScore = 0
    @Published var bestScore = 0
    @Published var showReward = false
    @Published var lastReward = 0
    @Published var gameTimeRemaining: Double = 30.0
    @Published var bestReactionTime: Double = 999.0
    @Published var showMissIndicator = false
    @Published var missIndicatorPosition = CGPoint.zero
    
    private let coreDataService = CoreDataService.shared
    private var gameTimer: Timer?
    private var targetSpawnTimer: Timer?
    private let gameDuration: Double = 30.0
    private let targetLifetime: Double = 2.0
    private let maxActiveTargets = 3
    private var gameAreaSize = CGSize(width: 300, height: 400)
    
    var appViewModel: AppViewModel?
    
    init() {
        loadBestScore()
    }
    
    // MARK: - Game Control
    func startGame() {
        guard !isPlaying else { return }
        
        isPlaying = true
        currentScore = 0
        gameTimeRemaining = gameDuration
        activeTargets.removeAll()
        showReward = false
        showMissIndicator = false
        
        startGameTimer()
        startTargetSpawning()
    }
    
    private func endGame() {
        isPlaying = false
        gameTimer?.invalidate()
        targetSpawnTimer?.invalidate()
        activeTargets.removeAll()
        
        lastScore = currentScore
        if currentScore > bestScore {
            bestScore = currentScore
            saveBestScore()
        }
        
        // Award stars based on performance
        let starsEarned = calculateStarsEarned()
        if starsEarned > 0 {
            lastReward = starsEarned
            appViewModel?.earnStars(Int32(starsEarned))
            
            // Create game session record
            _ = coreDataService.createGameSession(
                coinsSpent: 0, // Free to play
                coinsEarned: Int32(starsEarned)
            )
            
            showReward = true
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Hide reward after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.showReward = false
            }
        }
    }
    
    private func calculateStarsEarned() -> Int {
        let baseStars = currentScore / 5 // 1 star per 5 points
        let bonusStars = currentScore > bestScore ? 5 : 0 // Bonus for new high score
        return max(1, baseStars + bonusStars) // Minimum 1 star for playing
    }
    
    // MARK: - Game Timers
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.gameTimeRemaining -= 0.1
            
            if self.gameTimeRemaining <= 0 {
                self.endGame()
            }
        }
    }
    
    private func startTargetSpawning() {
        targetSpawnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.spawnTarget()
            self.removeExpiredTargets()
        }
        
        // Spawn first target immediately
        spawnTarget()
    }
    
    // MARK: - Game Area Management
    func updateGameArea(size: CGSize) {
        gameAreaSize = size
    }
    
    // MARK: - Target Management
    private func spawnTarget() {
        guard activeTargets.count < maxActiveTargets else { return }
        
        let sizes: [CGFloat] = [40, 50, 60]
        let targetSize = sizes.randomElement() ?? 50
        let padding: CGFloat = targetSize / 2 + 10 // Ensure targets don't spawn at edges
        
        let position = CGPoint(
            x: CGFloat.random(in: padding...(gameAreaSize.width - padding)),
            y: CGFloat.random(in: padding...(gameAreaSize.height - padding))
        )
        
        let colors: [Color] = [.accentGold, .success, .primary, .accentOrange]
        
        let target = GameTarget(
            position: position,
            size: targetSize,
            color: colors.randomElement() ?? .accentGold,
            appearTime: Date()
        )
        
        activeTargets.append(target)
        
        // Animate target appearance
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if let index = activeTargets.firstIndex(where: { $0.id == target.id }) {
                activeTargets[index].scale = 1.0
            }
        }
    }
    
    private func removeExpiredTargets() {
        let now = Date()
        activeTargets.removeAll { target in
            let elapsed = now.timeIntervalSince(target.appearTime)
            if elapsed > targetLifetime {
                // Show miss indicator
                showMissIndicator(at: target.position)
                return true
            }
            return false
        }
    }
    
    func targetTapped(_ target: GameTarget) {
        guard let index = activeTargets.firstIndex(where: { $0.id == target.id }) else { return }
        
        let reactionTime = Date().timeIntervalSince(target.appearTime)
        if reactionTime < bestReactionTime {
            bestReactionTime = reactionTime
        }
        
        // Calculate points based on reaction time and target size
        let speedBonus = max(1, Int((2.0 - reactionTime) * 10)) // Faster = more points
        let sizeBonus = target.size < 45 ? 2 : 1 // Smaller targets = more points
        let points = speedBonus * sizeBonus
        
        currentScore += points
        
        // Remove target with animation
        withAnimation(.easeOut(duration: 0.2)) {
            activeTargets[index].scale = 0.1
            activeTargets[index].opacity = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.activeTargets.removeAll { $0.id == target.id }
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func showMissIndicator(at position: CGPoint) {
        missIndicatorPosition = position
        showMissIndicator = true
        
        withAnimation(.easeOut(duration: 1.0)) {
            showMissIndicator = false
        }
    }
    
    // MARK: - Data Persistence
    private func loadBestScore() {
        bestScore = UserDefaults.standard.integer(forKey: "FocusGameBestScore")
        bestReactionTime = UserDefaults.standard.double(forKey: "FocusGameBestReactionTime")
        if bestReactionTime == 0 {
            bestReactionTime = 999.0
        }
    }
    
    private func saveBestScore() {
        UserDefaults.standard.set(bestScore, forKey: "FocusGameBestScore")
        UserDefaults.standard.set(bestReactionTime, forKey: "FocusGameBestReactionTime")
    }
}