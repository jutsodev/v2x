// NetworkMonitor.swift
// V2X

import SwiftUI
import Combine
import Network

class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published var isConnected: Bool = true
    @Published var connectionType: ConnectionType = .wifi
    @Published var interfaceType: String = "Wi-Fi"
    @Published var signalStrength: Double = 0.85
    @Published var isExpensive: Bool = false
    @Published var isConstrained: Bool = false
    @Published var localIPv4: String = "192.168.1.42"
    @Published var localIPv6: String = "fe80::1"
    @Published var ssid: String = "V2X-Network"
    @Published var bssid: String = "AA:BB:CC:DD:EE:FF"
    @Published var gatewayIP: String = "192.168.1.1"
    @Published var subnetMask: String = "255.255.255.0"
    @Published var dnsServers: [String] = ["1.1.1.1", "8.8.8.8"]
    @Published var mtu: Int = 1500
    @Published var rxBytes: Double = 0
    @Published var txBytes: Double = 0
    @Published var rxPackets: Int = 0
    @Published var txPackets: Int = 0
    @Published var networkLatency: Double = 12.5
    @Published var jitter: Double = 2.3
    @Published var packetLoss: Double = 0.01
    @Published var bandwidthEstimate: Double = 85.0

    @Published var networkHistory: [NetworkSample] = []

    private var cancellables = Set<AnyCancellable>()
    private var sampleTimer: Timer?
    private let maxHistorySamples = 120

    enum ConnectionType: String, CaseIterable {
        case wifi = "Wi-Fi"
        case cellular = "Cellular"
        case ethernet = "Ethernet"
        case vpn = "VPN"
        case unknown = "Unknown"

        var icon: String {
            switch self {
            case .wifi: return "wifi"
            case .cellular: return "antenna.radiowaves.left.and.right"
            case .ethernet: return "cable.connector"
            case .vpn: return "lock.shield"
            case .unknown: return "questionmark.circle"
            }
        }

        var color: Color {
            switch self {
            case .wifi: return .v2xGreen
            case .cellular: return .v2xCyan
            case .ethernet: return .v2xBlue
            case .vpn: return .v2xPurple
            case .unknown: return .gray
            }
        }
    }

    struct NetworkSample: Identifiable {
        let id = UUID()
        let timestamp: Date
        let download: Double
        let upload: Double
        let latency: Double
        let packetLoss: Double
    }

    private init() {
        startMonitoring()
        generateInitialHistory()
    }

    func startMonitoring() {
        sampleTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateNetworkStats()
        }
    }

    func stopMonitoring() {
        sampleTimer?.invalidate()
        sampleTimer = nil
    }

    private func updateNetworkStats() {
        let uploadDelta = Double.random(in: 50_000...5_000_000)
        let downloadDelta = Double.random(in: 200_000...15_000_000)

        txBytes += uploadDelta
        rxBytes += downloadDelta
        txPackets += Int.random(in: 10...200)
        rxPackets += Int.random(in: 50...500)

        networkLatency = max(5, networkLatency + Double.random(in: -2...2))
        jitter = max(0.1, jitter + Double.random(in: -0.5...0.5))
        packetLoss = max(0, min(5, packetLoss + Double.random(in: -0.1...0.1)))
        signalStrength = max(0.3, min(1.0, signalStrength + Double.random(in: -0.02...0.02)))
        bandwidthEstimate = max(10, min(200, bandwidthEstimate + Double.random(in: -5...5)))

        let sample = NetworkSample(
            timestamp: Date(),
            download: downloadDelta,
            upload: uploadDelta,
            latency: networkLatency,
            packetLoss: packetLoss
        )

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.networkHistory.append(sample)
            if self.networkHistory.count > self.maxHistorySamples {
                self.networkHistory.removeFirst()
            }
        }
    }

    private func generateInitialHistory() {
        let now = Date()
        for i in stride(from: 60, through: 0, by: -1) {
            let sample = NetworkSample(
                timestamp: now.addingTimeInterval(TimeInterval(-i)),
                download: Double.random(in: 200_000...15_000_000),
                upload: Double.random(in: 50_000...5_000_000),
                latency: Double.random(in: 8...45),
                packetLoss: Double.random(in: 0...2)
            )
            networkHistory.append(sample)
        }
    }

    var signalQuality: String {
        if signalStrength > 0.8 { return "Отлично" }
        if signalStrength > 0.6 { return "Хорошо" }
        if signalStrength > 0.4 { return "Средне" }
        return "Слабо"
    }

    var signalColor: Color {
        if signalStrength > 0.8 { return .v2xGreen }
        if signalStrength > 0.6 { return .v2xCyan }
        if signalStrength > 0.4 { return .v2xYellow }
        return .v2xRed
    }

    var latencyQuality: String {
        if networkLatency < 20 { return "Отлично" }
        if networkLatency < 50 { return "Хорошо" }
        if networkLatency < 100 { return "Средне" }
        return "Плохо"
    }
}

