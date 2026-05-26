// LiquidGlassButton.swift
// V2X

import SwiftUI

struct LiquidGlassButton: View {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void

    @State private var isPressed = false
    @State private var rippleScale: CGFloat = 0

    init(
        _ title: String,
        icon: String? = nil,
        color: Color = .v2xCyan,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                rippleScale = 1.5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                rippleScale = 0
            }
            HapticManager.shared.triggerImpact(.light)
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
            }
            .foregroundColor(color)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.12))

                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.15),
                                    color.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Ripple effect
                    Circle()
                        .fill(color.opacity(0.15))
                        .scaleEffect(rippleScale)
                        .opacity(rippleScale > 0 ? 0 : 0)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(color.opacity(0.3), lineWidth: 0.5)
            )
        }
        .buttonStyle(LiquidPressButtonStyle())
    }
}

// MARK: - Large Connection Button
struct LargeConnectionButton: View {
    @EnvironmentObject var vpnManager: VPNManager
    @EnvironmentObject var themeManager: ThemeManager
    let size: CGFloat

    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.3
    @State private var rotation: Double = 0
    @State private var innerRotation: Double = 0

    init(size: CGFloat = 140) {
        self.size = size
    }

    var body: some View {
        Button {
            HapticManager.shared.triggerPattern(
                vpnManager.connectionState == .connected ? .disconnection : .connection
            )
            vpnManager.toggle()
        } label: {
            ZStack {
                // Outer glow rings
                if vpnManager.connectionState == .connected {
                    ForEach(0..<3, id: \.self) { ring in
                        Circle()
                            .stroke(
                                buttonColor.opacity(0.15 - Double(ring) * 0.04),
                                lineWidth: 1
                            )
                            .frame(
                                width: size + CGFloat(ring) * 30 + (pulseScale - 1) * 20,
                                height: size + CGFloat(ring) * 30 + (pulseScale - 1) * 20
                            )
                            .scaleEffect(pulseScale)
                    }
                }

                // Animated gradient ring
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: vpnManager.connectionState == .connected
                                ? [buttonColor, buttonColor.opacity(0.3), buttonColor]
                                : [Color.gray.opacity(0.3), Color.gray.opacity(0.1), Color.gray.opacity(0.3)],
                            center: .center,
                            startAngle: .degrees(rotation),
                            endAngle: .degrees(rotation + 360)
                        ),
                        lineWidth: 2
                    )
                    .frame(width: size + 8, height: size + 8)

                // Main button circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                buttonColor.opacity(vpnManager.connectionState == .connected ? 0.35 : 0.15),
                                buttonColor.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: size / 2
                        )
                    )
                    .frame(width: size, height: size)

                // Glass fill
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.02),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)

                // Border
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                buttonColor.opacity(0.5),
                                buttonColor.opacity(0.15),
                                buttonColor.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: size, height: size)

                // Icon
                Image(systemName: vpnManager.connectionState.icon)
                    .font(.system(size: size * 0.28, weight: .bold))
                    .foregroundColor(buttonColor)
                    .rotationEffect(
                        vpnManager.connectionState.isTransitioning
                            ? .degrees(innerRotation) : .zero
                    )
                    .shadow(color: buttonColor.opacity(0.5), radius: 10)
            }
            .shadow(color: buttonColor.opacity(0.4), radius: vpnManager.connectionState == .connected ? 25 : 10)
        }
        .buttonStyle(LiquidPressButtonStyle())
        .onAppear {
            withAnimation(.v2xPulse) {
                pulseScale = 1.08
            }
            withAnimation(.v2xSpin) {
                rotation = 360
            }
        }
        .onChange(of: vpnManager.connectionState) { newState in
            if newState.isTransitioning {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    innerRotation = 360
                }
            } else {
                innerRotation = 0
            }
        }
    }

    private var buttonColor: Color {
        vpnManager.connectionState.color
    }
}

// MARK: - Copy Button
struct CopyButton: View {
    let text: String
    @State private var isCopied = false

    var body: some View {
        Button {
            UIPasteboard.general.string = text
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isCopied = true
            }
            HapticManager.shared.triggerImpact(.light)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    isCopied = false
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 12, weight: .medium))
                Text(isCopied ? "Скопировано" : "Копировать")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundColor(isCopied ? .v2xGreen : .v2xCyan)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill((isCopied ? Color.v2xGreen : Color.v2xCyan).opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                (isCopied ? Color.v2xGreen : Color.v2xCyan).opacity(0.25),
                                lineWidth: 0.5
                            )
                    )
            )
        }
        .buttonStyle(LiquidPressButtonStyle())
    }
}

// MARK: - Icon Button
struct GlassIconButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void

    init(_ icon: String, color: Color = .v2xCyan, size: CGFloat = 44, action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticManager.shared.triggerImpact(.light)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(color.opacity(0.12))
                        .overlay(
                            Circle()
                                .stroke(color.opacity(0.2), lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(LiquidPressButtonStyle())
    }
}
