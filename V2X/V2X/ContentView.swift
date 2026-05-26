// ContentView.swift
// V2X

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var vpnManager: VPNManager
    @State private var selectedTab: AppTab = .home
    @State private var tabBarOffset: CGFloat = 0
    @State private var showSplash = true
    @Namespace private var tabNamespace

    enum AppTab: String, CaseIterable {
        case home = "Главная"
        case settings = "Настройки"

        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor
                .ignoresSafeArea()

            if showSplash {
                SplashView(showSplash: $showSplash)
                    .transition(.opacity.combined(with: .scale(scale: 1.1)))
            } else {
                VStack(spacing: 0) {
                    tabContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                    liquidGlassTabBar
                }
                .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showSplash)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: selectedTab)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .home:
            MainView()
        case .settings:
            SettingsView()
        }
    }

    private var liquidGlassTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 12)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.08),
                                        Color.white.opacity(0.02),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.05),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 20, y: 10)
            }
        )
        .padding(.horizontal, 60)
        .padding(.bottom, 20)
    }

    private func tabButton(for tab: AppTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = tab
            }
            HapticManager.shared.triggerImpact(.light)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .symbolEffect(.bounce, value: selectedTab == tab)

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .foregroundColor(selectedTab == tab ? themeManager.currentTheme.accentColor : .gray.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                Group {
                    if selectedTab == tab {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.currentTheme.accentColor.opacity(0.15))
                            .matchedGeometryEffect(id: "tabIndicator", in: tabNamespace)
                    }
                }
            )
        }
        .buttonStyle(LiquidPressButtonStyle())
    }
}

// MARK: - Splash Screen
struct SplashView: View {
    @Binding var showSplash: Bool
    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var ringScale: CGFloat = 0.5
    @State private var ringOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var particlesVisible = false

    var body: some View {
        ZStack {
            Color(hex: "050505")
                .ignoresSafeArea()

            // Particle background
            if particlesVisible {
                ForEach(0..<30, id: \.self) { i in
                    SplashParticle(index: i)
                }
            }

            VStack(spacing: 24) {
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3, id: \.self) { ring in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "00F5FF").opacity(0.3 - Double(ring) * 0.1),
                                        Color(hex: "B026FF").opacity(0.2 - Double(ring) * 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: 120 + CGFloat(ring) * 30, height: 120 + CGFloat(ring) * 30)
                            .scaleEffect(ringScale)
                            .opacity(ringOpacity)
                    }

                    // Main logo circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "00F5FF").opacity(0.3),
                                    Color(hex: "B026FF").opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(hex: "00F5FF").opacity(0.5), radius: glowRadius)

                    // V2X Text
                    Text("V2X")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "00F5FF"), Color(hex: "B026FF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 8) {
                    Text("V2X")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Твой неубиваемый туннель в свободный интернет")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                glowRadius = 30
                ringScale = 1.0
                ringOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                textOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                particlesVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

struct SplashParticle: View {
    let index: Int
    @State private var offset: CGSize = .zero
    @State private var opacity: Double = 0

    var body: some View {
        Circle()
            .fill(
                [Color(hex: "00F5FF"), Color(hex: "B026FF"), Color(hex: "00FF9D")][index % 3]
            )
            .frame(width: CGFloat.random(in: 2...6), height: CGFloat.random(in: 2...6))
            .offset(offset)
            .opacity(opacity)
            .onAppear {
                let angle = Double.random(in: 0...360) * .pi / 180
                let distance = CGFloat.random(in: 80...200)
                withAnimation(
                    .easeOut(duration: Double.random(in: 1.5...3.0))
                    .delay(Double.random(in: 0...0.8))
                    .repeatForever(autoreverses: true)
                ) {
                    offset = CGSize(
                        width: cos(angle) * distance,
                        height: sin(angle) * distance
                    )
                    opacity = Double.random(in: 0.2...0.7)
                }
            }
    }
}
