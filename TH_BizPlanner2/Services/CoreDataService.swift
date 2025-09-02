//
//  CoreDataService.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import CoreData
import Foundation
import Combine

class CoreDataService: ObservableObject {
    static let shared = CoreDataService()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        save()
    }
    
    func deleteAll() {
        let entities = ["User", "Project", "Task", "GameSession"]
        
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Failed to delete \(entityName): \(error)")
            }
        }
        
        save()
    }
    
    // MARK: - User Methods
    func createUser(name: String, goal: String? = nil, avatarData: Data? = nil) -> User {
        let user = User(context: context)
        user.id = UUID()
        user.name = name
        user.goal = goal
        user.avatarData = avatarData
        user.coinBalance = 100 // Starting coins
        user.streakCount = 0
        user.createdAt = Date()
        save()
        return user
    }
    
    func fetchUser() -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
    
    func updateUserCoins(by amount: Int32) {
        guard let user = fetchUser() else { return }
        user.coinBalance += amount
        save()
    }
    
    func updateUserStreak() {
        guard let user = fetchUser() else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        if let lastDate = user.streakLastDate {
            if calendar.isDate(lastDate, inSameDayAs: today) {
                // Already counted today
                return
            } else if calendar.isDate(lastDate, equalTo: today, toGranularity: .day) ||
                      calendar.dateInterval(of: .day, for: lastDate)?.end == calendar.dateInterval(of: .day, for: today)?.start {
                // Consecutive day
                user.streakCount += 1
            } else {
                // Streak broken
                user.streakCount = 1
            }
        } else {
            // First task completion
            user.streakCount = 1
        }
        
        user.streakLastDate = today
        save()
    }
    
    // MARK: - Project Methods
    func createProject(name: String, deadline: Date? = nil, budget: Double = 0, notes: String? = nil) -> Project {
        guard let user = fetchUser() else {
            fatalError("No user found")
        }
        
        let project = Project(context: context)
        project.id = UUID()
        project.name = name
        project.deadline = deadline
        project.budget = budget
        project.notes = notes
        project.createdAt = Date()
        project.user = user
        save()
        return project
    }
    
    func fetchProjects() -> [Project] {
        let request: NSFetchRequest<Project> = Project.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.createdAt, ascending: false)]
        return (try? context.fetch(request)) ?? []
    }
    
    // MARK: - Task Methods
    func createTask(name: String, project: Project, deadline: Date? = nil, estimatedTime: Int32 = 0, notes: String? = nil) -> Task {
        let task = Task(context: context)
        task.id = UUID()
        task.name = name
        task.deadline = deadline
        task.estimatedTime = estimatedTime
        task.notes = notes
        task.isCompleted = false
        task.createdAt = Date()
        task.project = project
        save()
        return task
    }
    
    func toggleTaskCompletion(_ task: Task) {
        task.isCompleted.toggle()
        
        if task.isCompleted {
            task.completedAt = Date()
            // Award coins for task completion
            updateUserCoins(by: 10)
            updateUserStreak()
        } else {
            task.completedAt = nil
        }
        
        save()
    }
    
    func fetchCompletedTasksCount() -> Int {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.predicate = NSPredicate(format: "isCompleted == true")
        return (try? context.count(for: request)) ?? 0
    }
    
    func fetchTasksCompletedInLast7Days() -> [Int] {
        let calendar = Calendar.current
        let today = Date()
        var counts: [Int] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let request: NSFetchRequest<Task> = Task.fetchRequest()
            request.predicate = NSPredicate(
                format: "isCompleted == true AND completedAt >= %@ AND completedAt < %@",
                startOfDay as NSDate,
                endOfDay as NSDate
            )
            
            let count = (try? context.count(for: request)) ?? 0
            counts.append(count)
        }
        
        return counts.reversed()
    }
    
    // MARK: - Game Session Methods
    func createGameSession(coinsSpent: Int32, coinsEarned: Int32) -> GameSession {
        guard let user = fetchUser() else {
            fatalError("No user found")
        }
        
        let session = GameSession(context: context)
        session.id = UUID()
        session.coinsSpent = coinsSpent
        session.coinsEarned = coinsEarned
        session.createdAt = Date()
        session.user = user
        save()
        return session
    }
    
    func fetchCoinHistoryLast14Days() -> [Int] {
        let calendar = Calendar.current
        let today = Date()
        var balances: [Int] = []
        
        guard let user = fetchUser() else { return Array(repeating: 0, count: 14) }
        var runningBalance = Int(user.coinBalance)
        
        for i in 0..<14 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            // Get game sessions for this day
            let gameRequest: NSFetchRequest<GameSession> = GameSession.fetchRequest()
            gameRequest.predicate = NSPredicate(
                format: "createdAt >= %@ AND createdAt < %@",
                startOfDay as NSDate,
                endOfDay as NSDate
            )
            
            let gameSessions = (try? context.fetch(gameRequest)) ?? []
            let gameCoins = gameSessions.reduce(0) { $0 + Int($1.coinsEarned - $1.coinsSpent) }
            
            // Get completed tasks for this day
            let taskRequest: NSFetchRequest<Task> = Task.fetchRequest()
            taskRequest.predicate = NSPredicate(
                format: "isCompleted == true AND completedAt >= %@ AND completedAt < %@",
                startOfDay as NSDate,
                endOfDay as NSDate
            )
            
            let completedTasks = (try? context.count(for: taskRequest)) ?? 0
            let taskCoins = completedTasks * 10
            
            if i == 0 {
                balances.append(runningBalance)
            } else {
                runningBalance -= (gameCoins + taskCoins)
                balances.append(max(0, runningBalance))
            }
        }
        
        return balances.reversed()
    }
}