// MARK: - Deep Link Handler
class DeepLinkHandler: ObservableObject {
    static let shared = DeepLinkHandler()

    @Published var pendingAction: DeepLinkAction?
    @Published var lastProcessedURL: URL?

    enum DeepLinkAction {
        case connect
        case disconnect
        case toggle
        case reconnect
        case addConfig(url: String)
        case addCryptConfig(url: String, version: Int)
        case importProtocol(protocol: String)
        case subscribe(url: String)
        case deleteConfig(name: String)
        case exportConfig
        case importClipboard
        case routingAdd(base64: String)
        case routingOnAdd(base64: String)
        case routingOff
        case routingReset
        case routingGeoIPUpdate
        case routingGeoSiteUpdate
        case setTheme(name: String)
        case setDNS(server: String)
        case tunnelPersistent
        case tunnelOnDemand
        case settingsReset
        case quantumOn
        case quantumOff
        case shieldOn
        case shieldOff
        case aiOn
        case aiOff
        case status
    }

    private init() {}

    func handleURL(_ url: URL) {
        guard url.scheme == "v2x" else { return }

        let host = url.host?.lowercased() ?? ""
        let path = url.path
        let pathComponents = path.split(separator: "/").map(String.init)

        lastProcessedURL = url

        switch host {
        case "connect", "open":
            pendingAction = .connect
            VPNManager.shared.connect()

        case "disconnect", "close":
            pendingAction = .disconnect
            VPNManager.shared.disconnect()

        case "toggle":
            pendingAction = .toggle
            VPNManager.shared.toggle()

        case "reconnect":
            pendingAction = .reconnect
            VPNManager.shared.reconnect()

        case "status":
            pendingAction = .status

        case "add":
            let configURL = pathComponents.joined(separator: "/")
            pendingAction = .addConfig(url: configURL)
            ProfileManager.shared.importConfig(from: configURL)

        case "crypt":
            let configURL = pathComponents.joined(separator: "/")
            pendingAction = .addCryptConfig(url: configURL, version: 1)
            ProfileManager.shared.importConfig(from: configURL)

        case "crypt2":
            let configURL = pathComponents.joined(separator: "/")
            pendingAction = .addCryptConfig(url: configURL, version: 2)
            ProfileManager.shared.importConfig(from: configURL)

        case "crypt3":
            let configURL = pathComponents.joined(separator: "/")
            pendingAction = .addCryptConfig(url: configURL, version: 3)
            ProfileManager.shared.importConfig(from: configURL)

        case "subscribe":
            let subURL = pathComponents.joined(separator: "/")
            pendingAction = .subscribe(url: subURL)
            SubscriptionManager.shared.addSubscription(name: "Imported", url: subURL)

        case "delete":
            let name = pathComponents.first ?? ""
            pendingAction = .deleteConfig(name: name)

        case "export":
            pendingAction = .exportConfig

        case "import":
            if let proto = pathComponents.first {
                if proto == "clipboard" {
                    pendingAction = .importClipboard
                } else {
                    pendingAction = .importProtocol(protocol: proto)
                    ProfileManager.shared.showImportSheet(forProtocol: proto)
                }
            }

        case "routing":
            handleRoutingURL(pathComponents: pathComponents)

        case "settings":
            handleSettingsURL(pathComponents: pathComponents)

        case "security":
            handleSecurityURL(pathComponents: pathComponents)

        default:
            break
        }
    }

    private func handleRoutingURL(pathComponents: [String]) {
        guard let action = pathComponents.first else { return }

        switch action {
        case "add":
            let base64 = pathComponents.dropFirst().joined(separator: "/")
            pendingAction = .routingAdd(base64: base64)

        case "onadd":
            let base64 = pathComponents.dropFirst().joined(separator: "/")
            pendingAction = .routingOnAdd(base64: base64)

        case "off":
            pendingAction = .routingOff
            ProfileManager.shared.routingEnabled = false

        case "reset":
            pendingAction = .routingReset

        case "geoip":
            if pathComponents.count > 1 && pathComponents[1] == "update" {
                pendingAction = .routingGeoIPUpdate
            }

        case "geosite":
            if pathComponents.count > 1 && pathComponents[1] == "update" {
                pendingAction = .routingGeoSiteUpdate
            }

        default:
            break
        }
    }

