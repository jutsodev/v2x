// PulseParticles.swift
// V2X — V2X Pulse Live Particles

import SwiftUI

struct V2XPulseView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @EnvironmentObject var themeManager: ThemeManager
    let particleCount: Int
    let radius: CGFloat

    @State private var particles: [PulseParticle] = []
    @State private var timer: Timer?

    init(particleCount: Int = 40, radius: CGFloat = 120) {
        self.particleCount = particleCount
        self.radius = radius
    }

    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                particle.color.opacity(particle.opacity),
                                particle.color.opacity(particle.opacity * 0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: particle.size
                        )
                    )
                    .frame(width: particle.size * 2, height: particle.size * 2)
                    .offset(x: particle.position.x, y: particle.position.y)
                    .blur(radius: particle.blur)
            }
        }
        .frame(width: radius * 2, height: radius * 2)
        .onAppear {
            generateParticles()
            animateParticles()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: vpnManager.connectionState) { state in
            if state == .connected {
                animateParticles()
            }
        }
    }

    private func generateParticles() {
        let colors = themeManager.currentTheme.pulseColors
        particles = (0..<particleCount).map { i in
            let angle = Double.random(in: 0...(2 * .pi))
            let dist = CGFloat.random(in: radius * 0.3...radius)
            return PulseParticle(
                id: i,
                position: CGPoint(
                    x: cos(angle) * dist,
                    y: sin(angle) * dist
                ),
                targetPosition: CGPoint(
                    x: cos(angle) * dist * CGFloat.random(in: 0.8...1.2),
                    y: sin(angle) * dist * CGFloat.random(in: 0.8...1.2) - CGFloat.random(in: 20...60)
                ),
                size: CGFloat.random(in: 2...8),
                opacity: Double.random(in: 0.2...0.7),
                color: colors[i % colors.count],
                speed: Double.random(in: 1.5...4.0),
                blur: CGFloat.random(in: 0...2)
            )
        }
    }

    private func animateParticles() {
        for i in particles.indices {
            let delay = Double.random(in: 0...1.0)
            withAnimation(
                Animation.easeInOut(duration: particles[i].speed)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
            ) {
                particles[i].position = particles[i].targetPosition
                particles[i].opacity = Double.random(in: 0.1...0.6)
            }
        }
    }
}

struct PulseParticle: Identifiable {
    let id: Int
    var position: CGPoint
    var targetPosition: CGPoint
    var size: CGFloat
    var opacity: Double
    var color: Color
    var speed: Double
    var blur: CGFloat
}

// MARK: - Connection Pulse Ring
struct ConnectionPulseRing: View {
    let color: Color
    let isActive: Bool
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.5

    var body: some View {
        Circle()
            .stroke(color, lineWidth: 1)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                guard isActive else { return }
                withAnimation(
                    Animation.easeOut(duration: 2.0)
                        .repeatForever(autoreverses: false)
                ) {
                    scale = 2.5
                    opacity = 0
                }
            }
    }
}

// MARK: - Traffic Flow Particles
struct TrafficFlowParticles: View {
    @EnvironmentObject var vpnManager: VPNManager
    let width: CGFloat
    let height: CGFloat

    @State private var flowParticles: [FlowParticle] = []

    struct FlowParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var speed: Double
        var color: Color
        var opacity: Double
    }

    var body: some View {
        Canvas { context, size in
            for particle in flowParticles {
                let rect = CGRect(
                    x: particle.x - particle.size / 2,
                    y: particle.y - particle.size / 2,
                    width: particle.size,
                    height: particle.size
                )
                context.fill(
                    Circle().path(in: rect),
                    with: .color(particle.color.opacity(particle.opacity))
                )
            }
        }
        .frame(width: width, height: height)
        .onAppear {
            generateFlowParticles()
            startFlowAnimation()
        }
    }

    private func generateFlowParticles() {
        flowParticles = (0..<30).map { _ in
            FlowParticle(
                x: CGFloat.random(in: 0...width),
                y: CGFloat.random(in: 0...height),
                size: CGFloat.random(in: 2...5),
                speed: Double.random(in: 0.5...2.0),
                color: [.v2xCyan, .v2xGreen, .v2xPurple].randomElement()!,
                opacity: Double.random(in: 0.2...0.5)
            )
        }
    }

    private func startFlowAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            for i in flowParticles.indices {
                flowParticles[i].y -= CGFloat(flowParticles[i].speed)
                if flowParticles[i].y < 0 {
                    flowParticles[i].y = height
                    flowParticles[i].x = CGFloat.random(in: 0...width)
                }
            }
        }
    }
}
