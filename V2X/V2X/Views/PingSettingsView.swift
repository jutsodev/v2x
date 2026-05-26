// PingSettingsView.swift
// V2X

import SwiftUI

struct PingSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var profileManager: ProfileManager
    @Environment(\.dismiss) private var dismiss

    @State private var pingInterval: Double = 30
    @State private var pingTimeout: Double = 5
    @State private var autoPing = true
    @State private var showPingOnProfile = true
    @State private var pingOnConnect = true
    @State private var isPinging = false
    @State private var pingResults: [(String, Int)] = []

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Quick Ping
                    quickPingCard

                    // Settings
                    settingsSection(title: "Настройки пинга") {
                        SettingsToggleRow(
                            icon: "arrow.clockwise",
                            iconColor: .v2xCyan,
                            title: "Автоматический пинг",
                            subtitle: "Периодически проверять доступность серверов",
                            isOn: $autoPing
                        )

                        sectionDivider

                        SettingsToggleRow(
                            icon: "eye",
                            iconColor: .v2xGreen,
                            title: "Показывать пинг в профилях",
                            isOn: $showPingOnProfile
                        )

                        sectionDivider

                        SettingsToggleRow(
                            icon: "bolt.fill",
                            iconColor: .v2xYellow,
                            title: "Пинг при подключении",
                            subtitle: "Проверять пинг перед подключением",
                            isOn: $pingOnConnect
                        )
                    }

                    // Interval
                    settingsSection(title: "Интервал") {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Интервал пинга")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(Int(pingInterval))с")
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.v2xCyan)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 10)

                            Slider(value: $pingInterval, in: 10...120, step: 5)
                                .tint(.v2xCyan)
                                .padding(.horizontal, 16)

                            HStack {
                                Text("Таймаут")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(Int(pingTimeout))с")
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.v2xCyan)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 4)

                            Slider(value: $pingTimeout, in: 1...30, step: 1)
                                .tint(.v2xPurple)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 12)
                        }
                    }

                    // Results
                    if !pingResults.isEmpty {
                        settingsSection(title: "Результаты") {
                            ForEach(Array(pingResults.enumerated()), id: \.offset) { index, result in
                                HStack(spacing: 12) {
                                    Text(result.0)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("\(result.1) ms")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(result.1 < 50 ? .v2xGreen : result.1 < 100 ? .v2xYellow : .v2xRed)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)

                                if index < pingResults.count - 1 {
                                    Divider()
                                        .background(Color.white.opacity(0.06))
                                        .padding(.leading, 16)
                                }
                            }
                        }
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
                    Text("Пинг")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var quickPingCard: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 14) {
                HStack {
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 18))
                        .foregroundColor(.v2xCyan)
                    Text("Быстрый пинг")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }

                Button {
                    runPingAll()
                } label: {
                    HStack(spacing: 8) {
                        if isPinging {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 14))
                        }
                        Text(isPinging ? "Пингуем..." : "Пинг всех серверов")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
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
                .disabled(isPinging)
            }
            .padding(16)
        }
    }

    private func runPingAll() {
        isPinging = true
        pingResults.removeAll()

        let profiles = profileManager.profiles
        var results: [(String, Int)] = []

        for (index, profile) in profiles.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.3) {
                let ping = Int.random(in: 15...250)
                results.append((profile.name, ping))
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    pingResults = results.sorted { $0.1 < $1.1 }
                }

                if index == profiles.count - 1 {
                    isPinging = false
                    HapticManager.shared.triggerNotification(.success)
                }
            }
        }

        if profiles.isEmpty {
            isPinging = false
        }
    }

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)
            GlassSectionCard { content() }
        }
    }

    private var sectionDivider: some View {
        Divider().background(Color.white.opacity(0.06)).padding(.leading, 56)
    }
}
