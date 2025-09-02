//
//  AppViewModel.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var coinBalance: Int32 = 0
    @Published var showOnboarding = false
    
    private let coreDataService = CoreDataService.shared
    private let userDefaultsService = UserDefaultsService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        loadInitialData()
    }
    
    private func setupBindings() {
        userDefaultsService.$hasOnboarded
            .map { !$0 }
            .assign(to: \.showOnboarding, on: self)
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        currentUser = coreDataService.fetchUser()
        updateCoinBalance()
        
        if currentUser == nil && userDefaultsService.hasOnboarded {
            // Data was deleted but onboarding flag still exists
            resetToOnboarding()
        }
    }
    
    func updateCoinBalance() {
        coinBalance = currentUser?.coinBalance ?? 0
    }
    
    func completeOnboarding(with user: User) {
        currentUser = user
        updateCoinBalance()
        userDefaultsService.hasOnboarded = true
        
        // Schedule daily reminder
        NotificationService.shared.scheduleDailyReminder()
    }
    
    func deleteAllDataAndResetToOnboarding() {
        // Delete all Core Data
        coreDataService.deleteAll()
        
        // Reset UserDefaults
        userDefaultsService.resetAllData()
        
        // Reset local state
        currentUser = nil
        coinBalance = 0
        
        // This will trigger showOnboarding = true due to the binding
    }
    
    private func resetToOnboarding() {
        userDefaultsService.hasOnboarded = false
        currentUser = nil
        coinBalance = 0
    }
    
    func spendCoins(_ amount: Int32) -> Bool {
        guard coinBalance >= amount else { return false }
        
        coreDataService.updateUserCoins(by: -amount)
        currentUser = coreDataService.fetchUser()
        updateCoinBalance()
        return true
    }
    
    func earnCoins(_ amount: Int32) {
        coreDataService.updateUserCoins(by: amount)
        currentUser = coreDataService.fetchUser()
        updateCoinBalance()
    }
}