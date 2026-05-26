// ThreatShieldView.swift
// V2X

import SwiftUI

struct ThreatShieldView: View {
    @EnvironmentObject var threatShield: ThreatShield
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Shield Status
                    shieldStatusCard

                    // Stats Overview
                    statsOverview

                    // Threat Breakdown
                    threatBreakdown

                    // Recent Events
                    recentEventsSection

                    // Settings
                    shieldSettings

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
                    Text("Threat Shield")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Shield Status Card
    private var shieldStatusCard: some View {
        LiquidGlassCard(
            cornerRadius: 24,
            glowColor: threatShield.isEnabled ? .v2xGreen : nil,
            glowRadius: threatShield.isEnabled ? 12 : 0
        ) {
            VStack(spacing: 16) {
                ZStack {
                    // Animated rings
                    ForEach(0..<3, id: \.self) { ring in
                        Circle()
                            .stroke(
                                Color.v2xGreen.opacity(threatShield.isEnabled ? 0.15 - Double(ring) * 0.04 : 0.03),
                                lineWidth: 1.5
                            )
                            .frame(width: 80 + CGFloat(ring) * 25, height: 80 + CGFloat(ring) * 25)
                    }

                    Image(systemName: "shield.checkered")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            threatShield.isEnabled
                                ? LinearGradient(colors: [.v2xGreen, .v2xCyan], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [.gray, .gray.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: threatShield.isEnabled ? .v2xGreen.opacity(0.5) : .clear, radius: 10)
                }
                .frame(height: 140)

                Text("Live Threat Shield")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Text("Блокировка трекеров, рекламы, malware и фишинга в реальном времени")
                    .font(.system(size: 12))
                    .foregroundColor(.v2xTextTertiary)
                    .multilineTextAlignment(.center)

                LiquidGlassToggle(isOn: Binding(
                    get: { threatShield.isEnabled },
                    set: { _ in threatShield.toggle() }
                ))
            }
            .padding(20)
        }
    }

    // MARK: - Stats Overview
    private var statsOverview: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 12) {
                HStack {
                    Text("Всего заблокировано")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }

                Text("\(threatShield.totalBlocked)")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.v2xGreen, .v2xCyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .contentTransition(.numericText(value: threatShield.totalBlocked))

                HStack(spacing: 16) {
                    miniStat(value: "\(threatShield.trackersBlocked)", label: "Трекеры", color: .v2xPurple)
                    miniStat(value: "\(threatShield.adsBlocked)", label: "Реклама", color: .v2xYellow)
                    miniStat(value: "\(threatShield.malwareBlocked)", label: "Malware", color: .v2xRed)
                    miniStat(value: "\(threatShield.phishingBlocked)", label: "Фишинг", color: .v2xOrange)
                }
            }
            .padding(16)
        }
    }

    private func miniStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.v2xTextTertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Threat Breakdown
    private var threatBreakdown: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 12) {
                HStack {
                    Text("Анализ угроз")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }

                ForEach(ThreatEvent.ThreatType.allCases, id: \.self) { type in
                    let count = threatCountFor(type)
                    let total = max(threatShield.totalBlocked, 1)
                    let progress = Double(count) / Double(total)

                    HStack(spacing: 10) {
                        Image(systemName: type.icon)
                            .font(.system(size: 14))
                            .foregroundColor(type.color)
                            .frame(width: 24)

                        Text(type.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 80, alignment: .leading)

                        LiquidGlassProgressBar(progress: progress, color: type.color, height: 4)

                        Text("\(count)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(type.color)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
            .padding(16)
        }
    }

    private func threatCountFor(_ type: ThreatEvent.ThreatType) -> Int {
        switch type {
        case .tracker: return threatShield.trackersBlocked
        case .ad: return threatShield.adsBlocked
        case .malware: return threatShield.malwareBlocked
        case .phishing: return threatShield.phishingBlocked
        case .crypto: return Int(Double(threatShield.malwareBlocked) * 0.3)
        case .fingerprint: return Int(Double(threatShield.trackersBlocked) * 0.4)
        }
    }

    // MARK: - Recent Events
    private var recentEventsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Последние события")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.v2xTextTertiary)
                    .textCase(.uppercase)
                Spacer()
                GlowingDot(color: .v2xGreen, size: 6, isActive: threatShield.isEnabled)
                Text("LIVE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.v2xGreen)
            }
            .padding(.leading, 4)

            GlassSectionCard {
                ForEach(Array(threatShield.recentEvents.prefix(10).enumerated()), id: \.element.id) { index, event in
                    threatEventRow(event)

                    if index < min(threatShield.recentEvents.count, 10) - 1 {
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 44)
                    }
                }
            }
        }
    }

    private func threatEventRow(_ event: ThreatEvent) -> some View {
        HStack(spacing: 10) {
            Image(systemName: event.type.icon)
                .font(.system(size: 14))
                .foregroundColor(event.type.color)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 7)
                        .fill(event.type.color.opacity(0.1))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(event.domain)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Text(event.type.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(event.type.color)

                    Text("•")
                        .foregroundColor(.v2xTextTertiary)

                    Text(event.severity.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(event.severity.color)
                }
            }

            Spacer()

            Text(event.timestamp, style: .time)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.v2xTextTertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Shield Settings
    private var shieldSettings: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Настройки щита")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            GlassSectionCard {
                SettingsToggleRow(
                    icon: "eye.slash.fill",
                    iconColor: .v2xPurple,
                    title: "Блокировка трекеров",
                    isOn: .constant(true)
                )

                Divider().background(Color.white.opacity(0.06)).padding(.leading, 56)

                SettingsToggleRow(
                    icon: "xmark.rectangle.fill",
                    iconColor: .v2xYellow,
                    title: "Блокировка рекламы",
                    isOn: .constant(true)
                )

                Divider().background(Color.white.opacity(0.06)).padding(.leading, 56)

                SettingsToggleRow(
                    icon: "ladybug.fill",
                    iconColor: .v2xRed,
                    title: "Защита от malware",
                    isOn: .constant(true)
                )

                Divider().background(Color.white.opacity(0.06)).padding(.leading, 56)

                SettingsToggleRow(
                    icon: "exclamationmark.shield.fill",
                    iconColor: .v2xOrange,
                    title: "Защита от фишинга",
                    isOn: .constant(true)
                )

                Divider().background(Color.white.opacity(0.06)).padding(.leading, 56)

                SettingsToggleRow(
                    icon: "hand.raised.fill",
                    iconColor: .v2xGreen,
                    title: "Защита от fingerprinting",
                    isOn: .constant(true)
                )
            }
        }
    }
}
