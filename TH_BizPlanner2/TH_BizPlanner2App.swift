//
//  TH_BizPlanner2App.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

@main
struct TH_BizPlanner2App: App {
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appViewModel.showOnboarding {
                    OnboardingView()
                        .environmentObject(appViewModel)
                } else {
                    MainTabView()
                        .environmentObject(appViewModel)
                }
            }
            .onAppear {
                // Request notification permission on first launch
                NotificationService.shared.requestPermission()
            }
        }
    }
}
