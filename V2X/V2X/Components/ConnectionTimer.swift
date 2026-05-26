// ConnectionTimer.swift
// V2X

import SwiftUI

struct ConnectionTimer: View {
    @EnvironmentObject var vpnManager: VPNManager
    @State private var displayTime: String = "00:00:00"
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 4) {
            Text("Время подключения")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.v2xTextTertiary)

            Text(displayTime)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .contentTransition(.numericText())
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: vpnManager.connectionState) { state in
            if state == .connected {
                startTimer()
            } else {
                timer?.invalidate()
                if state == .disconnected {
                    displayTime = "00:00:00"
                }
            }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateDisplay()
        }
    }

    private func updateDisplay() {
        guard let since = vpnManager.connectedSince else {
            displayTime = "00:00:00"
            return
        }
        let interval = Date().timeIntervalSince(since)
        withAnimation(.linear(duration: 0.2)) {
            displayTime = String.formatDuration(interval)
        }
    }
}

// MARK: - Compact Timer
struct CompactConnectionTimer: View {
    @EnvironmentObject var vpnManager: VPNManager
    @State private var displayTime: String = "00:00:00"
    @State private var timer: Timer?

    var body: some View {
        Text(displayTime)
            .font(.system(size: 14, weight: .medium, design: .monospaced))
            .foregroundColor(.v2xTextSecondary)
            .onAppear { startTimer() }
            .onDisappear { timer?.invalidate() }
            .onChange(of: vpnManager.connectionState) { state in
                if state == .connected { startTimer() }
                else {
                    timer?.invalidate()
                    if state == .disconnected { displayTime = "00:00:00" }
                }
            }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard let since = vpnManager.connectedSince else { return }
            displayTime = String.formatDuration(Date().timeIntervalSince(since))
        }
    }
}

// MARK: - Status Indicator
struct StatusIndicator: View {
    let state: ConnectionState
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(state.color)
                .frame(width: 8, height: 8)
                .overlay(
                    Circle()
                        .fill(state.color.opacity(0.4))
                        .scaleEffect(isAnimating && state == .connected ? 2.5 : 1)
                        .opacity(isAnimating && state == .connected ? 0 : 0.4)
                )
                .shadow(color: state.color.opacity(0.5), radius: 4)

            Text(state.rawValue)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(state.color)
        }
        .onAppear {
            withAnimation(
                Animation.easeOut(duration: 1.5)
                    .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Traffic Stats Row
struct TrafficStatsRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.v2xTextSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}
