//
//  ProfileView.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showingEditProfile = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                GradientHeader(
                    title: "Profile",
                    coinBalance: appViewModel.coinBalance
                )
                
                // Content
                ScrollView {
                    VStack(spacing: Layout.spacing24) {
                        // Profile Card
                        ProfileCard()
                            .environmentObject(appViewModel)
                        
                        // Actions
                        VStack(spacing: Layout.spacing16) {
                            Button("Edit Profile") {
                                showingEditProfile = true
                            }
                            .secondaryButton()
                            
                            Button("Delete Profile & All Data") {
                                showingDeleteAlert = true
                            }
                            .foregroundColor(.error)
                            .font(.subtitle)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: Layout.cornerRadiusButton)
                                    .stroke(Color.error, lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, Layout.spacing20)
                    .padding(.top, Layout.spacing16)
                    .padding(.bottom, Layout.spacing20)
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
                .environmentObject(appViewModel)
        }
        .alert("Delete Profile", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                appViewModel.deleteAllDataAndResetToOnboarding()
            }
        } message: {
            Text("This will permanently delete your profile and all data including projects, tasks, and game history. This action cannot be undone.")
        }
    }
}

struct ProfileCard: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: Layout.spacing20) {
            // Avatar and Name
            VStack(spacing: Layout.spacing16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.surface)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .stroke(Color.border, lineWidth: 2)
                        )
                    
                    if let user = appViewModel.currentUser,
                       let avatarData = user.avatarData,
                       let uiImage = UIImage(data: avatarData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.border)
                    }
                }
                
                // Name
                VStack(spacing: Layout.spacing4) {
                    Text(appViewModel.currentUser?.name ?? "Unknown User")
                        .appStyle(.title, color: .inkPrimaryDark)
                    
                    if let goal = appViewModel.currentUser?.goal, !goal.isEmpty {
                        Text(goal)
                            .appStyle(.body, color: .inkPrimaryDark.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            
            // Stats
            HStack(spacing: Layout.spacing20) {
                ProfileStat(
                    icon: "dollarsign.circle.fill",
                    title: "Coins",
                    value: "\(appViewModel.coinBalance)",
                    color: .accentGold
                )
                
                Divider()
                    .frame(height: 40)
                    .background(Color.border)
                
                ProfileStat(
                    icon: "flame.fill",
                    title: "Streak",
                    value: "\(appViewModel.currentUser?.streakCount ?? 0) days",
                    color: .accentOrange
                )
                
                Divider()
                    .frame(height: 40)
                    .background(Color.border)
                
                ProfileStat(
                    icon: "calendar.badge.plus",
                    title: "Member Since",
                    value: memberSinceText,
                    color: .primary
                )
            }
        }
        .padding(Layout.spacing20)
        .glassCard()
    }
    
    private var memberSinceText: String {
        guard let createdAt = appViewModel.currentUser?.createdAt else { return "Unknown" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: createdAt)
    }
}

struct ProfileStat: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Layout.spacing8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: Layout.spacing4) {
                Text(value)
                    .appStyle(.subtitle, color: .inkPrimaryDark)
                    .multilineTextAlignment(.center)
                
                Text(title)
                    .appStyle(.caption, color: .inkPrimaryDark.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
    }
}



#Preview {
    ProfileView()
        .environmentObject(AppViewModel())
}