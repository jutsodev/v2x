// LiquidGlassToggle.swift
// V2X

import SwiftUI

struct LiquidGlassToggle: View {
    @Binding var isOn: Bool
    var onColor: Color = .v2xGreen
    var offColor: Color = Color(hex: "333333")

    @State private var thumbOffset: CGFloat = 0

    private let width: CGFloat = 52
    private let height: CGFloat = 31
    private let thumbSize: CGFloat = 27
    private let padding: CGFloat = 2

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                isOn.toggle()
            }
            HapticManager.shared.triggerPattern(.toggle)
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                // Track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        isOn
                            ? LinearGradient(
                                colors: [onColor, onColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                              )
                            : LinearGradient(
                                colors: [offColor, offColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                              )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: height / 2)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isOn ? 0.2 : 0.05),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: height / 2)
                            .stroke(
                                isOn ? onColor.opacity(0.4) : Color.white.opacity(0.08),
                                lineWidth: 0.5
                            )
                    )
                    .frame(width: width, height: height)

                // Thumb
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white, Color(hex: "E8E8E8")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.4),
                                        Color.clear
                                    ],
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: thumbSize
                                )
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
                    .shadow(color: isOn ? onColor.opacity(0.3) : Color.clear, radius: 6)
                    .frame(width: thumbSize, height: thumbSize)
                    .padding(padding)
            }
        }
        .buttonStyle(.plain)
        .if(isOn) { view in
            view.shadow(color: onColor.opacity(0.3), radius: 8)
        }
    }
}

// MARK: - Settings Row with Toggle
struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool

    init(
        icon: String,
        iconColor: Color = .v2xCyan,
        title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self._isOn = isOn
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.v2xTextTertiary)
                }
            }

            Spacer()

            LiquidGlassToggle(isOn: $isOn)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

// MARK: - Settings Navigation Row
struct SettingsNavRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let value: String?

    init(
        icon: String,
        iconColor: Color = .v2xCyan,
        title: String,
        subtitle: String? = nil,
        value: String? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.value = value
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.v2xTextTertiary)
                }
            }

            Spacer()

            if let value = value {
                Text(value)
                    .font(.system(size: 13))
                    .foregroundColor(.v2xTextTertiary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

// MARK: - Settings Action Row
struct SettingsActionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let action: () -> Void

    init(
        icon: String,
        iconColor: Color = .v2xCyan,
        title: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.triggerImpact(.light)
            action()
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(iconColor.opacity(0.12))
                    )

                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.v2xTextTertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(LiquidPressButtonStyle())
    }
}
