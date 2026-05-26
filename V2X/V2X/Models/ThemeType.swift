// ThemeType.swift
// V2X

import SwiftUI

// MARK: - Theme Definition
enum MoodTheme: String, CaseIterable, Codable, Identifiable {
    case ice = "Ice"
    case neon = "Neon"
    case cyberpunk = "Cyberpunk"
    case obsidian = "Obsidian"
    case blood = "Blood"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .ice: return "Ледяной"
        case .neon: return "Неон"
        case .cyberpunk: return "Киберпанк"
        case .obsidian: return "Обсидиан"
        case .blood: return "Кровавый"
        }
    }

    var icon: String {
        switch self {
        case .ice: return "snowflake"
        case .neon: return "light.max"
        case .cyberpunk: return "cpu"
        case .obsidian: return "diamond.fill"
        case .blood: return "drop.fill"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .ice: return Color(hex: "050510")
        case .neon: return Color(hex: "050505")
        case .cyberpunk: return Color(hex: "0A0510")
        case .obsidian: return Color(hex: "0A0A0A")
        case .blood: return Color(hex: "0A0505")
        }
    }

    var cardBackground: Color {
        switch self {
        case .ice: return Color(hex: "111120")
        case .neon: return Color(hex: "111111")
        case .cyberpunk: return Color(hex: "150F1A")
        case .obsidian: return Color(hex: "141414")
        case .blood: return Color(hex: "1A0F0F")
        }
    }

    var accentColor: Color {
        switch self {
        case .ice: return Color(hex: "00F5FF")
        case .neon: return Color(hex: "00FF9D")
        case .cyberpunk: return Color(hex: "B026FF")
        case .obsidian: return Color(hex: "8899AA")
        case .blood: return Color(hex: "FF2244")
        }
    }

    var secondaryAccent: Color {
        switch self {
        case .ice: return Color(hex: "B026FF")
        case .neon: return Color(hex: "00F5FF")
        case .cyberpunk: return Color(hex: "FF0055")
        case .obsidian: return Color(hex: "556677")
        case .blood: return Color(hex: "FF6644")
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .ice: return [Color(hex: "00F5FF"), Color(hex: "0088FF"), Color(hex: "B026FF")]
        case .neon: return [Color(hex: "00FF9D"), Color(hex: "00F5FF"), Color(hex: "B026FF")]
        case .cyberpunk: return [Color(hex: "B026FF"), Color(hex: "FF0055"), Color(hex: "FFD93D")]
        case .obsidian: return [Color(hex: "556677"), Color(hex: "8899AA"), Color(hex: "AABBCC")]
        case .blood: return [Color(hex: "FF2244"), Color(hex: "FF6644"), Color(hex: "FFD93D")]
        }
    }

    var pulseColors: [Color] {
        switch self {
        case .ice: return [Color(hex: "00F5FF"), Color(hex: "0088FF")]
        case .neon: return [Color(hex: "00FF9D"), Color(hex: "00F5FF")]
        case .cyberpunk: return [Color(hex: "B026FF"), Color(hex: "FF0055")]
        case .obsidian: return [Color(hex: "556677"), Color(hex: "8899AA")]
        case .blood: return [Color(hex: "FF2244"), Color(hex: "FF6644")]
        }
    }

    var glowColor: Color {
        accentColor.opacity(0.6)
    }

    var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                accentColor.opacity(0.3),
                secondaryAccent.opacity(0.1),
                accentColor.opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var glassFill: some ShapeStyle {
        LinearGradient(
            colors: [
                Color.white.opacity(0.06),
                Color.white.opacity(0.02),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var previewGradient: LinearGradient {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Theme Properties Bundle
struct ThemeProperties {
    let theme: MoodTheme

    var backgroundColor: Color { theme.backgroundColor }
    var cardBackground: Color { theme.cardBackground }
    var accentColor: Color { theme.accentColor }
    var secondaryAccent: Color { theme.secondaryAccent }
    var gradientColors: [Color] { theme.gradientColors }
    var pulseColors: [Color] { theme.pulseColors }
    var glowColor: Color { theme.glowColor }
    var borderGradient: LinearGradient { theme.borderGradient }
}
