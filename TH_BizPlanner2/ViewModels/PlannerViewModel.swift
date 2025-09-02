//
//  PlannerViewModel.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI
import Combine

class PlannerViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var selectedProject: Project?
    @Published var showingAddProject = false
    @Published var showingAddTask = false
    @Published var showingProjectDetails = false
    
    private let coreDataService = CoreDataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadProjects()
    }
    
    func loadProjects() {
        projects = coreDataService.fetchProjects()
    }
    
    func createProject(name: String, deadline: Date?, budget: Double, notes: String?) {
        _ = coreDataService.createProject(
            name: name,
            deadline: deadline,
            budget: budget,
            notes: notes
        )
        loadProjects()
    }
    
    func deleteProject(_ project: Project) {
        coreDataService.delete(project)
        loadProjects()
    }
    
    func createTask(name: String, deadline: Date?, estimatedTime: Int32, notes: String?) {
        guard let project = selectedProject else { return }
        
        let task = coreDataService.createTask(
            name: name,
            project: project,
            deadline: deadline,
            estimatedTime: estimatedTime,
            notes: notes
        )
        
        // Schedule notification if deadline is set
        if deadline != nil {
            NotificationService.shared.scheduleTaskDeadlineNotification(for: task)
        }
        
        loadProjects()
    }
    
    func toggleTaskCompletion(_ task: Task) {
        // Cancel notification if task is being completed
        if !task.isCompleted {
            NotificationService.shared.cancelTaskDeadlineNotification(for: task)
        }
        
        coreDataService.toggleTaskCompletion(task)
        loadProjects()
    }
    
    func deleteTask(_ task: Task) {
        NotificationService.shared.cancelTaskDeadlineNotification(for: task)
        coreDataService.delete(task)
        loadProjects()
    }
    
    func projectProgress(_ project: Project) -> Double {
        guard let tasks = project.tasks?.allObjects as? [Task],
              !tasks.isEmpty else { return 0.0 }
        
        let completedTasks = tasks.filter { $0.isCompleted }.count
        return Double(completedTasks) / Double(tasks.count)
    }
    
    func projectTaskCounts(_ project: Project) -> (completed: Int, total: Int) {
        guard let tasks = project.tasks?.allObjects as? [Task] else { return (0, 0) }
        let completed = tasks.filter { $0.isCompleted }.count
        return (completed, tasks.count)
    }
    
    func sortedTasks(for project: Project) -> [Task] {
        guard let tasks = project.tasks?.allObjects as? [Task] else { return [] }
        
        return tasks.sorted { task1, task2 in
            // Incomplete tasks first
            if task1.isCompleted != task2.isCompleted {
                return !task1.isCompleted
            }
            
            // Then by deadline (closest first)
            if let deadline1 = task1.deadline, let deadline2 = task2.deadline {
                return deadline1 < deadline2
            } else if task1.deadline != nil {
                return true
            } else if task2.deadline != nil {
                return false
            }
            
            // Finally by creation date
            return (task1.createdAt ?? Date.distantPast) > (task2.createdAt ?? Date.distantPast)
        }
    }
    
    func isDeadlineApproaching(_ deadline: Date?) -> Bool {
        guard let deadline = deadline else { return false }
        let daysBetween = Calendar.current.dateComponents([.day], from: Date(), to: deadline).day ?? 0
        return daysBetween <= 3 && daysBetween >= 0
    }
    
    func isDeadlineOverdue(_ deadline: Date?) -> Bool {
        guard let deadline = deadline else { return false }
        return deadline < Date()
    }
}