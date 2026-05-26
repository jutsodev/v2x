// CommunityView.swift
// V2X

import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Hero Card
                    LiquidGlassCard(cornerRadius: 24, glowColor: .v2xCyan, glowRadius: 10) {
                        VStack(spacing: 16) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.v2xCyan, .v2xPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                            Text("V2X Комьюнити")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)

                            Text("Присоединяйся к сообществу V2X.\nНовости, обновления, поддержка.")
                                .font(.system(size: 13))
                                .foregroundColor(.v2xTextTertiary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                    }

                    // Telegram
                    communityCard(
                        icon: "paperplane.fill",
                        color: .v2xCyan,
                        title: "Telegram",
                        subtitle: "Основной канал поддержки",
                        link: "t.me/kreadwrite"
                    )

                    communityCard(
                        icon: "megaphone.fill",
                        color: .v2xPurple,
                        title: "Канал обновлений",
                        subtitle: "Все обновления и новости",
                        link: "@kreadwriteQ"
                    )

                    // How to connect
                    settingsSection(title: "Как подключиться?") {
                        stepRow(number: 1, title: "Получите конфигурацию", description: "Получите ссылку vless://, trojan:// или другой протокол от провайдера VPN")
                        sectionDivider
                        stepRow(number: 2, title: "Импортируйте в V2X", description: "Вставьте ссылку в 'Добавить конфигурацию' или используйте One-Tap Import")
                        sectionDivider
                        stepRow(number: 3, title: "Подключитесь", description: "Нажмите кнопку подключения. AI Smart Connect выберет лучший сервер автоматически")
                    }

                    // Support
                    LiquidGlassCard(cornerRadius: 16) {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.v2xRed)
                                Text("Поддержать разработчиков")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                            }

                            Text("V2X — бесплатное приложение. Если вам нравится наша работа, вы можете поддержать развитие проекта.")
                                .font(.system(size: 12))
                                .foregroundColor(.v2xTextTertiary)
                                .lineSpacing(2)
                        }
                        .padding(14)
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
                    Text("Комьюнити")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func communityCard(icon: String, color: Color, title: String, subtitle: String, link: String) -> some View {
        LiquidGlassCard(cornerRadius: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.v2xTextTertiary)
                }

                Spacer()

                Text(link)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(color)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(color)
            }
            .padding(14)
        }
    }

    private func stepRow(number: Int, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.v2xCyan.opacity(0.15))
                    .frame(width: 28, height: 28)
                Text("\(number)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.v2xCyan)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.v2xTextTertiary)
                    .lineSpacing(2)
            }

            Spacer()
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
