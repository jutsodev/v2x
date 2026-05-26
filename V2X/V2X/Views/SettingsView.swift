// SettingsView.swift
// V2X

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var vpnManager: VPNManager
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var hapticManager: HapticManager

    @State private var showAddConfig = false
    @State private var showExportConfig = false
    @State private var showResetAlert = false
    @State private var showAbout = false
    @State private var showLogs = false
    @State private var showURLSchemes = false
    @State private var showTunnelSettings = false
    @State private var showDNSSettings = false
    @State private var showRoutingSettings = false
    @State private var showSubscription = false
    @State private var showStatistics = false
    @State private var showProfiles = false
    @State private var showThemePicker = false
    @State private var showCommunity = false
    @State private var showPingSettings = false
    @State private var showAISettings = false
    @State private var showQuantumStealth = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Настройки")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 8)

                // Configuration Section
                settingsSection(title: "Конфигурация") {
                    SettingsActionRow(icon: "plus.circle.fill", iconColor: .v2xCyan, title: "Добавить конфигурацию") {
                        showAddConfig = true
                    }
                    sectionDivider
                    SettingsActionRow(icon: "square.and.arrow.up.fill", iconColor: .v2xPurple, title: "Экспорт конфигурации") {
                        showExportConfig = true
                    }
                    sectionDivider
                    SettingsActionRow(icon: "list.bullet.rectangle.fill", iconColor: .v2xGreen, title: "Локальные профили") {
                        showProfiles = true
                    }
                }

                // Preferences Section
                settingsSection(title: "Предпочтения") {
                    Button {
                        showSubscription = true
                    } label: {
                        SettingsNavRow(icon: "link.circle.fill", iconColor: .v2xCyan, title: "Подписка", value: "\(profileManager.subscriptions.count)")
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    sectionDivider

                    Button {
                        showRoutingSettings = true
                    } label: {
                        SettingsNavRow(icon: "arrow.triangle.branch", iconColor: .v2xPurple, title: "Роутинг", value: "\(profileManager.routingRules.count) правил")
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    sectionDivider

                    Button {
                        showTunnelSettings = true
                    } label: {
                        SettingsNavRow(icon: "network", iconColor: .v2xGreen, title: "Туннель")
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    sectionDivider

                    Button {
                        showPingSettings = true
                    } label: {
                        SettingsNavRow(icon: "waveform.path.ecg", iconColor: .v2xYellow, title: "Пинг")
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    sectionDivider

                    Button {
                        showDNSSettings = true
                    } label: {
                        SettingsNavRow(icon: "server.rack", iconColor: .v2xBlue, title: "DNS", value: profileManager.activeDNS?.name ?? "Default")
                    }
                    .buttonStyle(LiquidPressButtonStyle())
                }

                // AI & Security Section
                settingsSection(title: "AI и безопасность") {
                    Button {
                        showAISettings = true
                    } label: {
                        SettingsNavRow(icon: "brain.head.profile", iconColor: .v2xCyan, title: "AI Smart Connect")
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    sectionDivider

                    Button {
                        showQuantumStealth = true
                    } label: {
                        SettingsNavRow(icon: "bolt.shield.fill", iconColor: .v2xPurple, title: "Quantum Stealth Mode")
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    sectionDivider

                    SettingsToggleRow(
                        icon: "shield.checkered",
                        iconColor: .v2xGreen,
                        title: "Live Threat Shield",
                        isOn: Binding(
                            get: { ThreatShield.shared.isEnabled },
                            set: { _ in ThreatShield.shared.toggle() }
                        )
                    )
                }

                // Themes Section
                settingsSection(title: "Внешний вид") {
                    Button {
                        showThemePicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: themeManager.currentTheme.icon)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeManager.currentTheme.accentColor)
                                .frame(width: 32, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(themeManager.currentTheme.accentColor.opacity(0.12))
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Mood Liquid Theme")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                Text(themeManager.currentTheme.displayName)
                                    .font(.system(size: 12))
                                    .foregroundColor(.v2xTextTertiary)
                            }

                            Spacer()

                            // Theme preview dots
                            HStack(spacing: 3) {
                                ForEach(themeManager.currentTheme.gradientColors.prefix(3), id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 8, height: 8)
                                }
                            }

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.v2xTextTertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    sectionDivider

                    SettingsToggleRow(
                        icon: "hand.tap.fill",
                        iconColor: .v2xYellow,
                        title: "Тактильный отклик",
                        isOn: $hapticManager.isHapticsEnabled
                    )
                }

                // Useful Section
                settingsSection(title: "Полезное") {
                    SettingsActionRow(icon: "person.2.fill", iconColor: .v2xCyan, title: "Комьюнити") {
                        showCommunity = true
                    }
                    sectionDivider
                    SettingsActionRow(icon: "heart.fill", iconColor: .v2xRed, title: "Поддержать разработчиков") {
                        // Open donation link
                    }
                    sectionDivider
                    SettingsActionRow(icon: "questionmark.circle.fill", iconColor: .v2xBlue, title: "Как подключиться?") {
                        showCommunity = true
                    }
                }

                // More Section
                settingsSection(title: "Подробнее") {
                    Button {
                        showURLSchemes = true
                    } label: {
                        SettingsNavRow(icon: "link", iconColor: .v2xCyan, title: "Схемы URL")
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    sectionDivider

                    Button {
                        showLogs = true
                    } label: {
                        SettingsNavRow(icon: "chart.bar.fill", iconColor: .v2xPurple, title: "Логи")
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    sectionDivider

                    Button {
                        showStatistics = true
                    } label: {
                        SettingsNavRow(icon: "chart.xyaxis.line", iconColor: .v2xGreen, title: "Статистика")
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    sectionDivider

                    Button {
                        showAbout = true
                    } label: {
                        SettingsNavRow(icon: "info.circle.fill", iconColor: .v2xTextTertiary, title: "О приложении")
                    }
                    .buttonStyle(LiquidPressButtonStyle())
                }

                // Reset Section
                Button {
                    showResetAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Сбросить всё")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.v2xRed)
                        Spacer()
                    }
                    .padding(.vertical, 14)
                    .liquidGlassBackground(cornerRadius: 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.v2xRed.opacity(0.2), lineWidth: 0.5)
                    )
                }
                .buttonStyle(LiquidPressButtonStyle())

                // Version footer
                VStack(spacing: 4) {
                    Text("V2X v1.0.0 (Build 1)")
                        .font(.system(size: 12))
                        .foregroundColor(.v2xTextTertiary)
                    Text("t.me/kreadwrite • @kreadwriteQ")
                        .font(.system(size: 11))
                        .foregroundColor(.v2xTextTertiary)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .alert("Сбросить всё?", isPresented: $showResetAlert) {
            Button("Отмена", role: .cancel) {}
            Button("Сбросить", role: .destructive) {
                profileManager.resetAll()
            }
        } message: {
            Text("Все конфигурации, подписки и настройки будут удалены.")
        }
        .sheet(isPresented: $showAddConfig) { ConfigImportView() }
        .sheet(isPresented: $showProfiles) { LocalProfilesView() }
        .sheet(isPresented: $showURLSchemes) { URLSchemesView() }
        .sheet(isPresented: $showTunnelSettings) { TunnelSettingsView() }
        .sheet(isPresented: $showDNSSettings) { DNSSettingsView() }
        .sheet(isPresented: $showRoutingSettings) { RoutingView() }
        .sheet(isPresented: $showSubscription) { SubscriptionView() }
        .sheet(isPresented: $showStatistics) { StatisticsView() }
        .sheet(isPresented: $showThemePicker) { ThemePickerView() }
        .sheet(isPresented: $showLogs) { LogsView() }
        .sheet(isPresented: $showAbout) { AboutView() }
        .sheet(isPresented: $showCommunity) { CommunityView() }
        .sheet(isPresented: $showAISettings) { AISmartConnectView() }
        .sheet(isPresented: $showQuantumStealth) { QuantumStealthView() }
        .sheet(isPresented: $showPingSettings) { PingSettingsView() }
    }

    // MARK: - Helpers
    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            GlassSectionCard {
                content()
            }
        }
    }

    private var sectionDivider: some View {
        Divider()
            .background(Color.white.opacity(0.06))
            .padding(.leading, 56)
    }
}
