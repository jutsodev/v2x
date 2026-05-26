// SplashView.swift
// V2X

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var themeManager: ThemeManager

    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var ringScales: [CGFloat] = [0.5, 0.5, 0.5]
    @State private var ringOpacities: [Double] = [0, 0, 0]
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var sloganOpacity: Double = 0
    @State private var particlesVisible = false
    @State private var glowIntensity: Double = 0

    var body: some View {
        ZStack {
            // Background
            Color(hex: "050505")
                .ignoresSafeArea()

            // Ambient particles
            if particlesVisible {
                SplashParticles()
            }

            // Center content
            VStack(spacing: 24) {
                Spacer()

                // Logo with rings
                ZStack {
                    // Outer rings
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.v2xCyan.opacity(0.4 - Double(index) * 0.1),
                                        Color.v2xPurple.opacity(0.3 - Double(index) * 0.08),
                                        Color.v2xGreen.opacity(0.2 - Double(index) * 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                            .frame(
                                width: 110 + CGFloat(index) * 30,
                                height: 110 + CGFloat(index) * 30
                            )
                            .scaleEffect(index < ringScales.count ? ringScales[index] : 0.5)
                            .opacity(index < ringOpacities.count ? ringOpacities[index] : 0)
                            .rotationEffect(.degrees(Double(index) * 30))
                    }

                    // Inner glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.v2xCyan.opacity(0.2 * glowIntensity),
                                    Color.v2xPurple.opacity(0.1 * glowIntensity),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)

                    // Logo circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "111111"),
                                    Color(hex: "0A0A0A")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 90, height: 90)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color.v2xCyan.opacity(0.5),
                                            Color.v2xPurple.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        )
                        .shadow(color: Color.v2xCyan.opacity(0.3 * glowIntensity), radius: 20)

                    // V2X text
                    Text("V2X")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.v2xCyan, .v2xPurple, .v2xGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // Title
                Text("V2X")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.8)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)

                // Slogan
                Text("Твой неубиваемый туннель в свободный интернет")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.v2xTextTertiary)
                    .opacity(sloganOpacity)
                    .multilineTextAlignment(.center)

                Spacer()

                // Bottom info
                VStack(spacing: 4) {
                    Text("t.me/kreadwrite • @kreadwriteQ")
                        .font(.system(size: 11))
                        .foregroundColor(.v2xTextTertiary)
                        .opacity(sloganOpacity * 0.7)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startAnimationSequence()
        }
    }

    private func startAnimationSequence() {
        // Phase 1: Logo appears
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }

        // Phase 2: Rings expand
        for index in 0..<3 {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4 + Double(index) * 0.15)) {
                ringScales[index] = 1.0
                ringOpacities[index] = 1.0
            }
        }

        // Phase 3: Glow intensifies
        withAnimation(.easeInOut(duration: 0.8).delay(0.6)) {
            glowIntensity = 1.0
        }

        // Phase 4: Particles appear
        withAnimation(.easeIn(duration: 0.5).delay(0.8)) {
            particlesVisible = true
        }

        // Phase 5: Title slides in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0)) {
            titleOpacity = 1.0
            titleOffset = 0
        }

        // Phase 6: Slogan fades in
        withAnimation(.easeInOut(duration: 0.6).delay(1.3)) {
            sloganOpacity = 1.0
        }
    }
}

struct SplashParticles: View {
    @State private var particles: [SplashParticle] = (0..<25).map { _ in SplashParticle.random() }

    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let x = particle.x * size.width
                let y = particle.y * size.height
                let opacity = particle.opacity

                var circle = Path()
                circle.addEllipse(in: CGRect(
                    x: x - particle.size / 2,
                    y: y - particle.size / 2,
                    width: particle.size,
                    height: particle.size
                ))

                context.fill(circle, with: .color(particle.color.opacity(opacity)))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                for index in particles.indices {
                    particles[index].x += CGFloat.random(in: -0.05...0.05)
                    particles[index].y += CGFloat.random(in: -0.05...0.05)
                    particles[index].opacity = Double.random(in: 0.1...0.5)
                }
            }
        }
    }
}

struct SplashParticle {
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
    var color: Color

    static func random() -> SplashParticle {
        let colors: [Color] = [.v2xCyan, .v2xPurple, .v2xGreen, .white]
        return SplashParticle(
            x: CGFloat.random(in: 0...1),
            y: CGFloat.random(in: 0...1),
            size: CGFloat.random(in: 1...4),
            opacity: Double.random(in: 0.05...0.3),
            color: colors.randomElement()!
        )
    }
}
