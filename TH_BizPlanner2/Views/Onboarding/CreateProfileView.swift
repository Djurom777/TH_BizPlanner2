//
//  CreateProfileView.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct CreateProfileView: View {
    @State private var name = ""
    @State private var goal = ""
    @State private var avatarImage: UIImage?
    @State private var showingImagePicker = false
    
    let onProfileCreated: (User) -> Void
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: Layout.spacing24) {
                // Header
                VStack(spacing: Layout.spacing16) {
                    Text("Create Your Profile")
                        .appStyle(.display, color: .inkPrimaryDark)
                    
                    Text("Let's get to know you better")
                        .appStyle(.body, color: .inkPrimaryDark.opacity(0.8))
                }
                .padding(.top, Layout.spacing24)
                
                // Avatar section
                VStack(spacing: Layout.spacing16) {
                    ZStack {
                        Circle()
                            .fill(Color.surface)
                            .frame(width: 120, height: 120)
                            .overlay(
                                Circle()
                                    .stroke(Color.border, lineWidth: 2)
                            )
                        
                        if let avatarImage = avatarImage {
                            Image(uiImage: avatarImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.border)
                        }
                        
                        // Edit button
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button {
                                    showingImagePicker = true
                                } label: {
                                    Image(systemName: "camera.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.primary)
                                        .background(Color.white, in: Circle())
                                }
                                .offset(x: -8, y: -8)
                            }
                        }
                        .frame(width: 120, height: 120)
                    }
                    
                    Text("Add Photo (Optional)")
                        .appStyle(.caption, color: .inkPrimaryDark.opacity(0.6))
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
                
                // Create button
                Button("Create Profile") {
                    createProfile()
                }
                .primaryButton(isEnabled: isFormValid)
                .padding(.horizontal, Layout.spacing20)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(selectedImage: $avatarImage)
        }
    }
    
    private func createProfile() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedGoal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var avatarData: Data?
        if let avatarImage = avatarImage {
            avatarData = avatarImage.jpegData(compressionQuality: 0.8)
        }
        
        let user = CoreDataService.shared.createUser(
            name: trimmedName,
            goal: trimmedGoal.isEmpty ? nil : trimmedGoal,
            avatarData: avatarData
        )
        
        onProfileCreated(user)
    }
}

struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, Layout.spacing16)
            .padding(.vertical, Layout.spacing12)
            .background(
                RoundedRectangle(cornerRadius: Layout.cornerRadiusInput)
                    .fill(Color.surface.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: Layout.cornerRadiusInput)
                            .stroke(Color.border.opacity(0.8), lineWidth: 1.5)
                    )
            )
            .foregroundColor(.inkPrimaryDark)
            .font(.body)
    }
}

#Preview {
    CreateProfileView { _ in }
}