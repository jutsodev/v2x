// View+Modifiers.swift
// V2X

import SwiftUI

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

    @ViewBuilder
    func ifLet<T, Content: View>(_ optional: T?, transform: (Self, T) -> Content) -> some View {
        if let value = optional {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - Size Reader
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func readSize(_ size: Binding<CGSize>) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear.preference(key: SizePreferenceKey.self, value: geo.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { newSize in
            size.wrappedValue = newSize
        }
    }
}

// MARK: - Visible
struct VisibleModifier: ViewModifier {
    let isVisible: Bool

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: isVisible)
    }
}

extension View {
    func visible(_ isVisible: Bool) -> some View {
        modifier(VisibleModifier(isVisible: isVisible))
    }
}

// MARK: - Glass Border Modifier
struct GlassBorderModifier: ViewModifier {
    let cornerRadius: CGFloat
    let color: Color
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(0.3),
                                color.opacity(0.1),
                                color.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: lineWidth
                    )
            )
    }
}

extension View {
    func glassBorder(cornerRadius: CGFloat = 16, color: Color = .white, lineWidth: CGFloat = 0.5) -> some View {
        modifier(GlassBorderModifier(cornerRadius: cornerRadius, color: color, lineWidth: lineWidth))
    }
}

// MARK: - Neon Border Modifier
struct NeonBorderModifier: ViewModifier {
    let cornerRadius: CGFloat
    let color: Color
    let intensity: Double

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color.opacity(0.4 * intensity), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.2 * intensity), radius: 4)
            .shadow(color: color.opacity(0.1 * intensity), radius: 8)
    }
}

extension View {
    func neonBorder(cornerRadius: CGFloat = 16, color: Color = .v2xCyan, intensity: Double = 1.0) -> some View {
        modifier(NeonBorderModifier(cornerRadius: cornerRadius, color: color, intensity: intensity))
    }
}

// MARK: - Pulsating Modifier
struct PulsatingModifier: ViewModifier {
    let color: Color
    let isActive: Bool

    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .shadow(color: isActive ? color.opacity(isPulsing ? 0.5 : 0.2) : .clear, radius: isPulsing ? 12 : 4)
            .onAppear {
                if isActive {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                }
            }
            .onChange(of: isActive) { newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPulsing = false
                    }
                }
            }
    }
}

extension View {
    func pulsating(color: Color = .v2xCyan, isActive: Bool = true) -> some View {
        modifier(PulsatingModifier(color: color, isActive: isActive))
    }
}

// MARK: - Slide In Modifier
struct SlideInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func slideIn(delay: Double = 0) -> some View {
        modifier(SlideInModifier(delay: delay))
    }
}

// MARK: - Bounce Tap Modifier
struct BounceTapModifier: ViewModifier {
    @State private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    func bounceTap() -> some View {
        modifier(BounceTapModifier())
    }
}

// MARK: - Parallax Modifier
struct ParallaxModifier: ViewModifier {
    let magnitude: CGFloat

    @State private var offset: CGSize = .zero

    func body(content: Content) -> some View {
        content
            .offset(x: offset.width * magnitude, y: offset.height * magnitude)
            .onAppear {
                withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                    offset = CGSize(width: CGFloat.random(in: -2...2), height: CGFloat.random(in: -2...2))
                }
            }
    }
}

extension View {
    func parallax(magnitude: CGFloat = 1.0) -> some View {
        modifier(ParallaxModifier(magnitude: magnitude))
    }
}

// MARK: - Glow Modifier
struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .shadow(color: isActive ? color.opacity(0.4) : .clear, radius: radius)
            .shadow(color: isActive ? color.opacity(0.2) : .clear, radius: radius * 2)
    }
}

extension View {
    func glow(color: Color = .v2xCyan, radius: CGFloat = 8, isActive: Bool = true) -> some View {
        modifier(GlowModifier(color: color, radius: radius, isActive: isActive))
    }
}

// MARK: - Card Shadow
extension View {
    func cardShadow(color: Color = .black, opacity: Double = 0.3, radius: CGFloat = 10, y: CGFloat = 5) -> some View {
        self.shadow(color: color.opacity(opacity), radius: radius, x: 0, y: y)
    }
}

// MARK: - Blur Card Background
struct BlurCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let material: Material

    func body(content: Content) -> some View {
        content
            .background(material, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.06), lineWidth: 0.5)
            )
    }
}

extension View {
    func blurCard(cornerRadius: CGFloat = 16, material: Material = .ultraThinMaterial) -> some View {
        modifier(BlurCardModifier(cornerRadius: cornerRadius, material: material))
    }
}

// MARK: - String Extensions
extension String {
    func truncated(to maxLength: Int, trailing: String = "...") -> String {
        if self.count > maxLength {
            return String(self.prefix(maxLength)) + trailing
        }
        return self
    }
}

// MARK: - Date Extensions
extension Date {
    var timeAgoString: String {
        let interval = Date().timeIntervalSince(self)
        if interval < 60 { return "только что" }
        if interval < 3600 { return "\(Int(interval / 60)) мин назад" }
        if interval < 86400 { return "\(Int(interval / 3600)) ч назад" }
        return "\(Int(interval / 86400)) дн назад"
    }
}
