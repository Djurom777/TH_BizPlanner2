//
//  PlannerView.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct PlannerView: View {
    @EnvironmentObject var plannerViewModel: PlannerViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    GradientHeader(
                        title: "Planner",
                        coinBalance: appViewModel.coinBalance
                    )
                    
                    // Content
                    ScrollView {
                        LazyVStack(spacing: Layout.spacing16) {
                            if plannerViewModel.projects.isEmpty {
                                EmptyProjectsView()
                            } else {
                                ForEach(plannerViewModel.projects, id: \.id) { project in
                                    ProjectCard(
                                        project: project,
                                        progress: plannerViewModel.projectProgress(project),
                                        taskCounts: plannerViewModel.projectTaskCounts(project)
                                    ) {
                                        plannerViewModel.selectedProject = project
                                        plannerViewModel.showingProjectDetails = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, Layout.spacing20)
                        .padding(.top, Layout.spacing16)
                        .padding(.bottom, 100) // Space for FAB
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button {
                            plannerViewModel.showingAddProject = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(Color.primary)
                                        .shadow(
                                            color: Layout.shadowLevel2.color,
                                            radius: Layout.shadowLevel2.blur,
                                            y: Layout.shadowLevel2.y
                                        )
                                )
                        }
                        .padding(.trailing, Layout.spacing20)
                        .padding(.bottom, Layout.spacing20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $plannerViewModel.showingAddProject) {
                AddProjectView()
                    .environmentObject(plannerViewModel)
            }
            .sheet(isPresented: $plannerViewModel.showingProjectDetails) {
                if let project = plannerViewModel.selectedProject {
                    ProjectDetailsView(project: project)
                        .environmentObject(plannerViewModel)
                }
            }
        }
        .onAppear {
            plannerViewModel.loadProjects()
        }
    }
}

struct EmptyProjectsView: View {
    var body: some View {
        VStack(spacing: Layout.spacing20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.border)
            
            VStack(spacing: Layout.spacing8) {
                Text("No Projects Yet")
                    .appStyle(.title, color: .inkPrimaryDark)
                
                Text("Create your first project to start planning and earning coins!")
                    .appStyle(.body, color: .inkPrimaryDark.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, Layout.spacing24)
        .padding(.top, Layout.spacing24)
    }
}

struct ProjectCard: View {
    let project: Project
    let progress: Double
    let taskCounts: (completed: Int, total: Int)
    let onTap: () -> Void
    
    private var isDeadlineApproaching: Bool {
        guard let deadline = project.deadline else { return false }
        let daysBetween = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        return daysBetween <= 3 && daysBetween >= 0
    }
    
    private var isDeadlineOverdue: Bool {
        guard let deadline = project.deadline else { return false }
        return deadline < Date()
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Layout.spacing16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: Layout.spacing4) {
                        Text(project.name ?? "Untitled Project")
                            .appStyle(.subtitle, color: .inkPrimaryDark)
                            .lineLimit(2)
                        
                        Text("\(taskCounts.completed)/\(taskCounts.total) tasks")
                            .appStyle(.caption, color: .inkPrimaryDark.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    ProgressRing(progress: progress, size: 50, lineWidth: 4)
                }
                
                // Deadline and Budget
                HStack {
                    if let deadline = project.deadline {
                        HStack(spacing: Layout.spacing4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundColor(
                                    isDeadlineOverdue ? .error :
                                    isDeadlineApproaching ? .warning : .inkPrimaryDark.opacity(0.7)
                                )
                            
                            Text(deadline, style: .date)
                                .appStyle(.caption, color: 
                                    isDeadlineOverdue ? .error :
                                    isDeadlineApproaching ? .warning : .inkPrimaryDark.opacity(0.7)
                                )
                        }
                        .padding(.horizontal, Layout.spacing8)
                        .padding(.vertical, Layout.spacing4)
                        .background(
                            Capsule()
                                .fill(
                                    (isDeadlineOverdue ? Color.error : 
                                     isDeadlineApproaching ? Color.warning : Color.border)
                                    .opacity(0.2)
                                )
                        )
                    }
                    
                    Spacer()
                    
                    if project.budget > 0 {
                        HStack(spacing: Layout.spacing4) {
                            Image(systemName: "dollarsign.circle")
                                .font(.caption)
                                .foregroundColor(.accentGold)
                            
                            Text("$\(Int(project.budget))")
                                .appStyle(.caption, color: .accentGold)
                        }
                        .padding(.horizontal, Layout.spacing8)
                        .padding(.vertical, Layout.spacing4)
                        .background(
                            Capsule()
                                .fill(Color.accentGold.opacity(0.2))
                        )
                    }
                }
            }
            .padding(Layout.spacing16)
            .glassCard()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PlannerView()
        .environmentObject(PlannerViewModel())
        .environmentObject(AppViewModel())
}