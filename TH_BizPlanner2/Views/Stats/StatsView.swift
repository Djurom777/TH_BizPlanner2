//
//  StatsView.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var statsViewModel: StatsViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                GradientHeader(
                    title: "Stats",
                    starBalance: appViewModel.starBalance
                )
                
                // Content
                ScrollView {
                    LazyVStack(spacing: Layout.spacing20) {
                        // KPI Cards
                        KPICardsView()
                            .environmentObject(statsViewModel)
                        
                        // Charts Section
                        ChartsView()
                            .environmentObject(statsViewModel)
                    }
                    .padding(.horizontal, Layout.spacing20)
                    .padding(.top, Layout.spacing16)
                    .padding(.bottom, Layout.spacing20)
                }
            }
        }
        .onAppear {
            statsViewModel.loadStats()
        }
        .refreshable {
            statsViewModel.refreshStats()
        }
    }
}

struct KPICardsView: View {
    @EnvironmentObject var statsViewModel: StatsViewModel
    
    var body: some View {
        VStack(spacing: Layout.spacing16) {
            Text("Overview")
                .appStyle(.title, color: .inkPrimaryDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Layout.spacing12), count: 2), spacing: Layout.spacing12) {
                KPICard(
                    icon: "folder.fill",
                    title: "Projects",
                    value: "\(statsViewModel.totalProjects)",
                    color: .primary
                )
                
                KPICard(
                    icon: "checkmark.circle.fill",
                    title: "Tasks Done",
                    value: "\(statsViewModel.completedTasks)",
                    color: .success
                )
                
                KPICard(
                    icon: "star.fill",
                    title: "Stars Earned",
                    value: "\(statsViewModel.starsEarned)",
                    color: .accentGold
                )
                
                KPICard(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "\(statsViewModel.currentStreak) days",
                    color: .accentOrange
                )
            }
        }
    }
}

struct KPICard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Layout.spacing12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: Layout.spacing4) {
                Text(value)
                    .appStyle(.title, color: .inkPrimaryDark)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(title)
                    .appStyle(.body, color: .inkPrimaryDark.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(Layout.spacing16)
        .glassCard()
    }
}

struct ChartsView: View {
    @EnvironmentObject var statsViewModel: StatsViewModel
    
    var body: some View {
        VStack(spacing: Layout.spacing20) {
            // Tasks Chart
            VStack(alignment: .leading, spacing: Layout.spacing16) {
                Text("Tasks This Week")
                    .appStyle(.title, color: .inkPrimaryDark)
                
                TasksBarChart()
                    .environmentObject(statsViewModel)
            }
            .padding(Layout.spacing16)
            .glassCard()
            
            // Stars Chart
            VStack(alignment: .leading, spacing: Layout.spacing16) {
                Text("Star History (14 Days)")
                    .appStyle(.title, color: .inkPrimaryDark)
                
                StarsLineChart()
                    .environmentObject(statsViewModel)
            }
            .padding(Layout.spacing16)
            .glassCard()
        }
    }
}

struct TasksBarChart: View {
    @EnvironmentObject var statsViewModel: StatsViewModel
    
    var body: some View {
        VStack(spacing: Layout.spacing12) {
            HStack {
                Text("Daily Tasks Completed")
                    .appStyle(.body, color: .inkPrimaryDark.opacity(0.8))
                
                Spacer()
                
                Text("Avg: \(String(format: "%.1f", statsViewModel.averageTasksPerDay))")
                    .appStyle(.caption, color: .inkPrimaryDark.opacity(0.6))
            }
            
            HStack(alignment: .bottom, spacing: Layout.spacing8) {
                let chartData = statsViewModel.chartDataForTasks()
                let maxValue = max(1, statsViewModel.maxTasksInWeek)
                
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                    VStack(spacing: Layout.spacing4) {
                        // Bar
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.primary, Color.primaryVariant],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: CGFloat(data.1) / CGFloat(maxValue) * 80)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(4)
                        
                        // Day label
                        Text(data.0)
                            .appStyle(.caption, color: .inkPrimaryDark.opacity(0.7))
                            .font(.system(size: 10))
                    }
                }
            }
            .frame(height: 100)
        }
    }
}

struct StarsLineChart: View {
    @EnvironmentObject var statsViewModel: StatsViewModel
    
    var body: some View {
        VStack(spacing: Layout.spacing12) {
            HStack {
                Text("Star Balance Over Time")
                    .appStyle(.body, color: .inkPrimaryDark.opacity(0.8))
                
                Spacer()
                
                Text("Peak: \(statsViewModel.maxStarsInHistory)")
                    .appStyle(.caption, color: .inkPrimaryDark.opacity(0.6))
            }
            
            GeometryReader { geometry in
                let chartData = statsViewModel.chartDataForStars()
                let maxValue = max(1, statsViewModel.maxStarsInHistory)
                let width = geometry.size.width
                let height = geometry.size.height
                
                ZStack {
                    // Grid lines
                    ForEach(0..<5) { i in
                        let y = height * CGFloat(i) / 4
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                        .stroke(Color.border.opacity(0.3), lineWidth: 0.5)
                    }
                    
                    // Line chart
                    if chartData.count > 1 {
                        Path { path in
                            for (index, data) in chartData.enumerated() {
                                let x = width * CGFloat(index) / CGFloat(chartData.count - 1)
                                let y = height - (height * CGFloat(data.1) / CGFloat(maxValue))
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [Color.accentGold, Color.accentOrange],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                        
                        // Data points
                        ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                            let x = width * CGFloat(index) / CGFloat(chartData.count - 1)
                            let y = height - (height * CGFloat(data.1) / CGFloat(maxValue))
                            
                            Circle()
                                .fill(Color.accentGold)
                                .frame(width: 4, height: 4)
                                .position(x: x, y: y)
                        }
                    }
                }
            }
            .frame(height: 80)
            
            // X-axis labels
            HStack {
                let chartData = statsViewModel.chartDataForStars()
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                    if index % 3 == 0 || index == chartData.count - 1 {
                        Text(data.0)
                            .appStyle(.caption, color: .inkPrimaryDark.opacity(0.6))
                            .font(.system(size: 10))
                        if index != chartData.count - 1 {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    StatsView()
        .environmentObject(StatsViewModel())
        .environmentObject(AppViewModel())
}