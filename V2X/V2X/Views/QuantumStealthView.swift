// QuantumStealthView.swift
// V2X

import SwiftUI

struct QuantumStealthView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var obfuscationLevel: Double = 3
    @State private var quantumResistant = true
    @State private var tripleObfuscation = true
    @State private var tlsFingerprint = "Chrome 120"
    @State private var headerPadding = true
    @State private var fragmentSize: Int = 100
    @State private var showShield = false

    let fingerprints = ["Chrome 120", "Firefox 121", "Safari 17", "Edge 120", "Random"]

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Shield Status
                    shieldStatusCard

                    // Obfuscation Level
                    obfuscationCard

                    // Security Settings
                    settingsSection(title: "Безопасность") {
                        SettingsToggleRow(
                            icon: "lock.shield.fill",
                            iconColor: .v2xPurple,
                            title: "Quantum-resistant шифрование",
                            subtitle: "Защита от квантовых компьютеров",
                            isOn: $quantumResistant
                        )

                        sectionDivider

                        SettingsToggleRow(
                            icon: "shield.lefthalf.filled.trianglebadge.exclamationmark",
                            iconColor: .v2xCyan,
                            title: "Тройная обфускация",
                            subtitle: "3 слоя шифрования трафика",
                            isOn: $tripleObfuscation
                        )

                        sectionDivider

                        SettingsToggleRow(
                            icon: "rectangle.and.hand.point.up.left.fill",
                            iconColor: .v2xGreen,
                            title: "Header Padding",
                            subtitle: "Маскировка размера пакетов",
                            isOn: $headerPadding
                        )
                    }

                    // TLS Fingerprint
                    settingsSection(title: "TLS Fingerprint") {
                        ForEach(fingerprints, id: \.self) { fp in
                            Button {
                                tlsFingerprint = fp
                                HapticManager.shared.triggerImpact(.light)
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: tlsFingerprint == fp ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 18))
                                        .foregroundColor(tlsFingerprint == fp ? .v2xCyan : .gray)

                                    Text(fp)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)

                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(LiquidPressButtonStyle())

                            if fp != fingerprints.last {
                                Divider()
                                    .background(Color.white.opacity(0.06))
                                    .padding(.leading, 48)
                            }
                        }
                    }

                    // Fragment Size
                    settingsSection(title: "Размер фрагмента") {
                        VStack(spacing: 8) {
                            HStack {
                                Text("Fragment Size")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(fragmentSize) bytes")
                                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                    .foregroundColor(.v2xCyan)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 10)

                            Slider(
                                value: Binding(
                                    get: { Double(fragmentSize) },
                                    set: { fragmentSize = Int($0) }
                                ),
                                in: 50...500,
                                step: 10
                            )
                            .tint(.v2xPurple)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 12)
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
                    Text("Quantum Stealth")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var shieldStatusCard: some View {
        LiquidGlassCard(cornerRadius: 24, glowColor: .v2xPurple, glowRadius: 12) {
            VStack(spacing: 16) {
                ZStack {
                    // Animated shield rings
                    ForEach(0..<3, id: \.self) { ring in
                        Circle()
                            .stroke(
                                Color.v2xPurple.opacity(0.15 - Double(ring) * 0.04),
                                lineWidth: 1
                            )
                            .frame(width: 80 + CGFloat(ring) * 25, height: 80 + CGFloat(ring) * 25)
                    }

                    Image(systemName: "bolt.shield.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.v2xPurple, .v2xCyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .v2xPurple.opacity(0.5), radius: 10)
                }
                .frame(height: 140)

                Text("Quantum Stealth Mode")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Text("Тройная обфускация + quantum-resistant шифрование для максимальной невидимости трафика")
                    .font(.system(size: 12))
                    .foregroundColor(.v2xTextTertiary)
                    .multilineTextAlignment(.center)

                LiquidGlassToggle(
                    isOn: $vpnManager.isQuantumStealthEnabled,
                    onColor: .v2xPurple
                )
            }
            .padding(20)
        }
    }

    private var obfuscationCard: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 12) {
                HStack {
                    Text("Уровень обфускации")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("Уровень \(Int(obfuscationLevel))")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.v2xPurple)
                }

                Slider(value: $obfuscationLevel, in: 1...5, step: 1)
                    .tint(.v2xPurple)

                HStack {
                    Text("Базовый")
                        .font(.system(size: 10))
                        .foregroundColor(.v2xTextTertiary)
                    Spacer()
                    Text("Максимальный")
                        .font(.system(size: 10))
                        .foregroundColor(.v2xTextTertiary)
                }

                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                level <= Int(obfuscationLevel)
                                    ? Color.v2xPurple
                                    : Color.white.opacity(0.06)
                            )
                            .frame(height: 6)
                    }
                }
            }
            .padding(16)
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
        Divider()
            .background(Color.white.opacity(0.06))
            .padding(.leading, 56)
    }
}
