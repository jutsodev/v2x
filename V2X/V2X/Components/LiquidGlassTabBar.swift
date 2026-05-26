// LiquidGlassTabBar.swift
// V2X

import SwiftUI

struct LiquidGlassTabBar: View {
    @Binding var selectedTab: Int
    let items: [TabBarItem]
    @EnvironmentObject var themeManager: ThemeManager

    @State private var animationOffset: CGFloat = 0
    @State private var indicatorWidth: CGFloat = 60

    struct TabBarItem: Identifiable {
        let id: Int
        let icon: String
        let activeIcon: String
        let title: String
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                tabButton(item)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(tabBarBackground)
        .padding(.horizontal, 40)
        .padding(.bottom, 8)
    }

    private func tabButton(_ item: TabBarItem) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = item.id
            }
            HapticManager.shared.triggerImpact(.light)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: selectedTab == item.id ? item.activeIcon : item.icon)
                    .font(.system(size: 20, weight: selectedTab == item.id ? .semibold : .regular))
                    .foregroundColor(selectedTab == item.id ? themeManager.currentTheme.accentColor : .v2xTextTertiary)
                    .scaleEffect(selectedTab == item.id ? 1.1 : 1.0)

                Text(item.title)
                    .font(.system(size: 10, weight: selectedTab == item.id ? .semibold : .regular))
                    .foregroundColor(selectedTab == item.id ? themeManager.currentTheme.accentColor : .v2xTextTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                selectedTab == item.id
                    ? RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.currentTheme.accentColor.opacity(0.08))
                        .transition(.scale.combined(with: .opacity))
                    : nil
            )
        }
        .buttonStyle(.plain)
    }

    private var tabBarBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                themeManager.currentTheme.accentColor.opacity(0.15),
                                Color.white.opacity(0.05),
                                themeManager.currentTheme.secondaryAccent.opacity(0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 10, y: 5)
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticManager.shared.triggerImpact(.medium)
            action()
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: color.opacity(0.4), radius: 10, y: 5)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Notification Banner
struct NotificationBanner: View {
    let message: String
    let type: BannerType
    var icon: String?

    enum BannerType {
        case success, error, warning, info

        var color: Color {
            switch self {
            case .success: return .v2xGreen
            case .error: return .v2xRed
            case .warning: return .v2xYellow
            case .info: return .v2xCyan
            }
        }

        var defaultIcon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon ?? type.defaultIcon)
                .font(.system(size: 18))
                .foregroundColor(type.color)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(type.color.opacity(0.3), lineWidth: 0.5)
                )
        )
        .shadow(color: type.color.opacity(0.2), radius: 8, y: 4)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var buttonTitle: String?
    var buttonAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundColor(.v2xTextTertiary)
                .padding(.bottom, 8)

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.v2xTextSecondary)

            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(.v2xTextTertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            if let buttonTitle = buttonTitle, let action = buttonAction {
                LiquidGlassButton(buttonTitle, icon: "plus.circle.fill", action: action)
                    .padding(.top, 8)
            }
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
    }
}

// MARK: - Loading View
struct V2XLoadingView: View {
    let message: String

    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0.8

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.v2xCyan.opacity(0.15), lineWidth: 3)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(Color.v2xCyan, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(rotation))
            }
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.0
                }
            }

            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.v2xTextTertiary)
        }
    }
}
