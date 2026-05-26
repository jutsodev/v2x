// SpeedTestView.swift
// V2X

import SwiftUI

struct SpeedTestView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var testState: TestState = .idle
    @State private var downloadSpeed: Double = 0
    @State private var uploadSpeed: Double = 0
    @State private var ping: Double = 0
    @State private var jitter: Double = 0
    @State private var progress: Double = 0
    @State private var testPhase: TestPhase = .ping
    @State private var speedHistory: [SpeedSample] = []
    @State private var testResults: [TestResult] = []

    enum TestState {
        case idle, running, completed
    }

    enum TestPhase: String {
        case ping = "Пинг"
        case download = "Загрузка"
        case upload = "Выгрузка"
    }

    struct SpeedSample: Identifiable {
        let id = UUID()
        let value: Double
        let type: TestPhase
    }

    struct TestResult: Identifiable {
        let id = UUID()
        let timestamp: Date
        let download: Double
        let upload: Double
        let ping: Double
        let server: String
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Speed Gauge
                    speedGaugeCard

                    // Current Metrics
                    if testState != .idle {
                        currentMetrics
                    }

                    // Start/Stop Button
                    controlButton

                    // History
                    if !testResults.isEmpty {
                        historySection
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .liquidGlassBackground(cornerRadius: 10)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Тест скорости")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Speed Gauge
    private var speedGaugeCard: some View {
        LiquidGlassCard(cornerRadius: 28) {
            VStack(spacing: 20) {
                ZStack {
                    // Background arc
                    ArcShape(startAngle: -210, endAngle: 30)
                        .stroke(Color.white.opacity(0.06), lineWidth: 12)
                        .frame(width: 200, height: 200)

                    // Progress arc
                    ArcShape(startAngle: -210, endAngle: -210 + (currentSpeed / maxSpeed) * 240)
                        .stroke(
                            LinearGradient(
                                colors: speedGradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)

                    // Tick marks
                    ForEach(0..<9, id: \.self) { tick in
                        let angle = -210 + Double(tick) * 30
                        Rectangle()
                            .fill(Color.white.opacity(tick % 3 == 0 ? 0.3 : 0.1))
                            .frame(width: 1, height: tick % 3 == 0 ? 12 : 6)
                            .offset(y: -88)
                            .rotationEffect(.degrees(angle))
                    }

                    // Center content
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", currentSpeed))
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())

                        Text("Mbps")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.v2xTextTertiary)

                        if testState == .running {
                            Text(testPhase.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.v2xCyan)
                        }
                    }

                    // Dot on arc
                    if testState == .running {
                        Circle()
                            .fill(.white)
                            .frame(width: 10, height: 10)
                            .shadow(color: .white, radius: 4)
                            .offset(y: -100)
                            .rotationEffect(.degrees(-210 + (currentSpeed / maxSpeed) * 240))
                    }
                }
                .frame(height: 200)

                // Phase progress
                if testState == .running {
                    LiquidGlassProgressBar(progress: progress, color: .v2xCyan, height: 4)
                }
            }
            .padding(24)
        }
    }

    private var currentSpeed: Double {
        switch testPhase {
        case .ping: return ping
        case .download: return downloadSpeed
        case .upload: return uploadSpeed
        }
    }

    private var maxSpeed: Double {
        switch testPhase {
        case .ping: return 200
        case .download, .upload: return 200
        }
    }

    private var speedGradientColors: [Color] {
        if currentSpeed > maxSpeed * 0.7 {
            return [.v2xGreen, .v2xCyan]
        } else if currentSpeed > maxSpeed * 0.3 {
            return [.v2xCyan, .v2xPurple]
        } else {
            return [.v2xYellow, .v2xCyan]
        }
    }

    // MARK: - Current Metrics
    private var currentMetrics: some View {
        HStack(spacing: 12) {
            metricBox(icon: "arrow.down.circle", label: "Download", value: String(format: "%.1f Mbps", downloadSpeed), color: .v2xCyan)
            metricBox(icon: "arrow.up.circle", label: "Upload", value: String(format: "%.1f Mbps", uploadSpeed), color: .v2xPurple)
            metricBox(icon: "gauge.with.needle", label: "Ping", value: String(format: "%.0f ms", ping), color: .v2xGreen)
        }
    }

    private func metricBox(icon: String, label: String, value: String, color: Color) -> some View {
        LiquidGlassCard(cornerRadius: 14) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)

                Text(value)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.v2xTextTertiary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Control Button
    private var controlButton: some View {
        Button {
            if testState == .running {
                stopTest()
            } else {
                startTest()
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: testState == .running ? "stop.fill" : "play.fill")
                    .font(.system(size: 18))
                Text(testState == .running ? "Остановить" : "Начать тест")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: testState == .running ? [.v2xRed, .v2xOrange] : [.v2xCyan, .v2xPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: (testState == .running ? Color.v2xRed : .v2xCyan).opacity(0.3), radius: 10, y: 5)
        }
        .buttonStyle(LiquidPressButtonStyle())
    }

    // MARK: - History Section
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("История тестов")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            ForEach(testResults) { result in
                LiquidGlassCard(cornerRadius: 14) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(result.timestamp, style: .date)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                            Text(result.server)
                                .font(.system(size: 10))
                                .foregroundColor(.v2xTextTertiary)
                        }

                        Spacer()

                        HStack(spacing: 16) {
                            VStack(spacing: 2) {
                                Text("↓")
                                    .font(.system(size: 10))
                                    .foregroundColor(.v2xCyan)
                                Text(String(format: "%.0f", result.download))
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }

                            VStack(spacing: 2) {
                                Text("↑")
                                    .font(.system(size: 10))
                                    .foregroundColor(.v2xPurple)
                                Text(String(format: "%.0f", result.upload))
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }

                            VStack(spacing: 2) {
                                Text("ms")
                                    .font(.system(size: 10))
                                    .foregroundColor(.v2xGreen)
                                Text(String(format: "%.0f", result.ping))
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(12)
                }
            }
        }
    }

    // MARK: - Test Logic
    private func startTest() {
        testState = .running
        downloadSpeed = 0
        uploadSpeed = 0
        ping = 0
        jitter = 0
        progress = 0
        speedHistory.removeAll()

        // Phase 1: Ping
        testPhase = .ping
        simulatePing()
    }

    private func simulatePing() {
        let steps = 10
        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    ping = Double.random(in: 15...45)
                    jitter = Double.random(in: 0.5...5)
                    progress = Double(i + 1) / Double(steps) * 0.33
                }

                if i == steps - 1 {
                    testPhase = .download
                    simulateDownload()
                }
            }
        }
    }

    private func simulateDownload() {
        let steps = 20
        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    let baseSpeed = Double.random(in: 50...120)
                    let variation = Double.random(in: -10...10)
                    downloadSpeed = max(0, baseSpeed + variation)
                    progress = 0.33 + Double(i + 1) / Double(steps) * 0.33
                }

                if i == steps - 1 {
                    testPhase = .upload
                    simulateUpload()
                }
            }
        }
    }

    private func simulateUpload() {
        let steps = 20
        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    let baseSpeed = Double.random(in: 20...50)
                    let variation = Double.random(in: -5...5)
                    uploadSpeed = max(0, baseSpeed + variation)
                    progress = 0.66 + Double(i + 1) / Double(steps) * 0.34
                }

                if i == steps - 1 {
                    completeTest()
                }
            }
        }
    }

    private func completeTest() {
        testState = .completed
        HapticManager.shared.triggerNotification(.success)

        let result = TestResult(
            timestamp: Date(),
            download: downloadSpeed,
            upload: uploadSpeed,
            ping: ping,
            server: "V2X Server \(ServerNode.sampleServers.randomElement()?.flag ?? "🌍")"
        )
        testResults.insert(result, at: 0)
    }

    private func stopTest() {
        testState = .idle
        progress = 0
    }
}
