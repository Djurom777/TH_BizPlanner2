//
//  AddTaskView.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct AddTaskView: View {
    let project: Project
    @EnvironmentObject var plannerViewModel: PlannerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var notes = ""
    @State private var estimatedTime = ""
    @State private var hasDeadline = false
    @State private var deadline = Date().addingTimeInterval(24 * 60 * 60) // 1 day from now
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Layout.spacing20) {
                        // Header
                        VStack(spacing: Layout.spacing8) {
                            Text("New Task")
                                .appStyle(.title, color: .inkPrimaryDark)
                            
                            Text("for \(project.name ?? "Project")")
                                .appStyle(.body, color: .inkPrimaryDark.opacity(0.7))
                        }
                        .padding(.top, Layout.spacing16)
                        
                        // Form
                        VStack(spacing: Layout.spacing20) {
                            // Task Name
                            VStack(alignment: .leading, spacing: Layout.spacing8) {
                                Text("Task Name")
                                    .appStyle(.subtitle, color: .inkPrimaryDark)
                                
                                TextField("Enter task name", text: $name)
                                    .textFieldStyle(AppTextFieldStyle())
                            }
                            
                            // Notes
                            VStack(alignment: .leading, spacing: Layout.spacing8) {
                                Text("Notes (Optional)")
                                    .appStyle(.subtitle, color: .inkPrimaryDark)
                                
                                TextField("Task description or notes", text: $notes)
                                    .textFieldStyle(AppTextFieldStyle())
                                    .lineLimit(2)
                            }
                            
                            // Estimated Time
                            VStack(alignment: .leading, spacing: Layout.spacing8) {
                                Text("Estimated Hours (Optional)")
                                    .appStyle(.subtitle, color: .inkPrimaryDark)
                                
                                TextField("0", text: $estimatedTime)
                                    .textFieldStyle(AppTextFieldStyle())
                                    .keyboardType(.numberPad)
                            }
                            
                            // Deadline Toggle
                            VStack(alignment: .leading, spacing: Layout.spacing12) {
                                Toggle("Set Deadline", isOn: $hasDeadline)
                                    .foregroundColor(.inkPrimaryDark)
                                    .font(.subtitle)
                                
                                if hasDeadline {
                                    DatePicker(
                                        "Deadline",
                                        selection: $deadline,
                                        in: Date()...,
                                        displayedComponents: [.date, .hourAndMinute]
                                    )
                                    .datePickerStyle(.compact)
                                    .foregroundColor(.inkPrimaryDark)
                                }
                            }
                        }
                        .padding(.horizontal, Layout.spacing20)
                        
                        Spacer(minLength: Layout.spacing24)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.primary),
                trailing: Button("Create") {
                    createTask()
                }
                .foregroundColor(isFormValid ? .primary : .border)
                .disabled(!isFormValid)
            )
        }
    }
    
    private func createTask() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let timeValue = Int32(estimatedTime) ?? 0
        
        plannerViewModel.createTask(
            name: trimmedName,
            deadline: hasDeadline ? deadline : nil,
            estimatedTime: timeValue,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes
        )
        
        dismiss()
    }
}

#Preview {
    let project = Project()
    project.name = "Sample Project"
    
    return AddTaskView(project: project)
        .environmentObject(PlannerViewModel())
}