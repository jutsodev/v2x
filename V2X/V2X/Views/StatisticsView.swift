// StatisticsView.swift
// V2X

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var statsTracker: StatsTracker
    @EnvironmentObject var vpnManager: VPNManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Live Traffic Graph
                    liveTrafficCard

                    // Session Stats
                    sessionStatsCard

                    // All Time Stats
                    allTimeStatsCard

                    // Daily Breakdown
                    dailyBreakdownSection

                    // Speed Records
                    speedRecordsCard

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
                    Text("Статистика")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Live Traffic Card
    private var liveTrafficCard: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.xyaxis.line")
                            .font(.system(size: 14))
                            .foregroundColor(.v2xCyan)
                        Text("Живой трафик")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    if vpnManager.connectionState == .connected {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.v2xGreen)
                                .frame(width: 6, height: 6)
                            Text("LIVE")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.v2xGreen)
                        }
                    }
                }

                TrafficGraph(height: 150, showLabels: true)
            }
            .padding(16)
        }
    }

    // MARK: - Session Stats
    private var sessionStatsCard: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 14) {
                HStack {
                    Text("Текущая сессия")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    CompactConnectionTimer()
                }

                HStack(spacing: 12) {
                    statBlock(
                        icon: "arrow.up",
                        label: "Upload",
                        value: String.formatBytes(vpnManager.stats.sessionUpload),
                        color: .v2xPurple
                    )
                    statBlock(
                        icon: "arrow.down",
                        label: "Download",
                        value: String.formatBytes(vpnManager.stats.sessionDownload),
                        color: .v2xCyan
                    )
                }

                HStack(spacing: 12) {
                    statBlock(
                        icon: "arrow.up.circle",
                        label: "Скорость ↑",
                        value: vpnManager.stats.formattedUploadSpeed,
                        color: .v2xPurple
                    )
                    statBlock(
                        icon: "arrow.down.circle",
                        label: "Скорость ↓",
                        value: vpnManager.stats.formattedDownloadSpeed,
                        color: .v2xCyan
                    )
                }
            }
            .padding(16)
        }
    }

    // MARK: - All Time Stats
    private var allTimeStatsCard: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 14) {
                HStack {
                    Text("За всё время")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }

                HStack(spacing: 12) {
                    statBlock(
                        icon: "arrow.up.arrow.down",
                        label: "Upload",
                        value: String.formatBytes(statsTracker.totalAllTimeUpload),
                        color: .v2xPurple
                    )
                    statBlock(
                        icon: "arrow.down.circle.fill",
                        label: "Download",
                        value: String.formatBytes(statsTracker.totalAllTimeDownload),
                        color: .v2xCyan
                    )
                }

                HStack(spacing: 12) {
                    statBlock(
                        icon: "number",
                        label: "Сессий",
                        value: "\(statsTracker.totalSessions)",
                        color: .v2xYellow
                    )
                    statBlock(
                        icon: "clock",
                        label: "Среднее время",
                        value: String.formatDuration(statsTracker.averageSessionDuration),
                        color: .v2xGreen
                    )
                }
            }
            .padding(16)
        }
    }

    // MARK: - Daily Breakdown
    private var dailyBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("По дням")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            GlassSectionCard {
                ForEach(Array(statsTracker.dailyStats.enumerated()), id: \.element.id) { index, stat in
                    dailyStatRow(stat)

                    if index < statsTracker.dailyStats.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 16)
                    }
                }
            }
        }
    }

    private func dailyStatRow(_ stat: StatsTracker.DailyStat) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(stat.date, style: .date)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)

                Text("\(stat.sessions) сессий • \(String.formatDuration(stat.duration))")
                    .font(.system(size: 11))
                    .foregroundColor(.v2xTextTertiary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("↑ " + String.formatBytes(stat.upload))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.v2xPurple)

                Text("↓ " + String.formatBytes(stat.download))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.v2xCyan)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Speed Records
    private var speedRecordsCard: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 12) {
                HStack {
                    Text("Рекорды скорости")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }

                HStack(spacing: 12) {
                    statBlock(
                        icon: "flame.fill",
                        label: "Max Download",
                        value: String.formatSpeed(statsTracker.maxDownloadSpeed),
                        color: .v2xCyan
                    )
                    statBlock(
                        icon: "flame.fill",
                        label: "Max Upload",
                        value: String.formatSpeed(statsTracker.maxUploadSpeed),
                        color: .v2xPurple
                    )
                }
            }
            .padding(16)
        }
    }

    // MARK: - Stat Block
    private func statBlock(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.v2xTextTertiary)
            }

            Text(value)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .liquidGlassBackground(cornerRadius: 12)
    }
}
