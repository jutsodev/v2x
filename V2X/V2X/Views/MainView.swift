// MainView.swift
// V2X

import SwiftUI

struct MainView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var statsTracker: StatsTracker
    @EnvironmentObject var aiSmartConnect: AISmartConnect
    @EnvironmentObject var threatShield: ThreatShield

    @State private var showAIPanel = false
    @State private var showThreatShield = false
    @State private var showProfilePicker = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection
                connectionCard
                statsSection
                quickActionsSection
                aiSmartRouteSection
                threatShieldSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .onAppear {
            statsTracker.startTracking()
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("V2X")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: themeManager.currentTheme.gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                Text("Твой неубиваемый туннель")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.v2xTextTertiary)
            }

            Spacer()

            // Profile badge
            Button {
                showProfilePicker = true
            } label: {
                HStack(spacing: 6) {
                    Circle()
                        .fill(vpnManager.connectionState.color)
                        .frame(width: 8, height: 8)

                    Text(vpnManager.activeProfile?.name ?? "Нет профиля")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .liquidGlassBackground(cornerRadius: 12)
            }
            .buttonStyle(LiquidPressButtonStyle())
            .sheet(isPresented: $showProfilePicker) {
                LocalProfilesView()
            }
        }
    }

    // MARK: - Connection Card
    private var connectionCard: some View {
        LiquidGlassCard(
            cornerRadius: 28,
            glowColor: vpnManager.connectionState == .connected
                ? themeManager.currentTheme.accentColor : nil,
            glowRadius: vpnManager.connectionState == .connected ? 15 : 0
        ) {
            VStack(spacing: 20) {
                // Status
                StatusIndicator(state: vpnManager.connectionState)

                // Connection button with pulse
                ZStack {
                    if vpnManager.connectionState == .connected {
                        V2XPulseView(particleCount: 35, radius: 100)
                    }

                    // Pulse rings
                    if vpnManager.connectionState == .connected {
                        ForEach(0..<3, id: \.self) { i in
                            ConnectionPulseRing(
                                color: themeManager.currentTheme.accentColor,
                                isActive: true
                            )
                            .frame(width: 140, height: 140)
                            .animation(
                                .easeOut(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(i) * 0.7),
                                value: vpnManager.connectionState
                            )
                        }
                    }

                    LargeConnectionButton(size: 140)
                }
                .frame(height: 220)

                // Timer or call to action
                if vpnManager.connectionState == .connected {
                    ConnectionTimer()
                } else if vpnManager.connectionState == .disconnected {
                    Text("Подключиться за 1 тап")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.v2xTextSecondary)
                } else {
                    Text(vpnManager.connectionState.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(vpnManager.connectionState.color)
                }

                // Active profile info
                if let profile = vpnManager.activeProfile {
                    HStack(spacing: 12) {
                        Image(systemName: profile.protocolType.icon)
                            .font(.system(size: 14))
                            .foregroundColor(profile.protocolType.color)

                        Text(profile.name)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.v2xTextSecondary)

                        if vpnManager.connectionState == .connected {
                            Text("•")
                                .foregroundColor(.v2xTextTertiary)

                            Text("\(vpnManager.currentPing) ms")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .foregroundColor(.v2xGreen)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .liquidGlassBackground(cornerRadius: 12)
                }
            }
            .padding(24)
        }
        .if(vpnManager.connectionState == .connected) { view in
            view.animatedBorder(
                colors: themeManager.currentTheme.gradientColors + [themeManager.currentTheme.gradientColors.first ?? .clear],
                cornerRadius: 28,
                lineWidth: 0.8
            )
        }
    }

    // MARK: - Stats Section
    private var statsSection: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 12) {
                HStack {
                    Text("Статистика")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    if vpnManager.connectionState == .connected {
                        Text("LIVE")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.v2xGreen)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.v2xGreen.opacity(0.15))
                            )
                    }
                }

                TrafficStatsRow(
                    icon: "arrow.up.circle.fill",
                    label: "Upload",
                    value: vpnManager.stats.formattedUpload,
                    color: .v2xPurple
                )

                Divider().opacity(0.1)

                TrafficStatsRow(
                    icon: "arrow.down.circle.fill",
                    label: "Download",
                    value: vpnManager.stats.formattedDownload,
                    color: .v2xCyan
                )

                Divider().opacity(0.1)

                TrafficStatsRow(
                    icon: "arrow.up.arrow.down.circle.fill",
                    label: "Total",
                    value: vpnManager.stats.formattedTotal,
                    color: .v2xGreen
                )

                if vpnManager.connectionState == .connected {
                    Divider().opacity(0.1)

                    MiniTrafficGraph(color: .v2xCyan, height: 40)
                        .padding(.top, 4)
                }
            }
            .padding(16)
        }
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        HStack(spacing: 12) {
            QuickActionCard(
                icon: "bolt.shield.fill",
                title: "Quantum\nStealth",
                isActive: vpnManager.isQuantumStealthEnabled,
                color: .v2xPurple
            ) {
                vpnManager.isQuantumStealthEnabled.toggle()
            }

            QuickActionCard(
                icon: "shield.checkered",
                title: "Threat\nShield",
                isActive: threatShield.isEnabled,
                color: .v2xGreen
            ) {
                threatShield.toggle()
            }

            QuickActionCard(
                icon: "brain.head.profile",
                title: "AI Smart\nRoute",
                isActive: aiSmartConnect.isEnabled,
                color: .v2xCyan
            ) {
                aiSmartConnect.toggleAI()
            }
        }
    }

    // MARK: - AI Smart Route
    private var aiSmartRouteSection: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.v2xCyan)

                        Text("AI Smart Connect")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    LiquidGlassToggle(isOn: Binding(
                        get: { aiSmartConnect.isEnabled },
                        set: { _ in aiSmartConnect.toggleAI() }
                    ))
                }

                if aiSmartConnect.isEnabled {
                    HStack(spacing: 16) {
                        ScoreGauge(label: "Сеть", score: aiSmartConnect.networkScore, color: .v2xCyan)
                        ScoreGauge(label: "Стабильность", score: aiSmartConnect.stabilityScore, color: .v2xGreen)
                        ScoreGauge(label: "Скорость", score: aiSmartConnect.speedScore, color: .v2xPurple)
                        ScoreGauge(label: "Задержка", score: aiSmartConnect.latencyScore, color: .v2xYellow)
                    }

                    if let server = aiSmartConnect.selectedServer {
                        HStack {
                            Text(server.flag)
                                .font(.system(size: 20))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(server.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("Рекомендован AI • \(Int(aiSmartConnect.confidence * 100))% уверенность")
                                    .font(.system(size: 11))
                                    .foregroundColor(.v2xTextTertiary)
                            }
                            Spacer()
                            Text("\(server.ping) ms")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.v2xGreen)
                        }
                        .padding(10)
                        .liquidGlassBackground(cornerRadius: 12)
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Threat Shield
    private var threatShieldSection: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.v2xGreen)
                            .symbolEffect(.pulse, isActive: threatShield.isEnabled)

                        Text("Live Threat Shield")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text("\(threatShield.totalBlocked)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.v2xGreen)
                    Text("заблокировано")
                        .font(.system(size: 11))
                        .foregroundColor(.v2xTextTertiary)
                }

                HStack(spacing: 8) {
                    ThreatStatBadge(icon: "eye.slash.fill", count: threatShield.trackersBlocked, label: "Трекеры", color: .v2xYellow)
                    ThreatStatBadge(icon: "nosign", count: threatShield.adsBlocked, label: "Реклама", color: .v2xBlue)
                    ThreatStatBadge(icon: "ladybug.fill", count: threatShield.malwareBlocked, label: "Malware", color: .v2xRed)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let isActive: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.triggerImpact(.medium)
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(isActive ? color : .gray)
                    .symbolEffect(.pulse, isActive: isActive)

                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(isActive ? .white : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .liquidGlassBackground(cornerRadius: 16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isActive ? color.opacity(0.3) : Color.clear,
                        lineWidth: 0.5
                    )
            )
            .if(isActive) { view in
                view.shadow(color: color.opacity(0.2), radius: 8)
            }
        }
        .buttonStyle(LiquidPressButtonStyle())
    }
}

// MARK: - Score Gauge
struct ScoreGauge: View {
    let label: String
    let score: Double
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: score)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))

                Text("\(Int(score * 100))")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
            .frame(width: 36, height: 36)

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.v2xTextTertiary)
                .lineLimit(1)
        }
    }
}

// MARK: - Threat Stat Badge
struct ThreatStatBadge: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)

            Text("\(count)")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.v2xTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .liquidGlassBackground(cornerRadius: 10)
    }
}
