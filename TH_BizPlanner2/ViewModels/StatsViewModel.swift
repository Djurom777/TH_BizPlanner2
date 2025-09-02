//
//  StatsViewModel.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI
import Combine

class StatsViewModel: ObservableObject {
    @Published var totalProjects = 0
    @Published var completedTasks = 0
    @Published var coinsEarned = 0
    @Published var currentStreak = 0
    @Published var tasksLast7Days: [Int] = []
    @Published var coinHistoryLast14Days: [Int] = []
    
    private let coreDataService = CoreDataService.shared
    
    init() {
        loadStats()
    }
    
    func loadStats() {
        // Load basic stats
        totalProjects = coreDataService.fetchProjects().count
        completedTasks = coreDataService.fetchCompletedTasksCount()
        
        // Load user-specific stats
        if let user = coreDataService.fetchUser() {
            coinsEarned = Int(user.coinBalance)
            currentStreak = Int(user.streakCount)
        }
        
        // Load chart data
        tasksLast7Days = coreDataService.fetchTasksCompletedInLast7Days()
        coinHistoryLast14Days = coreDataService.fetchCoinHistoryLast14Days()
    }
    
    func refreshStats() {
        loadStats()
    }
    
    // MARK: - Chart Data Helpers
    func chartDataForTasks() -> [(String, Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        return tasksLast7Days.enumerated().map { index, count in
            let date = calendar.date(byAdding: .day, value: index - 6, to: today) ?? today
            let formatter = DateFormatter()
            formatter.dateFormat = "E" // Short day name (Mon, Tue, etc.)
            return (formatter.string(from: date), count)
        }
    }
    
    func chartDataForCoins() -> [(String, Int)] {
        let calendar = Calendar.current
        let today = Date()
        
        return coinHistoryLast14Days.enumerated().map { index, balance in
            let date = calendar.date(byAdding: .day, value: index - 13, to: today) ?? today
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d" // Short date format
            return (formatter.string(from: date), balance)
        }
    }
    
    var maxTasksInWeek: Int {
        tasksLast7Days.max() ?? 1
    }
    
    var maxCoinsInHistory: Int {
        coinHistoryLast14Days.max() ?? 1
    }
    
    var averageTasksPerDay: Double {
        let sum = tasksLast7Days.reduce(0, +)
        return tasksLast7Days.isEmpty ? 0 : Double(sum) / Double(tasksLast7Days.count)
    }
    
    var totalCoinsFromTasks: Int {
        completedTasks * 10 // 10 coins per completed task
    }
}