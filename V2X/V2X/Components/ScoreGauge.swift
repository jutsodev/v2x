// ScoreGauge.swift
// V2X

import SwiftUI

struct ScoreGauge: View {
    let label: String
    let score: Double
    let color: Color
    var size: CGFloat = 52

    @State private var animatedScore: Double = 0

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        color.opacity(0.12),
                        lineWidth: 4
                    )
                    .frame(width: size, height: size)

                // Progress ring
                Circle()
                    .trim(from: 0, to: animatedScore)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.3),
                                color,
                                color.opacity(0.8)
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))

                // Score text
                Text("\(Int(animatedScore * 100))")
                    .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                    .foregroundColor(color)
            }

            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.v2xTextTertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).delay(0.2)) {
                animatedScore = score
            }
        }
        .onChange(of: score) { newValue in
            withAnimation(.easeInOut(duration: 0.6)) {
                animatedScore = newValue
            }
        }
    }
}

struct LargeScoreGauge: View {
    let label: String
    let score: Double
    let color: Color
    var subtitle: String = ""
    var size: CGFloat = 100

    @State private var animatedScore: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.opacity(0.08), Color.clear],
                            center: .center,
                            startRadius: size * 0.4,
                            endRadius: size * 0.6
                        )
                    )
                    .frame(width: size * 1.2, height: size * 1.2)

                // Background track
                Circle()
                    .stroke(color.opacity(0.08), lineWidth: 6)
                    .frame(width: size, height: size)

                // Secondary track
                Circle()
                    .trim(from: 0, to: animatedScore)
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(0.4), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))

                // Inner content
                VStack(spacing: 2) {
                    Text("\(Int(animatedScore * 100))")
                        .font(.system(size: size * 0.3, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("%")
                        .font(.system(size: size * 0.12, weight: .medium))
                        .foregroundColor(color)
                }

                // Dot indicator
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                    .shadow(color: color, radius: 4)
                    .offset(y: -size / 2)
                    .rotationEffect(.degrees(animatedScore * 360))
            }

            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.v2xTextTertiary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
                animatedScore = score
            }
        }
        .onChange(of: score) { newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatedScore = newValue
            }
        }
    }
}

struct MultiScoreGauge: View {
    let segments: [(String, Double, Color)]
    var size: CGFloat = 120

    @State private var animatedValues: [Double] = []

    var body: some View {
        ZStack {
            ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
                let offset = CGFloat(index) * 8
                Circle()
                    .trim(
                        from: 0,
                        to: index < animatedValues.count ? animatedValues[index] : 0
                    )
                    .stroke(
                        segment.2,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: size - offset * 2, height: size - offset * 2)
                    .rotationEffect(.degrees(-90))
            }

            VStack(spacing: 2) {
                let avg = segments.map(\.1).reduce(0, +) / Double(max(segments.count, 1))
                Text("\(Int(avg * 100))")
                    .font(.system(size: size * 0.22, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                Text("AVG")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.v2xTextTertiary)
            }
        }
        .onAppear {
            animatedValues = Array(repeating: 0, count: segments.count)
            for (index, segment) in segments.enumerated() {
                withAnimation(.easeInOut(duration: 1.2).delay(Double(index) * 0.2)) {
                    if index < animatedValues.count {
                        animatedValues[index] = segment.1
                    }
                }
            }
        }
    }
}

struct SpeedMeter: View {
    let speed: Double
    let maxSpeed: Double
    let color: Color
    var label: String = ""
    var size: CGFloat = 80

    @State private var animatedProgress: Double = 0

    var progress: Double {
        min(speed / max(maxSpeed, 1), 1.0)
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Background arc
                ArcShape(startAngle: -210, endAngle: 30)
                    .stroke(color.opacity(0.1), lineWidth: 6)
                    .frame(width: size, height: size)

                // Progress arc
                ArcShape(
                    startAngle: -210,
                    endAngle: -210 + animatedProgress * 240
                )
                .stroke(
                    LinearGradient(
                        colors: [color.opacity(0.5), color],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: size, height: size)

                VStack(spacing: 0) {
                    Text(String.formatSpeed(speed))
                        .font(.system(size: size * 0.16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
            }

            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.v2xTextTertiary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: speed) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedProgress = progress
            }
        }
    }
}

struct ArcShape: Shape {
    var startAngle: Double
    var endAngle: Double

    var animatableData: Double {
        get { endAngle }
        set { endAngle = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startAngle),
            endAngle: .degrees(endAngle),
            clockwise: false
        )
        return path
    }
}

struct StatusBadge: View {
    let text: String
    let color: Color
    var icon: String?
    var isAnimated: Bool = false

    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }

            if isAnimated {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
                    .scaleEffect(isPulsing ? 1.3 : 0.8)
                    .animation(.easeInOut(duration: 0.8).repeatForever(), value: isPulsing)
                    .onAppear { isPulsing = true }
            }

            Text(text)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.25), lineWidth: 0.5)
                )
        )
    }
}
