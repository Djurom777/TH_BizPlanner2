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
    @State private var avatarImage: UIImage?
    @State private var showingImagePicker = false
    @State private var hasChangedImage = false
    
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
                            
                            Button("Remove Photo") {
                                avatarImage = nil
                                hasChangedImage = true
                            }
                            .foregroundColor(.error)
                            .font(.caption)
                            .opacity(avatarImage != nil ? 1.0 : 0.0)
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
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(selectedImage: $avatarImage)
                .onDisappear {
                    hasChangedImage = true
                }
        }
        .onAppear {
            loadCurrentProfile()
        }
    }
    
    private func loadCurrentProfile() {
        guard let user = appViewModel.currentUser else { return }
        
        name = user.name ?? ""
        goal = user.goal ?? ""
        
        if let avatarData = user.avatarData,
           let uiImage = UIImage(data: avatarData) {
            avatarImage = uiImage
        }
    }
    
    private func saveProfile() {
        guard let user = appViewModel.currentUser else { return }
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedGoal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        
        user.name = trimmedName
        user.goal = trimmedGoal.isEmpty ? nil : trimmedGoal
        
        if hasChangedImage {
            if let avatarImage = avatarImage {
                user.avatarData = avatarImage.jpegData(compressionQuality: 0.8)
            } else {
                user.avatarData = nil
            }
        }
        
        CoreDataService.shared.save()
        appViewModel.currentUser = user
        
        dismiss()
    }
}

#Preview {
    EditProfileView()
        .environmentObject(AppViewModel())
}