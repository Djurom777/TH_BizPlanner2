//
//  MainTabView.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var plannerViewModel = PlannerViewModel()
    @StateObject private var gameViewModel = GameViewModel()
    @StateObject private var statsViewModel = StatsViewModel()
    
    var body: some View {
        TabView {
            PlannerView()
                .environmentObject(plannerViewModel)
                .tabItem {
                    Image(systemName: "list.clipboard")
                    Text("Planner")
                }
                .tag(0)
            
            GameView()
                .environmentObject(gameViewModel)
                .tabItem {
                    Image(systemName: "gamecontroller")
                    Text("Game")
                }
                .tag(1)
            
            StatsView()
                .environmentObject(statsViewModel)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.primary)
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear {
            setupTabBarAppearance()
            gameViewModel.appViewModel = appViewModel
        }
        .onChange(of: appViewModel.starBalance) { _ in
            // Refresh stats when star balance changes
            statsViewModel.refreshStats()
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(Color.surface.opacity(0.95))
        
        // Configure normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.border)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.border)
        ]
        
        // Configure selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.primary)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.primary)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppViewModel())
}