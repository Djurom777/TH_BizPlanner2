//
//  UserDefaultsService.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import Foundation

class UserDefaultsService: ObservableObject {
    static let shared = UserDefaultsService()
    
    private init() {}
    
    // MARK: - Keys
    private enum Keys {
        static let hasOnboarded = "hasOnboarded"
        static let notificationsEnabled = "notificationsEnabled"
    }
    
    // MARK: - Properties
    @Published var hasOnboarded: Bool = UserDefaults.standard.bool(forKey: Keys.hasOnboarded) {
        didSet {
            UserDefaults.standard.set(hasOnboarded, forKey: Keys.hasOnboarded)
        }
    }
    
    @Published var notificationsEnabled: Bool = UserDefaults.standard.bool(forKey: Keys.notificationsEnabled) {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
        }
    }
    
    // MARK: - Methods
    func resetAllData() {
        hasOnboarded = false
        notificationsEnabled = false
        
        // Remove all UserDefaults keys
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}