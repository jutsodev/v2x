// LiquidGlassNavBar.swift
// V2X

import SwiftUI

struct LiquidGlassNavBar: View {
    let title: String
    var subtitle: String?
    var leadingAction: (() -> Void)?
    var trailingAction: (() -> Void)?
    var trailingIcon: String?

    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(spacing: 12) {
            if let action = leadingAction {
                Button(action: action) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .liquidGlassBackground(cornerRadius: 10)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.v2xTextTertiary)
                }
            }

            Spacer()

            if let action = trailingAction, let icon = trailingIcon {
                Button(action: action) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.v2xCyan)
                        .frame(width: 36, height: 36)
                        .liquidGlassBackground(cornerRadius: 10)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.8)
                .ignoresSafeArea()
        )
    }
}

struct LiquidGlassSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Поиск..."
    var onClear: (() -> Void)?

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundColor(isFocused ? .v2xCyan : .v2xTextTertiary)
                .animation(.v2xSnappy, value: isFocused)

            TextField(placeholder, text: $text)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    text = ""
                    onClear?()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.v2xTextTertiary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlassBackground(cornerRadius: 14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isFocused ? Color.v2xCyan.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .animation(.v2xSnappy, value: isFocused)
    }
}

struct LiquidGlassSegmentedControl: View {
    let options: [String]
    @Binding var selectedIndex: Int
    var color: Color = .v2xCyan

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                Button {
                    withAnimation(.v2xSnappy) {
                        selectedIndex = index
                    }
                    HapticManager.shared.triggerImpact(.light)
                } label: {
                    Text(option)
                        .font(.system(size: 13, weight: selectedIndex == index ? .semibold : .medium))
                        .foregroundColor(selectedIndex == index ? .white : .v2xTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedIndex == index ? color.opacity(0.2) : Color.clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .liquidGlassBackground(cornerRadius: 13)
    }
}

struct LiquidGlassChip: View {
    let title: String
    var icon: String?
    var color: Color = .v2xCyan
    var isSelected: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: {
            HapticManager.shared.triggerImpact(.light)
            action()
        }) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                }
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : .v2xTextSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.3) : Color.white.opacity(0.05))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? color.opacity(0.4) : Color.clear, lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(LiquidPressButtonStyle())
    }
}

struct LiquidGlassProgressBar: View {
    let progress: Double
    var color: Color = .v2xCyan
    var height: CGFloat = 6
    var showPercentage: Bool = false

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(spacing: 4) {
            if showPercentage {
                HStack {
                    Spacer()
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(color)
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.white.opacity(0.06))

                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.6), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animatedProgress)
                        .shadow(color: color.opacity(0.4), radius: 4)
                }
            }
            .frame(height: height)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeInOut(duration: 0.4)) {
                animatedProgress = newValue
            }
        }
    }
}

struct LiquidGlassAlert: View {
    let title: String
    let message: String
    var icon: String = "exclamationmark.triangle.fill"
    var iconColor: Color = .v2xYellow
    var primaryButtonTitle: String = "OK"
    var secondaryButtonTitle: String?
    var primaryAction: () -> Void
    var secondaryAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(iconColor)

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.v2xTextTertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                if let secondaryTitle = secondaryButtonTitle {
                    Button {
                        secondaryAction?()
                    } label: {
                        Text(secondaryTitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.v2xTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .liquidGlassBackground(cornerRadius: 12)
                    }
                }

                Button(action: primaryAction) {
                    Text(primaryButtonTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(iconColor.opacity(0.3))
                        )
                }
            }
        }
        .padding(24)
        .liquidGlassBackground(cornerRadius: 24)
        .padding(.horizontal, 40)
    }
}

struct AnimatedCounter: View {
    let value: Int
    var font: Font = .system(size: 24, weight: .bold, design: .monospaced)
    var color: Color = .white

    @State private var displayValue: Int = 0
    @State private var timer: Timer?

    var body: some View {
        Text("\(displayValue)")
            .font(font)
            .foregroundColor(color)
            .contentTransition(.numericText(value: displayValue))
            .onAppear {
                animateToValue()
            }
            .onChange(of: value) { _ in
                animateToValue()
            }
    }

    private func animateToValue() {
        timer?.invalidate()
        let steps = 20
        let increment = max((value - displayValue) / steps, 1)
        var current = displayValue

        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { t in
            current += increment
            if current >= value {
                current = value
                t.invalidate()
            }
            withAnimation(.v2xFast) {
                displayValue = current
            }
        }
    }
}

struct GlowingDot: View {
    let color: Color
    var size: CGFloat = 8
    var isActive: Bool = true

    @State private var isPulsing = false

    var body: some View {
        ZStack {
            if isActive {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: size * 2, height: size * 2)
                    .scaleEffect(isPulsing ? 1.5 : 0.8)
                    .opacity(isPulsing ? 0 : 0.5)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isPulsing)
            }

            Circle()
                .fill(color)
                .frame(width: size, height: size)
                .shadow(color: isActive ? color : .clear, radius: 3)
        }
        .onAppear {
            if isActive { isPulsing = true }
        }
    }
}
