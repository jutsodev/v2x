// VPNManager.swift
// V2X

import SwiftUI
import Combine

final class VPNManager: ObservableObject {
    static let shared = VPNManager()

    @Published var connectionState: ConnectionState = .disconnected
    @Published var activeProfile: VPNProfile? = VPNProfile.preview
    @Published var stats: TrafficStats = TrafficStats()
    @Published var connectedSince: Date?
    @Published var currentPing: Int = 0
    @Published var isQuantumStealthEnabled = true
    @Published var isThreatShieldActive = true
    @Published var tunnelMode: TunnelMode = .persistent
    @Published var ipVersion: IPVersion = .v4v6
    @Published var isOnDemandEnabled = false
    @Published var connectOnAllNetworks = true
    @Published var disconnectOnSleep = false
    @Published var memoryLimit: Int = 256
    @Published var fragmentationEnabled = false

    private var statsTimer: Timer?
    private var pingTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    enum TunnelMode: String, CaseIterable {
        case persistent = "Постоянный"
        case onDemand = "По требованию"
        case manual = "Ручной"
    }

    enum IPVersion: String, CaseIterable {
        case v4 = "IPv4"
        case v6 = "IPv6"
        case v4v6 = "IPv4 & IPv6"
    }

    private init() {
        setupDemoData()
    }

    // MARK: - Connection Management
    func connect() {
        guard connectionState == .disconnected || connectionState == .error else { return }

        connectionState = .connecting
        HapticManager.shared.triggerImpact(.medium)

        // Simulate connection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1.2...2.5)) { [weak self] in
            guard let self = self else { return }
            self.connectionState = .connected
            self.connectedSince = Date()
            self.stats.connectedSince = self.connectedSince
            self.startStatsUpdates()
            self.startPingUpdates()
            HapticManager.shared.triggerNotification(.success)
        }
    }

    func disconnect() {
        guard connectionState == .connected else { return }

        connectionState = .disconnecting
        HapticManager.shared.triggerImpact(.medium)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }
            self.connectionState = .disconnected
            self.stopStatsUpdates()
            self.stopPingUpdates()
            self.connectedSince = nil
            self.stats.connectedSince = nil
            HapticManager.shared.triggerNotification(.warning)
        }
    }

    func toggle() {
        switch connectionState {
        case .connected:
            disconnect()
        case .disconnected:
            connect()
        default:
            break
        }
    }

    func reconnect() {
        disconnect()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.connect()
        }
    }

    // MARK: - Stats Simulation
    private func startStatsUpdates() {
        statsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.simulateTraffic()
        }
    }

    private func stopStatsUpdates() {
        statsTimer?.invalidate()
        statsTimer = nil
    }

    private func startPingUpdates() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.currentPing = Int.random(in: 18...45)
        }
    }

    private func stopPingUpdates() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func simulateTraffic() {
        let uploadDelta = Int64.random(in: 50_000...500_000)
        let downloadDelta = Int64.random(in: 200_000...2_000_000)

        stats.uploadBytes += uploadDelta
        stats.downloadBytes += downloadDelta
        stats.totalBytes = stats.uploadBytes + stats.downloadBytes
        stats.sessionUpload += uploadDelta
        stats.sessionDownload += downloadDelta
        stats.uploadSpeed = Double(uploadDelta)
        stats.downloadSpeed = Double(downloadDelta)
    }

    private func setupDemoData() {
        stats = TrafficStats(
            uploadBytes: 658_737_049,
            downloadBytes: 5_926_248_448,
            totalBytes: 10_737_418_240_000,
            uploadSpeed: 2_500_000,
            downloadSpeed: 15_000_000,
            connectedSince: nil,
            sessionUpload: 0,
            sessionDownload: 0
        )
    }

    // MARK: - Computed Properties
    var isConnected: Bool {
        connectionState == .connected
    }

    var isMuxEnabled: Bool {
        connectionState == .connected
    }

    var isFragmentEnabled: Bool {
        fragmentationEnabled
    }

    // MARK: - Connection Timer
    var connectionDuration: TimeInterval {
        guard let since = connectedSince else { return 0 }
        return Date().timeIntervalSince(since)
    }

    var formattedDuration: String {
        String.formatDuration(connectionDuration)
    }
}
