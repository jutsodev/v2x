// Animation+Spring.swift
// V2X

import SwiftUI

// MARK: - Custom Spring Animations
extension Animation {
    static let v2xBounce = Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)
    static let v2xSmooth = Animation.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)
    static let v2xSnappy = Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    static let v2xSlow = Animation.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0)
    static let v2xFast = Animation.spring(response: 0.2, dampingFraction: 0.8, blendDuration: 0)

    static let v2xPulse = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    static let v2xGlow = Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)
    static let v2xSpin = Animation.linear(duration: 3.0).repeatForever(autoreverses: false)
    static let v2xFloat = Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)

    static func v2xSpring(response: Double = 0.4, damping: Double = 0.7) -> Animation {
        .spring(response: response, dampingFraction: damping, blendDuration: 0)
    }

    static func v2xDelay(_ delay: Double) -> Animation {
        .spring(response: 0.5, dampingFraction: 0.8).delay(delay)
    }
}

// MARK: - Transition Presets
extension AnyTransition {
    static let v2xSlide = AnyTransition.asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )

    static let v2xFade = AnyTransition.opacity.combined(with: .scale(scale: 0.95))

    static let v2xPop = AnyTransition.scale(scale: 0.8).combined(with: .opacity)

    static let v2xSlideUp = AnyTransition.asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .move(edge: .top).combined(with: .opacity)
    )

    static let v2xBlur = AnyTransition.modifier(
        active: BlurModifier(isActive: true),
        identity: BlurModifier(isActive: false)
    )
}

struct BlurModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .blur(radius: isActive ? 10 : 0)
            .opacity(isActive ? 0 : 1)
    }
}

// MARK: - Button Press Style
struct LiquidPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.v2xFast, value: configuration.isPressed)
    }
}

struct V2XButtonStyle: ButtonStyle {
    var color: Color = .v2xCyan
    var cornerRadius: CGFloat = 14

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(color.opacity(configuration.isPressed ? 0.6 : 0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(color.opacity(0.4), lineWidth: 0.5)
                    )
            )
            .foregroundColor(color)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.v2xFast, value: configuration.isPressed)
    }
}

struct GlassButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 14

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(configuration.isPressed ? 0.12 : 0.06),
                                        Color.white.opacity(0.02)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.v2xFast, value: configuration.isPressed)
    }
}
