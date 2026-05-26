// Color+Theme.swift
// V2X

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - V2X Design System Colors
extension Color {
    static let v2xCyan = Color(hex: "00F5FF")
    static let v2xPurple = Color(hex: "B026FF")
    static let v2xGreen = Color(hex: "00FF9D")
    static let v2xYellow = Color(hex: "FFD93D")
    static let v2xRed = Color(hex: "FF4444")
    static let v2xOrange = Color(hex: "FF6B6B")
    static let v2xBlue = Color(hex: "4D96FF")

    static let v2xBackground = Color(hex: "050505")
    static let v2xSurface = Color(hex: "0A0A0A")
    static let v2xCard = Color(hex: "111111")
    static let v2xCardLight = Color(hex: "1A1A1A")
    static let v2xCardBorder = Color.white.opacity(0.08)

    static let v2xTextPrimary = Color.white
    static let v2xTextSecondary = Color.white.opacity(0.7)
    static let v2xTextTertiary = Color.white.opacity(0.4)

    static func v2xGradient(from: String, to: String) -> LinearGradient {
        LinearGradient(
            colors: [Color(hex: from), Color(hex: to)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Gradient Presets
struct V2XGradients {
    static let primary = LinearGradient(
        colors: [.v2xCyan, .v2xPurple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let success = LinearGradient(
        colors: [Color(hex: "00FF9D"), Color(hex: "00D68F")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let danger = LinearGradient(
        colors: [Color(hex: "FF4444"), Color(hex: "FF6B6B")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warning = LinearGradient(
        colors: [Color(hex: "FFD93D"), Color(hex: "FF9500")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let neon = LinearGradient(
        colors: [.v2xCyan, .v2xGreen, .v2xPurple],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let glassBorder = LinearGradient(
        colors: [
            Color.white.opacity(0.25),
            Color.white.opacity(0.05),
            Color.white.opacity(0.15)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let glassInner = LinearGradient(
        colors: [
            Color.white.opacity(0.08),
            Color.white.opacity(0.02),
            Color.clear
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let darkCard = LinearGradient(
        colors: [
            Color(hex: "1A1A1A"),
            Color(hex: "111111")
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}
