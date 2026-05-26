// TunnelSettingsView.swift
// V2X

import SwiftUI

struct TunnelSettingsView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var showIPSettings = false

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Tunnel Status Card
                    tunnelStatusCard

                    // Tunnel Mode Section
                    settingsSection(title: "Режим туннеля") {
                        SettingsToggleRow(
                            icon: "network",
                            iconColor: .v2xCyan,
                            title: "Постоянный туннель",
                            subtitle: "Автоматическое переподключение",
                            isOn: Binding(
                                get: { vpnManager.tunnelMode == .persistent },
                                set: { if $0 { vpnManager.tunnelMode = .persistent } }
                            )
                        )
                    }

                    // IP Settings
                    settingsSection(title: "Настройки IP") {
                        ForEach(VPNManager.IPVersion.allCases, id: \.self) { version in
                            Button {
                                vpnManager.ipVersion = version
                                HapticManager.shared.triggerImpact(.light)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: vpnManager.ipVersion == version ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(vpnManager.ipVersion == version ? .v2xCyan : .gray)

                                    Text(version.rawValue)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)

                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(LiquidPressButtonStyle())

                            if version != VPNManager.IPVersion.allCases.last {
                                Divider()
                                    .background(Color.white.opacity(0.06))
                                    .padding(.leading, 56)
                            }
                        }
                    }

                    // On Demand
                    settingsSection(title: "По требованию") {
                        SettingsToggleRow(
                            icon: "bolt.circle.fill",
                            iconColor: .v2xYellow,
                            title: "По требованию",
                            subtitle: "Автоматическое подключение при доступе к сети",
                            isOn: $vpnManager.isOnDemandEnabled
                        )
                    }

                    // Network Settings
                    settingsSection(title: "Сеть") {
                        SettingsToggleRow(
                            icon: "wifi",
                            iconColor: .v2xGreen,
                            title: "Включить все сети",
                            subtitle: "Wi-Fi, сотовые данные, Ethernet",
                            isOn: $vpnManager.connectOnAllNetworks
                        )

                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 56)

                        SettingsToggleRow(
                            icon: "moon.fill",
                            iconColor: .v2xPurple,
                            title: "Отключение в сне",
                            subtitle: "Отключать VPN при блокировке экрана",
                            isOn: $vpnManager.disconnectOnSleep
                        )

                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 56)

                        SettingsToggleRow(
                            icon: "square.split.2x2",
                            iconColor: .v2xBlue,
                            title: "Фрагментация",
                            subtitle: "Разбивать пакеты для обхода DPI",
                            isOn: $vpnManager.fragmentationEnabled
                        )
                    }

                    // Memory Settings
                    settingsSection(title: "Ресурсы") {
                        HStack(spacing: 12) {
                            Image(systemName: "memorychip")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.v2xOrange)
                                .frame(width: 32, height: 32)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.v2xOrange.opacity(0.12))
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ограничение памяти")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)

                                Text("\(vpnManager.memoryLimit) MB")
                                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.v2xTextTertiary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)

                        Slider(
                            value: Binding(
                                get: { Double(vpnManager.memoryLimit) },
                                set: { vpnManager.memoryLimit = Int($0) }
                            ),
                            in: 64...512,
                            step: 64
                        )
                        .tint(.v2xCyan)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .liquidGlassBackground(cornerRadius: 10)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Настройки туннеля")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Tunnel Status Card
    private var tunnelStatusCard: some View {
        LiquidGlassCard(
            cornerRadius: 20,
            glowColor: vpnManager.connectionState == .connected ? .v2xGreen : nil,
            glowRadius: vpnManager.connectionState == .connected ? 8 : 0
        ) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(vpnManager.connectionState.color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: "network")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(vpnManager.connectionState.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Статус туннеля")
                        .font(.system(size: 13))
                        .foregroundColor(.v2xTextTertiary)

                    Text(vpnManager.connectionState.rawValue)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(vpnManager.connectionState.color)

                    if vpnManager.connectionState == .connected {
                        CompactConnectionTimer()
                    }
                }

                Spacer()

                if vpnManager.connectionState == .connected {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(vpnManager.ipVersion.rawValue)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.v2xCyan)
                        Text(vpnManager.tunnelMode.rawValue)
                            .font(.system(size: 10))
                            .foregroundColor(.v2xTextTertiary)
                    }
                }
            }
            .padding(16)
        }
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
}
