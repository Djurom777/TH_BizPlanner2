//
//  AddProjectView.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct AddProjectView: View {
    @EnvironmentObject var plannerViewModel: PlannerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var notes = ""
    @State private var budget = ""
    @State private var hasDeadline = false
    @State private var deadline = Date().addingTimeInterval(7 * 24 * 60 * 60) // 7 days from now
    
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
                        Text("New Project")
                            .appStyle(.title, color: .inkPrimaryDark)
                            .padding(.top, Layout.spacing16)
                        
                        // Form
                        VStack(spacing: Layout.spacing20) {
                            // Project Name
                            VStack(alignment: .leading, spacing: Layout.spacing8) {
                                Text("Project Name")
                                    .appStyle(.subtitle, color: .inkPrimaryDark)
                                
                                TextField("Enter project name", text: $name)
                                    .textFieldStyle(AppTextFieldStyle())
                            }
                            
                            // Notes
                            VStack(alignment: .leading, spacing: Layout.spacing8) {
                                Text("Notes (Optional)")
                                    .appStyle(.subtitle, color: .inkPrimaryDark)
                                
                                TextField("Project description or notes", text: $notes)
                                    .textFieldStyle(AppTextFieldStyle())
                                    .lineLimit(3)
                            }
                            
                            // Budget
                            VStack(alignment: .leading, spacing: Layout.spacing8) {
                                Text("Budget (Optional)")
                                    .appStyle(.subtitle, color: .inkPrimaryDark)
                                
                                TextField("0", text: $budget)
                                    .textFieldStyle(AppTextFieldStyle())
                                    .keyboardType(.decimalPad)
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
                                        displayedComponents: [.date]
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
                    createProject()
                }
                .foregroundColor(isFormValid ? .primary : .border)
                .disabled(!isFormValid)
            )
        }
    }
    
    private func createProject() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let budgetValue = Double(budget) ?? 0
        
        plannerViewModel.createProject(
            name: trimmedName,
            deadline: hasDeadline ? deadline : nil,
            budget: budgetValue,
            notes: trimmedNotes.isEmpty ? nil : trimmedNotes
        )
        
        dismiss()
    }
}

#Preview {
    AddProjectView()
        .environmentObject(PlannerViewModel())
}