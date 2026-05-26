// View+LiquidGlass.swift
// V2X

import SwiftUI

// MARK: - Liquid Glass Modifiers
extension View {
    func liquidGlassCard(cornerRadius: CGFloat = 20, borderWidth: CGFloat = 0.5) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(V2XGradients.glassInner)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(V2XGradients.glassBorder, lineWidth: borderWidth)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 15, y: 5)
    }

    func liquidGlassBackground(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(hex: "111111").opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.05),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.white.opacity(0.03),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
    }

    func neonGlow(color: Color, radius: CGFloat = 15) -> some View {
        self
            .shadow(color: color.opacity(0.6), radius: radius / 2)
            .shadow(color: color.opacity(0.3), radius: radius)
            .shadow(color: color.opacity(0.1), radius: radius * 2)
    }

    func liquidRipple(isPressed: Bool, color: Color = .white) -> some View {
        self.overlay(
            Circle()
                .fill(color.opacity(isPressed ? 0.15 : 0))
                .scaleEffect(isPressed ? 2.5 : 0.1)
                .animation(.easeOut(duration: 0.4), value: isPressed)
                .allowsHitTesting(false)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    func shimmerEffect(isActive: Bool = true) -> some View {
        self.overlay(
            GeometryReader { geometry in
                if isActive {
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.5)
                    .rotationEffect(.degrees(20))
                    .offset(x: isActive ? geometry.size.width * 1.5 : -geometry.size.width)
                    .animation(
                        Animation.linear(duration: 2.5).repeatForever(autoreverses: false),
                        value: isActive
                    )
                }
            }
            .allowsHitTesting(false)
        )
        .clipped()
    }

    func floatingAnimation(offset: CGFloat = 6, duration: Double = 3) -> some View {
        self.modifier(FloatingModifier(offset: offset, duration: duration))
    }
}

// MARK: - Floating Animation Modifier
struct FloatingModifier: ViewModifier {
    let offset: CGFloat
    let duration: Double
    @State private var isFloating = false

    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -offset : offset)
            .animation(
                Animation.easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear {
                isFloating = true
            }
    }
}

// MARK: - Animated Border
struct AnimatedBorderModifier: ViewModifier {
    let colors: [Color]
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    @State private var rotation: Double = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        AngularGradient(
                            colors: colors + [colors.first ?? .clear],
                            center: .center,
                            startAngle: .degrees(rotation),
                            endAngle: .degrees(rotation + 360)
                        ),
                        lineWidth: lineWidth
                    )
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 4).repeatForever(autoreverses: false)
                        ) {
                            rotation = 360
                        }
                    }
            )
    }
}

extension View {
    func animatedBorder(
        colors: [Color] = [.v2xCyan, .v2xPurple, .v2xGreen, .v2xCyan],
        cornerRadius: CGFloat = 20,
        lineWidth: CGFloat = 1
    ) -> some View {
        self.modifier(AnimatedBorderModifier(colors: colors, cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
}

// MARK: - Conditional Modifier
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
