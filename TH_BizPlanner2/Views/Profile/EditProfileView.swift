//
//  EditProfileView.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var goal = ""
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Layout.spacing24) {
                        // Header
                        Text("Edit Profile")
                            .appStyle(.title, color: .inkPrimaryDark)
                            .padding(.top, Layout.spacing16)
                        
                        // Profile icon
                        VStack(spacing: Layout.spacing16) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.accentGold)
                        }
                        
                        // Form fields
                        VStack(spacing: Layout.spacing20) {
                            VStack(alignment: .leading, spacing: Layout.spacing8) {
                                Text("Name")
                                    .appStyle(.subtitle, color: .inkPrimaryDark)
                                
                                TextField("Enter your name", text: $name)
                                    .textFieldStyle(AppTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: Layout.spacing8) {
                                Text("Goal (Optional)")
                                    .appStyle(.subtitle, color: .inkPrimaryDark)
                                
                                TextField("What's your main goal?", text: $goal)
                                    .textFieldStyle(AppTextFieldStyle())
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
                trailing: Button("Save") {
                    saveProfile()
                }
                .foregroundColor(isFormValid ? .primary : .border)
                .disabled(!isFormValid)
            )
        }
        .onAppear {
            loadCurrentProfile()
        }
    }
    
    private func loadCurrentProfile() {
        guard let user = appViewModel.currentUser else { return }
        
        name = user.name ?? ""
        goal = user.goal ?? ""
    }
    
    private func saveProfile() {
        guard let user = appViewModel.currentUser else { return }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedGoal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        
        user.name = trimmedName
        user.goal = trimmedGoal.isEmpty ? nil : trimmedGoal
        
        CoreDataService.shared.save()
        appViewModel.currentUser = user
        
        dismiss()
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AppViewModel())
}