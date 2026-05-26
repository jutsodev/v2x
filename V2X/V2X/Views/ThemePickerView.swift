// ThemePickerView.swift
// V2X

import SwiftUI

struct ThemePickerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Current Theme Preview
                    currentThemeCard

                    // Theme Grid
                    themeGrid

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
                    Text("Mood Liquid Themes")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var currentThemeCard: some View {
        LiquidGlassCard(cornerRadius: 24, glowColor: themeManager.currentTheme.accentColor, glowRadius: 10) {
            VStack(spacing: 16) {
                // Preview gradient
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.currentTheme.previewGradient)
                    .frame(height: 80)
                    .overlay(
                        HStack {
                            Image(systemName: themeManager.currentTheme.icon)
                                .font(.system(size: 28))
                                .foregroundColor(.white)

                            VStack(alignment: .leading) {
                                Text(themeManager.currentTheme.displayName)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)

                                Text("Активная тема")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }

                            Spacer()
                        }
                        .padding(16)
                    )

                // Color swatches
                HStack(spacing: 8) {
                    ForEach(themeManager.currentTheme.gradientColors, id: \.self) { color in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(color)
                                .frame(height: 30)
                                .shadow(color: color.opacity(0.4), radius: 4)

                            Text(colorName(color))
                                .font(.system(size: 9))
                                .foregroundColor(.v2xTextTertiary)
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    private var themeGrid: some View {
        VStack(spacing: 12) {
            ForEach(MoodTheme.allCases) { theme in
                themeCard(theme)
            }
        }
    }

    private func themeCard(_ theme: MoodTheme) -> some View {
        Button {
            themeManager.setTheme(theme)
        } label: {
            HStack(spacing: 14) {
                // Theme preview circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: theme.gradientColors.prefix(2).map { $0 },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: theme.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    Text(themeDescription(theme))
                        .font(.system(size: 12))
                        .foregroundColor(.v2xTextTertiary)
                        .lineLimit(1)
                }

                Spacer()

                // Color dots
                HStack(spacing: 3) {
                    ForEach(theme.gradientColors.prefix(3), id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)
                    }
                }

                if themeManager.selectedTheme == theme {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(theme.accentColor)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.cardBackground.opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                themeManager.selectedTheme == theme
                                    ? theme.accentColor.opacity(0.4)
                                    : Color.white.opacity(0.06),
                                lineWidth: themeManager.selectedTheme == theme ? 1.5 : 0.5
                            )
                    )
            )
            .shadow(
                color: themeManager.selectedTheme == theme ? theme.accentColor.opacity(0.2) : Color.clear,
                radius: 8
            )
        }
        .buttonStyle(LiquidPressButtonStyle())
    }

    private func themeDescription(_ theme: MoodTheme) -> String {
        switch theme {
        case .ice: return "Холодный ледяной стиль с бирюзовыми акцентами"
        case .neon: return "Яркий неоновый стиль с зелёными акцентами"
        case .cyberpunk: return "Футуристичный киберпанк с фиолетовыми тонами"
        case .obsidian: return "Элегантный минималистичный стиль"
        case .blood: return "Агрессивный стиль с красными акцентами"
        }
    }

    private func colorName(_ color: Color) -> String {
        "Accent"
    }
}