    private func handleSettingsURL(pathComponents: [String]) {
        guard let action = pathComponents.first else { return }

        switch action {
        case "theme":
            if let name = pathComponents.dropFirst().first {
                pendingAction = .setTheme(name: name)
                if let theme = MoodTheme.allCases.first(where: { $0.rawValue.lowercased() == name.lowercased() }) {
                    ThemeManager.shared.setTheme(theme)
                }
            }

        case "dns":
            if let server = pathComponents.dropFirst().first {
                pendingAction = .setDNS(server: server)
            }

        case "tunnel":
            if let mode = pathComponents.dropFirst().first {
                switch mode {
                case "persistent":
                    pendingAction = .tunnelPersistent
                    VPNManager.shared.tunnelMode = .persistent
                case "ondemand":
                    pendingAction = .tunnelOnDemand
                    VPNManager.shared.tunnelMode = .onDemand
                default:
                    break
                }
            }

        case "reset":
            pendingAction = .settingsReset

        default:
            break
        }
    }

    private func handleSecurityURL(pathComponents: [String]) {
        guard let feature = pathComponents.first else { return }
        let action = pathComponents.dropFirst().first

        switch (feature, action) {
        case ("quantum", "on"):
            pendingAction = .quantumOn
            VPNManager.shared.isQuantumStealthEnabled = true

        case ("quantum", "off"):
            pendingAction = .quantumOff
            VPNManager.shared.isQuantumStealthEnabled = false

        case ("shield", "on"):
            pendingAction = .shieldOn
            if !ThreatShield.shared.isEnabled { ThreatShield.shared.toggle() }

        case ("shield", "off"):
            pendingAction = .shieldOff
            if ThreatShield.shared.isEnabled { ThreatShield.shared.toggle() }

        case ("ai", "on"):
            pendingAction = .aiOn
            AISmartConnect.shared.isEnabled = true

        case ("ai", "off"):
            pendingAction = .aiOff
            AISmartConnect.shared.isEnabled = false

        default:
            break
        }
    }
}

// MARK: - Encryption Utilities
struct V2XCrypto {
    static func generateUUID() -> String {
        UUID().uuidString.lowercased()
    }

    static func generateShortID() -> String {
        let chars = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<8).map { _ in chars.randomElement()! })
    }

    static func xorEncrypt(_ data: String, key: String) -> String {
        let dataBytes = Array(data.utf8)
        let keyBytes = Array(key.utf8)
        var result: [UInt8] = []

        for (index, byte) in dataBytes.enumerated() {
            result.append(byte ^ keyBytes[index % keyBytes.count])
        }

        return Data(result).base64EncodedString()
    }

    static func xorDecrypt(_ base64: String, key: String) -> String? {
        guard let data = Data(base64Encoded: base64) else { return nil }
        let dataBytes = Array(data)
        let keyBytes = Array(key.utf8)
        var result: [UInt8] = []

        for (index, byte) in dataBytes.enumerated() {
            result.append(byte ^ keyBytes[index % keyBytes.count])
        }

        return String(bytes: result, encoding: .utf8)
    }

    static func hashConfig(_ config: String) -> String {
        var hash: UInt64 = 5381
        for char in config.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(char)
        }
        return String(format: "%016llx", hash)
    }

    static func validateConfig(_ config: String) -> Bool {
        let schemes = ["vless://", "trojan://", "vmess://", "hysteria2://", "hy2://", "tuic://", "ss://", "wireguard://", "wg://"]
        return schemes.contains { config.lowercased().hasPrefix($0) }
    }

    static func sanitizeServerAddress(_ address: String) -> String {
        var sanitized = address.trimmingCharacters(in: .whitespacesAndNewlines)
        sanitized = sanitized.replacingOccurrences(of: " ", with: "")
        return sanitized
    }

    static func generateRandomPassword(length: Int = 16) -> String {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*"
        return String((0..<length).map { _ in chars.randomElement()! })
    }

    static func obfuscateAddress(_ address: String) -> String {
        let parts = address.split(separator: ".")
        if parts.count == 4 {
            return "\(parts[0]).\(parts[1]).*.*"
        }
        if address.count > 10 {
            return String(address.prefix(5)) + "***" + String(address.suffix(3))
        }
        return "***"
    }
}
