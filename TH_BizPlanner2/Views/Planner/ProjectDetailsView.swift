//
//  ProjectDetailsView.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct ProjectDetailsView: View {
    let project: Project
    @EnvironmentObject var plannerViewModel: PlannerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    ProjectHeaderView(
                        project: project,
                        progress: plannerViewModel.projectProgress(project)
                    )
                    
                    // Tab Selector
                    Picker("Tab", selection: $selectedTab) {
                        Text("Tasks").tag(0)
                        Text("Overview").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, Layout.spacing20)
                    .padding(.vertical, Layout.spacing12)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        TasksTabView(project: project)
                            .tag(0)
                        
                        OverviewTabView(project: project)
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Done") {
                    dismiss()
                }
                .foregroundColor(.primary),
                trailing: Menu {
                    Button("Delete Project", role: .destructive) {
                        plannerViewModel.deleteProject(project)
                        dismiss()
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.primary)
                }
            )
        }
        .sheet(isPresented: $plannerViewModel.showingAddTask) {
            AddTaskView(project: project)
                .environmentObject(plannerViewModel)
        }
    }
}

struct ProjectHeaderView: View {
    let project: Project
    let progress: Double
    
    var body: some View {
        VStack(spacing: Layout.spacing16) {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.primary.opacity(0.3),
                    Color.primaryVariant.opacity(0.2),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)
            
            // Content
            VStack(spacing: Layout.spacing12) {
                // Title and Progress
                HStack {
                    VStack(alignment: .leading, spacing: Layout.spacing8) {
                        Text(project.name ?? "Untitled Project")
                            .appStyle(.title, color: .inkPrimaryDark)
                            .lineLimit(2)
                        
                        if let deadline = project.deadline {
                            HStack(spacing: Layout.spacing4) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundColor(.inkPrimaryDark.opacity(0.7))
                                
                                Text("Due \(deadline, style: .date)")
                                    .appStyle(.caption, color: .inkPrimaryDark.opacity(0.7))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    ProgressRing(progress: progress, size: 80, lineWidth: 6)
                }
                
                // Budget
                if project.budget > 0 {
                    HStack {
                        HStack(spacing: Layout.spacing4) {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.accentGold)
                            
                            Text("Budget: $\(Int(project.budget))")
                                .appStyle(.body, color: .inkPrimaryDark)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, Layout.spacing20)
            .padding(.bottom, Layout.spacing16)
        }
    }
}

struct TasksTabView: View {
    let project: Project
    @EnvironmentObject var plannerViewModel: PlannerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Add Task Button
            HStack {
                Button {
                    plannerViewModel.selectedProject = project
                    plannerViewModel.showingAddTask = true
                } label: {
                    HStack(spacing: Layout.spacing8) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Task")
                    }
                    .foregroundColor(.primary)
                    .font(.subtitle)
                }
                
                Spacer()
            }
            .padding(.horizontal, Layout.spacing20)
            .padding(.vertical, Layout.spacing12)
            
            // Tasks List
            ScrollView {
                LazyVStack(spacing: Layout.spacing12) {
                    let tasks = plannerViewModel.sortedTasks(for: project)
                    
                    if tasks.isEmpty {
                        EmptyTasksView()
                    } else {
                        ForEach(tasks, id: \.id) { task in
                            TaskRowView(task: task)
                                .environmentObject(plannerViewModel)
                        }
                    }
                }
                .padding(.horizontal, Layout.spacing20)
                .padding(.bottom, Layout.spacing20)
            }
        }
    }
}

struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: Layout.spacing16) {
            Image(systemName: "checkmark.circle.badge.xmark")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(.border)
            
            VStack(spacing: Layout.spacing8) {
                Text("No Tasks Yet")
                    .appStyle(.subtitle, color: .inkPrimaryDark)
                
                Text("Add your first task to get started!")
                    .appStyle(.body, color: .inkPrimaryDark.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, Layout.spacing24)
    }
}

struct TaskRowView: View {
    let task: Task
    @EnvironmentObject var plannerViewModel: PlannerViewModel
    
