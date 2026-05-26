// ConnectionDetailView.swift
// V2X

import SwiftUI

struct ConnectionDetailView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var stateMachine = ConnectionStateMachine()
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Connection status card
                    connectionStatusCard

                    // Tab selector
                    LiquidGlassSegmentedControl(
                        options: ["Трафик", "Фазы", "Детали"],
                        selectedIndex: $selectedTab
                    )

                    switch selectedTab {
                    case 0:
                        trafficSection
                    case 1:
                        connectionPhasesSection
                    case 2:
                        connectionDetails
                    default:
                        EmptyView()
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
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .liquidGlassBackground(cornerRadius: 10)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Детали подключения")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Connection Status Card
    private var connectionStatusCard: some View {
        LiquidGlassCard(
            cornerRadius: 24,
            glowColor: vpnManager.isConnected ? .v2xGreen : nil,
            glowRadius: vpnManager.isConnected ? 10 : 0
        ) {
            VStack(spacing: 14) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(vpnManager.isConnected ? Color.v2xGreen.opacity(0.15) : Color.gray.opacity(0.1))
                            .frame(width: 50, height: 50)

                        Image(systemName: vpnManager.isConnected ? "checkmark.shield.fill" : "shield.slash")
                            .font(.system(size: 22))
                            .foregroundColor(vpnManager.isConnected ? .v2xGreen : .gray)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(vpnManager.isConnected ? "Подключено" : "Отключено")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)

                            GlowingDot(color: vpnManager.isConnected ? .v2xGreen : .gray, isActive: vpnManager.isConnected)
                        }

                        if vpnManager.isConnected {
                            Text("Время: \(vpnManager.stats.formattedDuration)")
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(.v2xTextTertiary)
                        }
                    }

                    Spacer()

                    if vpnManager.isConnected, let profile = vpnManager.activeProfile {
                        StatusBadge(text: profile.protocolType.rawValue, color: profile.protocolType.color)
                    }
                }

                if vpnManager.isConnected {
                    HStack(spacing: 16) {
                        speedIndicator(
                            icon: "arrow.up",
                            label: "Upload",
                            speed: vpnManager.stats.formattedUploadSpeed,
                            color: .v2xCyan
                        )
                        speedIndicator(
                            icon: "arrow.down",
                            label: "Download",
                            speed: vpnManager.stats.formattedDownloadSpeed,
                            color: .v2xGreen
                        )
                        speedIndicator(
                            icon: "gauge.with.needle",
                            label: "Ping",
                            speed: "\(vpnManager.stats.ping) ms",
                            color: .v2xPurple
                        )
                    }
                }
            }
            .padding(18)
        }
    }

    private func speedIndicator(icon: String, label: String, speed: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(speed)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.v2xTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Traffic Section
    private var trafficSection: some View {
        VStack(spacing: 16) {
            // Live Traffic Graph
            LiquidGlassCard(cornerRadius: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Трафик в реальном времени")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        GlowingDot(color: .v2xGreen, size: 6, isActive: vpnManager.isConnected)
                    }

                    TrafficGraph()
                        .frame(height: 160)
                }
                .padding(14)
            }

            // Session Statistics
            LiquidGlassCard(cornerRadius: 20) {
                VStack(spacing: 12) {
                    HStack {
                        Text("Статистика сессии")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        statCell(label: "Загружено", value: String.formatBytes(vpnManager.stats.sessionDownload), icon: "arrow.down.circle", color: .v2xGreen)
                        statCell(label: "Выгружено", value: String.formatBytes(vpnManager.stats.sessionUpload), icon: "arrow.up.circle", color: .v2xCyan)
                        statCell(label: "Пакеты (IN)", value: "\(vpnManager.stats.packetsIn)", icon: "arrow.down.right", color: .v2xPurple)
                        statCell(label: "Пакеты (OUT)", value: "\(vpnManager.stats.packetsOut)", icon: "arrow.up.right", color: .v2xYellow)
                        statCell(label: "Пик загрузки", value: String.formatSpeed(vpnManager.stats.peakDownloadSpeed), icon: "gauge.with.dots.needle.100percent", color: .v2xGreen)
                        statCell(label: "Пик выгрузки", value: String.formatSpeed(vpnManager.stats.peakUploadSpeed), icon: "gauge.with.dots.needle.67percent", color: .v2xCyan)
                    }
                }
                .padding(16)
            }

            // All-Time Stats
            LiquidGlassCard(cornerRadius: 20) {
                VStack(spacing: 12) {
                    HStack {
                        Text("Общая статистика")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }

                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text(String.formatBytes(vpnManager.stats.totalDownload))
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.v2xGreen)
                            Text("Всего загружено")
                                .font(.system(size: 10))
                                .foregroundColor(.v2xTextTertiary)
                        }

                        VStack(spacing: 4) {
                            Text(String.formatBytes(vpnManager.stats.totalUpload))
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.v2xCyan)
                            Text("Всего выгружено")
                                .font(.system(size: 10))
                                .foregroundColor(.v2xTextTertiary)
                        }
                    }
                }
                .padding(16)
            }
        }
    }

    private func statCell(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.v2xTextTertiary)
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.05))
        )
    }

    // MARK: - Connection Phases Section
    private var connectionPhasesSection: some View {
        VStack(spacing: 16) {
            LiquidGlassCard(cornerRadius: 20) {
                VStack(spacing: 12) {
                    HStack {
                        Text("Фазы подключения")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        StatusBadge(text: stateMachine.state.rawValue, color: stateMachine.state.color)
                    }

                    LiquidGlassProgressBar(progress: stateMachine.progress, color: .v2xCyan, height: 4, showPercentage: true)

                    ForEach(stateMachine.phases) { phase in
                        phaseRow(phase)
                    }
                }
                .padding(16)
            }

            Button {
                if stateMachine.state == .connected {
                    stateMachine.startDisconnection()
                } else {
                    stateMachine.startConnection()
                }
            } label: {
                Text(stateMachine.state == .connected ? "Отключить" : "Подключить")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                stateMachine.state == .connected
                                    ? LinearGradient(colors: [.v2xRed, .v2xOrange], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [.v2xCyan, .v2xPurple], startPoint: .leading, endPoint: .trailing)
                            )
                    )
            }
            .buttonStyle(LiquidPressButtonStyle())
        }
    }

    private func phaseRow(_ phase: ConnectionStateMachine.PhaseInfo) -> some View {
        HStack(spacing: 12) {
            phaseStatusIcon(phase.status)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(phase.phase.rawValue)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)

                if let detail = phase.detail {
                    Text(detail)
                        .font(.system(size: 11))
                        .foregroundColor(.v2xTextTertiary)
                }
            }

            Spacer()

            if let duration = phase.duration {
                Text(String(format: "%.0f ms", duration))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.v2xTextTertiary)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func phaseStatusIcon(_ status: ConnectionStateMachine.PhaseInfo.PhaseStatus) -> some View {
        switch status {
        case .pending:
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 20, height: 20)
        case .active:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .v2xCyan))
                .scaleEffect(0.7)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(.v2xGreen)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(.v2xRed)
        }
    }

    // MARK: - Connection Details
    private var connectionDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Детали подключения")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            GlassSectionCard {
                if let profile = vpnManager.activeProfile {
                    detailRow(label: "Профиль", value: profile.name)
                    detailDivider
                    detailRow(label: "Протокол", value: profile.protocolType.rawValue)
                    detailDivider
                    detailRow(label: "Сервер", value: V2XCrypto.obfuscateAddress(profile.serverAddress))
                    detailDivider
                    detailRow(label: "Порт", value: "\(profile.serverPort)")
                }

                detailDivider
                detailRow(label: "Локальный IP", value: networkMonitor.localIPv4)
                detailDivider
                detailRow(label: "VPN IP", value: "10.0.0.2")
                detailDivider
                detailRow(label: "DNS", value: networkMonitor.dnsServers.joined(separator: ", "))
                detailDivider
                detailRow(label: "Шифрование", value: "AES-256-GCM")
                detailDivider
                detailRow(label: "TLS", value: "1.3")
                detailDivider
                detailRow(label: "Fingerprint", value: "Chrome 120")
                detailDivider
                detailRow(label: "Мультиплекс", value: vpnManager.isMuxEnabled ? "Вкл" : "Выкл")
                detailDivider
                detailRow(label: "Фрагментация", value: vpnManager.isFragmentEnabled ? "Вкл" : "Выкл")
                detailDivider
                detailRow(label: "MTU", value: "\(networkMonitor.mtu)")
                detailDivider
                detailRow(label: "Quantum Stealth", value: vpnManager.isQuantumStealthEnabled ? "Вкл" : "Выкл")
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.v2xTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.v2xTextTertiary)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var detailDivider: some View {
        Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)
    }
}
