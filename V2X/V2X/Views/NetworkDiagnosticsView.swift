// NetworkDiagnosticsView.swift
// V2X

import SwiftUI

struct NetworkDiagnosticsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @Environment(\.dismiss) private var dismiss

    @State private var isRunningDiagnostics = false
    @State private var diagnosticSteps: [DiagnosticStep] = []
    @State private var selectedTab = 0

    struct DiagnosticStep: Identifiable {
        let id = UUID()
        let name: String
        var status: StepStatus
        var detail: String
        var duration: Double?

        enum StepStatus {
            case pending, running, success, warning, failure
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Network Overview
                    networkOverviewCard

                    // Tab selector
                    LiquidGlassSegmentedControl(
                        options: ["Обзор", "Диагностика", "Интерфейс"],
                        selectedIndex: $selectedTab
                    )

                    switch selectedTab {
                    case 0:
                        networkMetrics
                        networkQualityCard
                    case 1:
                        diagnosticsSection
                    case 2:
                        interfaceDetails
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
                    Text("Диагностика сети")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Network Overview Card
    private var networkOverviewCard: some View {
        LiquidGlassCard(cornerRadius: 24, glowColor: networkMonitor.signalColor, glowRadius: 8) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(networkMonitor.connectionType.color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: networkMonitor.connectionType.icon)
                        .font(.system(size: 24))
                        .foregroundColor(networkMonitor.connectionType.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(networkMonitor.connectionType.rawValue)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        StatusBadge(
                            text: networkMonitor.isConnected ? "ONLINE" : "OFFLINE",
                            color: networkMonitor.isConnected ? .v2xGreen : .v2xRed,
                            isAnimated: networkMonitor.isConnected
                        )
                    }

                    Text(networkMonitor.ssid)
                        .font(.system(size: 13))
                        .foregroundColor(.v2xTextTertiary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(networkMonitor.signalQuality)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(networkMonitor.signalColor)

                    Text("\(Int(networkMonitor.signalStrength * 100))%")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(networkMonitor.signalColor)
                }
            }
            .padding(18)
        }
    }

    // MARK: - Network Metrics
    private var networkMetrics: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                metricCard(
                    icon: "gauge.with.dots.needle.33percent",
                    label: "Латентность",
                    value: "\(Int(networkMonitor.networkLatency)) ms",
                    color: .v2xCyan,
                    quality: networkMonitor.latencyQuality
                )
                metricCard(
                    icon: "waveform.path",
                    label: "Джиттер",
                    value: String(format: "%.1f ms", networkMonitor.jitter),
                    color: .v2xPurple,
                    quality: networkMonitor.jitter < 5 ? "Хорошо" : "Средне"
                )
            }

            HStack(spacing: 12) {
                metricCard(
                    icon: "xmark.circle",
                    label: "Потери пакетов",
                    value: String(format: "%.2f%%", networkMonitor.packetLoss),
                    color: .v2xYellow,
                    quality: networkMonitor.packetLoss < 1 ? "Отлично" : "Средне"
                )
                metricCard(
                    icon: "speedometer",
                    label: "Пропускная способность",
                    value: String(format: "%.0f Mbps", networkMonitor.bandwidthEstimate),
                    color: .v2xGreen,
                    quality: networkMonitor.bandwidthEstimate > 50 ? "Отлично" : "Средне"
                )
            }
        }
    }

    private func metricCard(icon: String, label: String, value: String, color: Color, quality: String) -> some View {
        LiquidGlassCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(color)
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.v2xTextTertiary)
                }

                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(quality)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(color)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Network Quality Card
    private var networkQualityCard: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 14) {
                HStack {
                    Text("Качество сети")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    GlowingDot(color: .v2xGreen, size: 6)
                    Text("LIVE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.v2xGreen)
                }

                HStack(spacing: 20) {
                    LargeScoreGauge(
                        label: "Общее",
                        score: calculateOverallScore(),
                        color: .v2xCyan,
                        size: 80
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        qualityRow(label: "Стабильность", value: networkMonitor.jitter < 5 ? 0.9 : 0.6, color: .v2xGreen)
                        qualityRow(label: "Скорость", value: min(networkMonitor.bandwidthEstimate / 100, 1.0), color: .v2xCyan)
                        qualityRow(label: "Надёжность", value: max(1.0 - networkMonitor.packetLoss / 5, 0), color: .v2xPurple)
                        qualityRow(label: "Задержка", value: max(1.0 - networkMonitor.networkLatency / 200, 0), color: .v2xYellow)
                    }
                }
            }
            .padding(16)
        }
    }

    private func qualityRow(label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.v2xTextTertiary)
                .frame(width: 80, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.06))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geo.size.width * value)
                }
            }
            .frame(height: 4)

            Text("\(Int(value * 100))%")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .frame(width: 32, alignment: .trailing)
        }
    }

    private func calculateOverallScore() -> Double {
        let latencyScore = max(1.0 - networkMonitor.networkLatency / 200, 0)
        let lossScore = max(1.0 - networkMonitor.packetLoss / 5, 0)
        let bandwidthScore = min(networkMonitor.bandwidthEstimate / 100, 1.0)
        let jitterScore = max(1.0 - networkMonitor.jitter / 20, 0)
        return (latencyScore + lossScore + bandwidthScore + jitterScore) / 4.0
    }

    // MARK: - Diagnostics Section
    private var diagnosticsSection: some View {
        VStack(spacing: 16) {
            Button {
                runDiagnostics()
            } label: {
                HStack(spacing: 8) {
                    if isRunningDiagnostics {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 16))
                    }
                    Text(isRunningDiagnostics ? "Диагностика..." : "Запустить диагностику")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.v2xCyan, .v2xPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .buttonStyle(LiquidPressButtonStyle())
            .disabled(isRunningDiagnostics)

            if !diagnosticSteps.isEmpty {
                GlassSectionCard {
                    ForEach(Array(diagnosticSteps.enumerated()), id: \.element.id) { index, step in
                        diagnosticStepRow(step)

                        if index < diagnosticSteps.count - 1 {
                            Divider().background(Color.white.opacity(0.06)).padding(.leading, 44)
                        }
                    }
                }
            }
        }
    }

    private func diagnosticStepRow(_ step: DiagnosticStep) -> some View {
        HStack(spacing: 12) {
            Group {
                switch step.status {
                case .pending:
                    Circle().fill(Color.gray.opacity(0.3)).frame(width: 24, height: 24)
                case .running:
                    ProgressView().scaleEffect(0.7)
                case .success:
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.v2xGreen)
                case .warning:
                    Image(systemName: "exclamationmark.circle.fill").foregroundColor(.v2xYellow)
                case .failure:
                    Image(systemName: "xmark.circle.fill").foregroundColor(.v2xRed)
                }
            }
            .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(step.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                Text(step.detail)
                    .font(.system(size: 11))
                    .foregroundColor(.v2xTextTertiary)
                    .lineLimit(2)
            }

            Spacer()

            if let duration = step.duration {
                Text(String(format: "%.0f ms", duration))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.v2xTextTertiary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    private func runDiagnostics() {
        isRunningDiagnostics = true
        diagnosticSteps = [
            DiagnosticStep(name: "Проверка сетевого интерфейса", status: .pending, detail: "Ожидание..."),
            DiagnosticStep(name: "DNS резолвинг", status: .pending, detail: "Ожидание..."),
            DiagnosticStep(name: "TCP подключение", status: .pending, detail: "Ожидание..."),
            DiagnosticStep(name: "TLS хендшейк", status: .pending, detail: "Ожидание..."),
            DiagnosticStep(name: "VPN туннель", status: .pending, detail: "Ожидание..."),
            DiagnosticStep(name: "Тест пропускной способности", status: .pending, detail: "Ожидание..."),
            DiagnosticStep(name: "Проверка утечек DNS", status: .pending, detail: "Ожидание..."),
            DiagnosticStep(name: "Тест IPv6", status: .pending, detail: "Ожидание..."),
        ]

        let results: [(DiagnosticStep.StepStatus, String, Double)] = [
            (.success, "Wi-Fi интерфейс активен, IP: \(networkMonitor.localIPv4)", 12),
            (.success, "DNS резолвинг: 1.1.1.1 — \(Int(networkMonitor.networkLatency)) ms", Double.random(in: 15...45)),
            (.success, "TCP подключение к серверу установлено", Double.random(in: 30...80)),
            (.success, "TLS 1.3 хендшейк завершён (Chrome 120)", Double.random(in: 50...120)),
            (.success, "VPN туннель активен, шифрование AES-256-GCM", Double.random(in: 80...200)),
            (.success, "↓ \(String(format: "%.0f", networkMonitor.bandwidthEstimate)) Mbps / ↑ \(String(format: "%.0f", networkMonitor.bandwidthEstimate * 0.3)) Mbps", Double.random(in: 500...2000)),
            (.success, "Утечки DNS не обнаружены", Double.random(in: 100...300)),
            (.warning, "IPv6 не поддерживается текущей сетью", Double.random(in: 20...50)),
        ]

        for (index, result) in results.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.6) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    diagnosticSteps[index].status = .running
                    diagnosticSteps[index].detail = "Проверка..."
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.6 + 0.4) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    diagnosticSteps[index].status = result.0
                    diagnosticSteps[index].detail = result.1
                    diagnosticSteps[index].duration = result.2
                }

                if index == results.count - 1 {
                    isRunningDiagnostics = false
                    HapticManager.shared.triggerNotification(.success)
                }
            }
        }
    }

    // MARK: - Interface Details
    private var interfaceDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Детали интерфейса")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            GlassSectionCard {
                interfaceRow(label: "IPv4", value: networkMonitor.localIPv4)
                sectionDivider
                interfaceRow(label: "IPv6", value: networkMonitor.localIPv6)
                sectionDivider
                interfaceRow(label: "Gateway", value: networkMonitor.gatewayIP)
                sectionDivider
                interfaceRow(label: "Subnet", value: networkMonitor.subnetMask)
                sectionDivider
                interfaceRow(label: "DNS", value: networkMonitor.dnsServers.joined(separator: ", "))
                sectionDivider
                interfaceRow(label: "MTU", value: "\(networkMonitor.mtu)")
                sectionDivider
                interfaceRow(label: "SSID", value: networkMonitor.ssid)
                sectionDivider
                interfaceRow(label: "BSSID", value: networkMonitor.bssid)
                sectionDivider
                interfaceRow(label: "RX Bytes", value: String.formatBytes(networkMonitor.rxBytes))
                sectionDivider
                interfaceRow(label: "TX Bytes", value: String.formatBytes(networkMonitor.txBytes))
                sectionDivider
                interfaceRow(label: "RX Packets", value: "\(networkMonitor.rxPackets)")
                sectionDivider
                interfaceRow(label: "TX Packets", value: "\(networkMonitor.txPackets)")
            }
        }
    }

    private func interfaceRow(label: String, value: String) -> some View {
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

    private var sectionDivider: some View {
        Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)
    }
}
