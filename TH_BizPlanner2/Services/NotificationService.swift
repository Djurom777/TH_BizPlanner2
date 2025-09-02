//
//  NotificationService.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                UserDefaultsService.shared.notificationsEnabled = granted
            }
            
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleTaskDeadlineNotification(for task: Task) {
        guard let deadline = task.deadline,
              let taskName = task.name,
              let taskId = task.id?.uuidString,
              UserDefaultsService.shared.notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Deadline Reminder"
        content.body = "Don't forget to complete: \(taskName)"
        content.sound = .default
        content.badge = 1
        
        // Schedule notification 1 hour before deadline
        let notificationDate = Calendar.current.date(byAdding: .hour, value: -1, to: deadline)
        
        guard let triggerDate = notificationDate,
              triggerDate > Date() else { return }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task_deadline_\(taskId)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func cancelTaskDeadlineNotification(for task: Task) {
        guard let taskId = task.id?.uuidString else { return }
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["task_deadline_\(taskId)"]
        )
    }
    
    func scheduleDailyReminder() {
        guard UserDefaultsService.shared.notificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "PlinkoBiz Planner"
        content.body = "Time to check your tasks and make progress on your goals!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 9 // 9 AM daily reminder
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule daily reminder: \(error)")
            }
        }
    }
}