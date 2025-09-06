//
//  OnboardingView.swift
//  TH_BizPlanner2
//
//  Created by IGOR on 14/08/2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()
            
            if viewModel.showCreateProfile {
                CreateProfileView(
                    onProfileCreated: { user in
                        appViewModel.completeOnboarding(with: user)
                    }
                )
            } else {
                OnboardingSlidesView(
                    currentSlide: $viewModel.currentSlide,
                    onSkip: {
                        viewModel.showCreateProfile = true
                    },
                    onContinue: {
                        if viewModel.currentSlide < 2 {
                            withAnimation(AppAnimations.medium) {
                                viewModel.currentSlide += 1
                            }
                        } else {
                            viewModel.showCreateProfile = true
                        }
                    }
                )
            }
        }
    }
}

struct OnboardingSlidesView: View {
    @Binding var currentSlide: Int
    let onSkip: () -> Void
    let onContinue: () -> Void
    
    private let slides = [
        OnboardingSlide(
            icon: "target",
            title: "Plan Your Success",
            description: "Create projects and organize tasks with ease. Set deadlines, track progress, and achieve your goals step by step."
        ),
                    OnboardingSlide(
                icon: "gamecontroller.fill",
                title: "Play & Earn",
                description: "Complete tasks to earn stars and unlock fun mini-games. Turn productivity into an engaging experience with achievements."
            ),
        OnboardingSlide(
            icon: "chart.line.uptrend.xyaxis",
            title: "Track Your Growth",
            description: "Monitor your progress with detailed stats and charts. See your productivity trends and celebrate achievements."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                Button("Skip") {
                    onSkip()
                }
                .foregroundColor(.primary)
                .font(.subtitle)
            }
            .padding(.horizontal, Layout.spacing20)
            .padding(.top, Layout.spacing16)
            
            Spacer()
            
            // Slides
            TabView(selection: $currentSlide) {
                ForEach(0..<slides.count, id: \.self) { index in
                    OnboardingSlideView(slide: slides[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(maxHeight: 400)
            
            // Page indicators
            HStack(spacing: Layout.spacing8) {
                ForEach(0..<slides.count, id: \.self) { index in
                    Circle()
                        .fill(currentSlide == index ? Color.primary : Color.border)
                        .frame(width: 8, height: 8)
                        .scaleEffect(currentSlide == index ? 1.2 : 1.0)
                        .animation(AppAnimations.quick, value: currentSlide)
                }
            }
            .padding(.top, Layout.spacing24)
            
            Spacer()
            
            // Continue button
            Button(currentSlide == slides.count - 1 ? "Get Started" : "Continue") {
                onContinue()
            }
            .primaryButton()
            .padding(.horizontal, Layout.spacing20)
            .padding(.bottom, Layout.spacing24)
        }
    }
}

struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    
    var body: some View {
        VStack(spacing: Layout.spacing24) {
            // Icon
            Image(systemName: slide.icon)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(.primary)
                .pulsing()
            
            // Content
            VStack(spacing: Layout.spacing16) {
                Text(slide.title)
                    .appStyle(.display, color: .inkPrimaryDark)
                    .multilineTextAlignment(.center)
                
                Text(slide.description)
                    .appStyle(.body, color: .inkPrimaryDark.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
        .padding(.horizontal, Layout.spacing24)
    }
}

struct OnboardingSlide {
    let icon: String
    let title: String
    let description: String
}

class OnboardingViewModel: ObservableObject {
    @Published var currentSlide = 0
    @Published var showCreateProfile = false
}

#Preview {
    OnboardingView()
        .environmentObject(AppViewModel())
}