    var body: some View {
        HStack(spacing: Layout.spacing12) {
            // Checkbox
            Button {
                plannerViewModel.toggleTaskCompletion(task)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? .success : .border)
            }
            
            // Task Content
            VStack(alignment: .leading, spacing: Layout.spacing4) {
                Text(task.name ?? "Untitled Task")
                    .appStyle(.body, color: task.isCompleted ? .inkPrimaryDark.opacity(0.6) : .inkPrimaryDark)
                
                if let notes = task.notes, !notes.isEmpty {
                    Text(notes)
                        .appStyle(.caption, color: .inkPrimaryDark.opacity(0.7))
                        .lineLimit(2)
                }
                
                // Task metadata
                HStack(spacing: Layout.spacing12) {
                    if let deadline = task.deadline {
                        HStack(spacing: Layout.spacing4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                                .foregroundColor(
                                    plannerViewModel.isDeadlineOverdue(deadline) ? .error :
                                    plannerViewModel.isDeadlineApproaching(deadline) ? .warning : .inkPrimaryDark.opacity(0.6)
                                )
                            
                            Text(deadline, style: .date)
                                .appStyle(.caption, color: 
                                    plannerViewModel.isDeadlineOverdue(deadline) ? .error :
                                    plannerViewModel.isDeadlineApproaching(deadline) ? .warning : .inkPrimaryDark.opacity(0.6)
                                )
                        }
                    }
                    
                    if task.estimatedTime > 0 {
                        HStack(spacing: Layout.spacing4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundColor(.inkPrimaryDark.opacity(0.6))
                            
                            Text("\(task.estimatedTime)h")
                                .appStyle(.caption, color: .inkPrimaryDark.opacity(0.6))
                        }
                    }
                }
            }
            
            Spacer()
            
            // Delete button
            Button {
                plannerViewModel.deleteTask(task)
            } label: {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundColor(.error)
            }
        }
        .padding(Layout.spacing12)
        .glassCard()
    }
}

struct OverviewTabView: View {
    let project: Project
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Layout.spacing20) {
                if let notes = project.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: Layout.spacing8) {
                        Text("Notes")
                            .appStyle(.subtitle, color: .inkPrimaryDark)
                        
                        Text(notes)
                            .appStyle(.body, color: .inkPrimaryDark.opacity(0.8))
                            .lineLimit(nil)
                    }
                    .padding(Layout.spacing16)
                    .glassCard()
                }
                
                // Project Stats
                VStack(alignment: .leading, spacing: Layout.spacing12) {
                    Text("Project Stats")
                        .appStyle(.subtitle, color: .inkPrimaryDark)
                    
                    VStack(spacing: Layout.spacing8) {
                        StatRow(
                            icon: "calendar.badge.plus",
                            title: "Created",
                            value: project.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown"
                        )
                        
                        if let deadline = project.deadline {
                            StatRow(
                                icon: "calendar.badge.exclamationmark",
                                title: "Deadline",
                                value: deadline.formatted(date: .abbreviated, time: .omitted)
                            )
                        }
                        
                        if project.budget > 0 {
                            StatRow(
                                icon: "dollarsign.circle",
                                title: "Budget",
                                value: "$\(Int(project.budget))"
                            )
                        }
                    }
                }
                .padding(Layout.spacing16)
                .glassCard()
            }
            .padding(.horizontal, Layout.spacing20)
            .padding(.bottom, Layout.spacing20)
        }
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.primary)
                .frame(width: 20)
            
            Text(title)
                .appStyle(.body, color: .inkPrimaryDark)
            
            Spacer()
            
            Text(value)
                .appStyle(.body, color: .inkPrimaryDark.opacity(0.7))
        }
    }
}

#Preview {
    let project = Project()
    project.name = "Sample Project"
    project.deadline = Date().addingTimeInterval(7 * 24 * 60 * 60)
    project.budget = 1000
    project.notes = "This is a sample project with some notes."
    
    return ProjectDetailsView(project: project)
        .environmentObject(PlannerViewModel())
}