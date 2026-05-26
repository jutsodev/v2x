// LiquidEffects.swift
// V2X

import SwiftUI

// MARK: - Liquid Ripple Effect
struct LiquidRippleEffect: ViewModifier {
    @State private var ripples: [RippleState] = []

    struct RippleState: Identifiable {
        let id = UUID()
        var location: CGPoint
        var scale: CGFloat = 0
        var opacity: Double = 0.6
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    ZStack {
                        ForEach(ripples) { ripple in
                            Circle()
                                .fill(Color.white.opacity(ripple.opacity))
                                .frame(width: 40, height: 40)
                                .scaleEffect(ripple.scale)
                                .position(ripple.location)
                                .allowsHitTesting(false)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        addRipple(at: location)
                    }
                }
            )
    }

    private func addRipple(at location: CGPoint) {
        var ripple = RippleState(location: location)
        ripples.append(ripple)

        withAnimation(.easeOut(duration: 0.6)) {
            if let index = ripples.firstIndex(where: { $0.id == ripple.id }) {
                ripples[index].scale = 5
                ripples[index].opacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            ripples.removeAll { $0.id == ripple.id }
        }
    }
}

extension View {
    func liquidRipple() -> some View {
        modifier(LiquidRippleEffect())
    }
}

// MARK: - Chromatic Aberration Effect
struct ChromaticAberrationModifier: ViewModifier {
    let offset: CGFloat
    let isActive: Bool

    func body(content: Content) -> some View {
        ZStack {
            if isActive {
                content
                    .foregroundColor(.red.opacity(0.15))
                    .offset(x: -offset, y: -offset)
                    .blendMode(.screen)

                content
                    .foregroundColor(.blue.opacity(0.15))
                    .offset(x: offset, y: offset)
                    .blendMode(.screen)
            }

            content
        }
    }
}

extension View {
    func chromaticAberration(offset: CGFloat = 1.5, isActive: Bool = true) -> some View {
        modifier(ChromaticAberrationModifier(offset: offset, isActive: isActive))
    }
}

// MARK: - Caustics Effect Layer
struct CausticsLayer: View {
    let color: Color
    var intensity: Double = 0.3
    var speed: Double = 2.0

    @State private var phase: Double = 0

    var body: some View {
        Canvas { context, size in
            let columns = 8
            let rows = 6
            let cellW = size.width / CGFloat(columns)
            let cellH = size.height / CGFloat(rows)

            for col in 0..<columns {
                for row in 0..<rows {
                    let x = CGFloat(col) * cellW + cellW / 2
                    let y = CGFloat(row) * cellH + cellH / 2

                    let offset = sin(phase + Double(col) * 0.5 + Double(row) * 0.3) * 0.5 + 0.5
                    let opacity = offset * intensity

                    let radius = cellW * 0.4 * CGFloat(offset + 0.5)

                    var circle = Path()
                    circle.addEllipse(in: CGRect(
                        x: x - radius,
                        y: y - radius,
                        width: radius * 2,
                        height: radius * 2
                    ))

                    context.fill(circle, with: .color(color.opacity(opacity)))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Liquid Gradient Background
struct LiquidGradientBackground: View {
    let colors: [Color]
    var speed: Double = 3.0

    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: speed).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Mesh Gradient Fallback
struct AnimatedMeshBackground: View {
    let colors: [Color]
    @State private var phase: Double = 0

    var body: some View {
        Canvas { context, size in
            let gridSize = 5
            let cellW = size.width / CGFloat(gridSize - 1)
            let cellH = size.height / CGFloat(gridSize - 1)

            for i in 0..<gridSize {
                for j in 0..<gridSize {
                    let baseX = CGFloat(i) * cellW
                    let baseY = CGFloat(j) * cellH
                    let offsetX = sin(phase + Double(i + j) * 0.5) * 20
                    let offsetY = cos(phase + Double(i - j) * 0.7) * 20

                    let x = baseX + CGFloat(offsetX)
                    let y = baseY + CGFloat(offsetY)

                    let colorIndex = (i + j) % colors.count
                    let opacity = 0.1 + sin(phase + Double(i * j) * 0.3) * 0.05

                    var circle = Path()
                    circle.addEllipse(in: CGRect(x: x - 30, y: y - 30, width: 60, height: 60))
                    context.fill(circle, with: .color(colors[colorIndex].opacity(opacity)))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
        .blur(radius: 30)
        .allowsHitTesting(false)
    }
}

// MARK: - Connection Button Rings
struct ConnectionButtonRings: View {
    let isConnected: Bool
    let color: Color

    @State private var ring1Scale: CGFloat = 0.9
    @State private var ring2Scale: CGFloat = 0.85
    @State private var ring3Scale: CGFloat = 0.8
    @State private var ring1Opacity: Double = 0.3
    @State private var ring2Opacity: Double = 0.2
    @State private var ring3Opacity: Double = 0.1

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(ring3Opacity), lineWidth: 1)
                .scaleEffect(ring3Scale)

            Circle()
                .stroke(color.opacity(ring2Opacity), lineWidth: 1.5)
                .scaleEffect(ring2Scale)

            Circle()
                .stroke(color.opacity(ring1Opacity), lineWidth: 2)
                .scaleEffect(ring1Scale)
        }
        .onAppear {
            if isConnected {
                startPulseAnimation()
            }
        }
        .onChange(of: isConnected) { connected in
            if connected {
                startPulseAnimation()
            } else {
                resetAnimation()
            }
        }
    }

    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            ring1Scale = 1.15
            ring1Opacity = 0.5
        }
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.3)) {
            ring2Scale = 1.25
            ring2Opacity = 0.35
        }
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true).delay(0.6)) {
            ring3Scale = 1.35
            ring3Opacity = 0.2
        }
    }

    private func resetAnimation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            ring1Scale = 0.9
            ring2Scale = 0.85
            ring3Scale = 0.8
            ring1Opacity = 0.1
            ring2Opacity = 0.08
            ring3Opacity = 0.05
        }
    }
}

// MARK: - Glass Reflection
struct GlassReflection: View {
    let cornerRadius: CGFloat

    @State private var offset: CGFloat = -100

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.05),
                        .white.opacity(0.1),
                        .white.opacity(0.05),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .offset(x: offset)
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: false).delay(1)) {
                    offset = 400
                }
            }
            .clipped()
            .allowsHitTesting(false)
    }
}

// MARK: - Neon Text
struct NeonText: View {
    let text: String
    let color: Color
    var font: Font = .system(size: 16, weight: .bold)

    var body: some View {
        ZStack {
            Text(text)
                .font(font)
                .foregroundColor(color.opacity(0.3))
                .blur(radius: 8)

            Text(text)
                .font(font)
                .foregroundColor(color.opacity(0.6))
                .blur(radius: 4)

            Text(text)
                .font(font)
                .foregroundColor(color)
        }
    }
}


