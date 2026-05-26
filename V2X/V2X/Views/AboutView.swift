// AboutView.swift
// V2X

import SwiftUI

struct AboutView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Logo
                    VStack(spacing: 16) {
                        ZStack {
                            ForEach(0..<3, id: \.self) { ring in
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: themeManager.currentTheme.gradientColors,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                                    .frame(width: 90 + CGFloat(ring) * 20, height: 90 + CGFloat(ring) * 20)
                                    .opacity(0.3 - Double(ring) * 0.08)
                            }

                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            themeManager.currentTheme.accentColor.opacity(0.3),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 50
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Text("V2X")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(themeManager.currentTheme.previewGradient)
                        }
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .onAppear {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                                logoScale = 1.0
                                logoOpacity = 1.0
                            }
                        }

                        Text("V2X")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Твой неубиваемый туннель в свободный интернет")
                            .font(.system(size: 13))
                            .foregroundColor(.v2xTextTertiary)
                            .multilineTextAlignment(.center)

                        Text("v1.0.0 (Build 1)")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.v2xTextTertiary)
                    }
                    .padding(.top, 20)

                    // Features
                    settingsSection(title: "Уникальные возможности") {
                        featureRow(icon: "brain.head.profile", color: .v2xCyan, title: "AI Smart Connect", subtitle: "Нейросеть выбирает лучший сервер")
                        sectionDivider
                        featureRow(icon: "bolt.shield.fill", color: .v2xPurple, title: "Quantum Stealth Mode", subtitle: "Тройная обфускация + quantum-resistant")
                        sectionDivider
                        featureRow(icon: "waveform.path.ecg", color: .v2xGreen, title: "V2X Pulse", subtitle: "Живые пульсирующие частицы трафика")
                        sectionDivider
                        featureRow(icon: "shield.checkered", color: .v2xYellow, title: "Live Threat Shield", subtitle: "Блокировка трекеров, рекламы, malware")
                        sectionDivider
                        featureRow(icon: "paintpalette.fill", color: .v2xOrange, title: "Mood Liquid Themes", subtitle: "Ice, Neon, Cyberpunk, Obsidian, Blood")
                        sectionDivider
                        featureRow(icon: "iphone.radiowaves.left.and.right", color: .v2xRed, title: "Shake to Disconnect", subtitle: "Потряси телефон — мгновенное отключение")
                        sectionDivider
                        featureRow(icon: "hand.tap.fill", color: .v2xBlue, title: "One-Tap Import", subtitle: "Поддержка всех VPN-протоколов")
                    }

                    // Links
                    settingsSection(title: "Ссылки") {
                        linkRow(icon: "paperplane.fill", title: "Telegram", value: "t.me/kreadwrite", color: .v2xCyan)
                        sectionDivider
                        linkRow(icon: "megaphone.fill", title: "Канал", value: "@kreadwriteQ", color: .v2xPurple)
                    }

                    // Tech Info
                    settingsSection(title: "Технические данные") {
                        infoRow(label: "Платформа", value: "iOS 17+")
                        sectionDivider
                        infoRow(label: "Фреймворк", value: "SwiftUI")
                        sectionDivider
                        infoRow(label: "Протоколы", value: "VLESS, Trojan, VMess, Hysteria2, TUIC, SS, WG")
                        sectionDivider
                        infoRow(label: "Шифрование", value: "AES-256-GCM, ChaCha20")
                        sectionDivider
                        infoRow(label: "Дизайн", value: "Liquid Glassmorphism")
                    }

                    Text("© 2025 V2X Team. All rights reserved.")
                        .font(.system(size: 11))
                        .foregroundColor(.v2xTextTertiary)
                        .padding(.top, 8)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
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
                    Text("О приложении")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.v2xTextTertiary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func linkRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)))

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(color)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.v2xTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 12))
                .foregroundColor(.v2xTextTertiary)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
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
