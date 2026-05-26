// VPNProfile.swift
// V2X

import Foundation
import SwiftUI

// MARK: - VPN Protocol Types
enum VPNProtocolType: String, CaseIterable, Codable, Identifiable {
    case vless = "VLESS"
    case trojan = "Trojan"
    case vmess = "VMess"
    case vlessReality = "VLESS+Reality"
    case hysteria2 = "Hysteria2"
    case tuic = "TUIC"
    case shadowsocks = "Shadowsocks"
    case wireguard = "WireGuard"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .vless: return "bolt.shield.fill"
        case .trojan: return "shield.lefthalf.filled"
        case .vmess: return "lock.shield.fill"
        case .vlessReality: return "sparkle.magnifyingglass"
        case .hysteria2: return "waveform.path.ecg"
        case .tuic: return "network.badge.shield.half.filled"
        case .shadowsocks: return "moon.fill"
        case .wireguard: return "antenna.radiowaves.left.and.right"
        }
    }

    var color: Color {
        switch self {
        case .vless: return Color(hex: "00F5FF")
        case .trojan: return Color(hex: "FF6B6B")
        case .vmess: return Color(hex: "B026FF")
        case .vlessReality: return Color(hex: "00FF9D")
        case .hysteria2: return Color(hex: "FFD93D")
        case .tuic: return Color(hex: "6BCB77")
        case .shadowsocks: return Color(hex: "4D96FF")
        case .wireguard: return Color(hex: "FF6B6B")
        }
    }

    var urlScheme: String {
        switch self {
        case .vless, .vlessReality: return "vless://"
        case .trojan: return "trojan://"
        case .vmess: return "vmess://"
        case .hysteria2: return "hysteria2://"
        case .tuic: return "tuic://"
        case .shadowsocks: return "ss://"
        case .wireguard: return "wireguard://"
        }
    }
}

// MARK: - VPN Profile
struct VPNProfile: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var serverAddress: String
    var port: Int
    var protocolType: VPNProtocolType
    var uuid: String
    var encryption: String
    var network: String
    var security: String
    var sni: String
    var fingerprint: String
    var publicKey: String
    var shortId: String
    var flow: String
    var rawConfig: String
    var isActive: Bool
    var lastConnected: Date?
    var ping: Int?
    var uploadBytes: Int64
    var downloadBytes: Int64
    var createdAt: Date
    var tags: [String]

    init(
        id: UUID = UUID(),
        name: String = "New Profile",
        serverAddress: String = "",
        port: Int = 443,
        protocolType: VPNProtocolType = .vless,
        uuid: String = "",
        encryption: String = "none",
        network: String = "tcp",
        security: String = "tls",
        sni: String = "",
        fingerprint: String = "chrome",
        publicKey: String = "",
        shortId: String = "",
        flow: String = "xtls-rprx-vision",
        rawConfig: String = "",
        isActive: Bool = false,
        lastConnected: Date? = nil,
        ping: Int? = nil,
        uploadBytes: Int64 = 0,
        downloadBytes: Int64 = 0,
        createdAt: Date = Date(),
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.serverAddress = serverAddress
        self.port = port
        self.protocolType = protocolType
        self.uuid = uuid
        self.encryption = encryption
        self.network = network
        self.security = security
        self.sni = sni
        self.fingerprint = fingerprint
        self.publicKey = publicKey
        self.shortId = shortId
        self.flow = flow
        self.rawConfig = rawConfig
        self.isActive = isActive
        self.lastConnected = lastConnected
        self.ping = ping
        self.uploadBytes = uploadBytes
        self.downloadBytes = downloadBytes
        self.createdAt = createdAt
        self.tags = tags
    }

    var displayAddress: String {
        "\(serverAddress):\(port)"
    }

    var formattedPing: String {
        guard let ping = ping else { return "—" }
        return "\(ping) ms"
    }

    static let preview = VPNProfile(
        name: "V2X Ultra",
        serverAddress: "ultra.v2x.network",
        port: 443,
        protocolType: .vlessReality,
        uuid: "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
        sni: "www.google.com",
        isActive: true,
        ping: 24,
        uploadBytes: 658_737_049,
        downloadBytes: 5_926_248_448
    )

    static let samples: [VPNProfile] = [
        VPNProfile(
            name: "V2X Ultra",
            serverAddress: "ultra.v2x.network",
            port: 443,
            protocolType: .vlessReality,
            isActive: true,
            ping: 24
        ),
        VPNProfile(
            name: "Frankfurt DE",
            serverAddress: "de.v2x.network",
            port: 2083,
            protocolType: .trojan,
            ping: 48
        ),
        VPNProfile(
            name: "Tokyo JP",
            serverAddress: "jp.v2x.network",
            port: 443,
            protocolType: .hysteria2,
            ping: 89
        ),
        VPNProfile(
            name: "Singapore SG",
            serverAddress: "sg.v2x.network",
            port: 443,
            protocolType: .vless,
            ping: 112
        ),
        VPNProfile(
            name: "New York US",
            serverAddress: "us.v2x.network",
            port: 8443,
            protocolType: .vmess,
            ping: 156
        ),
        VPNProfile(
            name: "London UK WireGuard",
            serverAddress: "uk.v2x.network",
            port: 51820,
            protocolType: .wireguard,
            ping: 67
        )
    ]
}

// MARK: - Connection State
enum ConnectionState: String, Equatable {
    case disconnected = "Отключено"
    case connecting = "Подключение..."
    case connected = "Подключено"
    case disconnecting = "Отключение..."
    case error = "Ошибка"

    var color: Color {
        switch self {
        case .disconnected: return .gray
        case .connecting: return Color(hex: "FFD93D")
        case .connected: return Color(hex: "00FF9D")
        case .disconnecting: return Color(hex: "FFD93D")
        case .error: return Color(hex: "FF4444")
        }
    }

    var icon: String {
        switch self {
        case .disconnected: return "power"
        case .connecting: return "arrow.triangle.2.circlepath"
        case .connected: return "pause.fill"
        case .disconnecting: return "arrow.triangle.2.circlepath"
        case .error: return "exclamationmark.triangle.fill"
        }
    }

    var isTransitioning: Bool {
        self == .connecting || self == .disconnecting
    }
}

// MARK: - Server Node
struct ServerNode: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var country: String
    var countryCode: String
    var city: String
    var address: String
    var port: Int
    var protocolType: VPNProtocolType
    var load: Double
    var ping: Int
    var isOnline: Bool
    var isPremium: Bool
    var maxSpeed: String

    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        countryCode: String,
        city: String,
        address: String,
        port: Int = 443,
        protocolType: VPNProtocolType = .vless,
        load: Double = 0.0,
        ping: Int = 0,
        isOnline: Bool = true,
        isPremium: Bool = false,
        maxSpeed: String = "1 Gbps"
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.countryCode = countryCode
        self.city = city
        self.address = address
        self.port = port
        self.protocolType = protocolType
        self.load = load
        self.ping = ping
        self.isOnline = isOnline
        self.isPremium = isPremium
        self.maxSpeed = maxSpeed
    }

    var flag: String {
        let base: UInt32 = 127397
        return countryCode.uppercased().unicodeScalars.reduce("") {
            $0 + String(UnicodeScalar(base + $1.value)!)
        }
    }

    var loadPercentage: String {
        "\(Int(load * 100))%"
    }

    var loadColor: Color {
        if load < 0.3 { return Color(hex: "00FF9D") }
        if load < 0.7 { return Color(hex: "FFD93D") }
        return Color(hex: "FF4444")
    }

    static let samples: [ServerNode] = [
        ServerNode(name: "Frankfurt Ultra", country: "Germany", countryCode: "DE", city: "Frankfurt", address: "de1.v2x.net", load: 0.23, ping: 24, isPremium: true),
        ServerNode(name: "Tokyo Fast", country: "Japan", countryCode: "JP", city: "Tokyo", address: "jp1.v2x.net", load: 0.45, ping: 89),
        ServerNode(name: "Singapore", country: "Singapore", countryCode: "SG", city: "Singapore", address: "sg1.v2x.net", load: 0.12, ping: 56, isPremium: true),
        ServerNode(name: "New York", country: "United States", countryCode: "US", city: "New York", address: "us1.v2x.net", load: 0.67, ping: 156),
        ServerNode(name: "London", country: "United Kingdom", countryCode: "GB", city: "London", address: "uk1.v2x.net", load: 0.34, ping: 67, isPremium: true),
        ServerNode(name: "Amsterdam", country: "Netherlands", countryCode: "NL", city: "Amsterdam", address: "nl1.v2x.net", load: 0.55, ping: 42)
    ]
}

// MARK: - Traffic Stats
struct TrafficStats: Equatable {
    var uploadBytes: Int64
    var downloadBytes: Int64
    var totalBytes: Int64
    var uploadSpeed: Double
    var downloadSpeed: Double
    var connectedSince: Date?
    var sessionUpload: Int64
    var sessionDownload: Int64

    init(
        uploadBytes: Int64 = 0,
        downloadBytes: Int64 = 0,
        totalBytes: Int64 = 0,
        uploadSpeed: Double = 0,
        downloadSpeed: Double = 0,
        connectedSince: Date? = nil,
        sessionUpload: Int64 = 0,
        sessionDownload: Int64 = 0
    ) {
        self.uploadBytes = uploadBytes
        self.downloadBytes = downloadBytes
        self.totalBytes = totalBytes
        self.uploadSpeed = uploadSpeed
        self.downloadSpeed = downloadSpeed
        self.connectedSince = connectedSince
        self.sessionUpload = sessionUpload
        self.sessionDownload = sessionDownload
    }

    var formattedUpload: String {
        ByteCountFormatter.string(fromByteCount: uploadBytes, countStyle: .binary)
    }

    var formattedDownload: String {
        ByteCountFormatter.string(fromByteCount: downloadBytes, countStyle: .binary)
    }

    var formattedTotal: String {
        ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .binary)
    }

    var formattedUploadSpeed: String {
        ByteCountFormatter.string(fromByteCount: Int64(uploadSpeed), countStyle: .binary) + "/s"
    }

    var formattedDownloadSpeed: String {
        ByteCountFormatter.string(fromByteCount: Int64(downloadSpeed), countStyle: .binary) + "/s"
    }

    var connectionDuration: TimeInterval {
        guard let since = connectedSince else { return 0 }
        return Date().timeIntervalSince(since)
    }

    static let preview = TrafficStats(
        uploadBytes: 658_737_049,
        downloadBytes: 5_926_248_448,
        totalBytes: 10_737_418_240,
        uploadSpeed: 2_500_000,
        downloadSpeed: 15_000_000,
        connectedSince: Date().addingTimeInterval(-868),
        sessionUpload: 128_000_000,
        sessionDownload: 512_000_000
    )
}

// MARK: - DNS Configuration
struct DNSConfiguration: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var primaryDNS: String
    var secondaryDNS: String
    var dnsOverHTTPS: String
    var dnsOverTLS: String
    var isActive: Bool
    var type: DNSType

    enum DNSType: String, Codable, CaseIterable {
        case standard = "Standard"
        case doh = "DNS-over-HTTPS"
        case dot = "DNS-over-TLS"
        case custom = "Custom"
    }

    init(
        id: UUID = UUID(),
        name: String = "Default",
        primaryDNS: String = "1.1.1.1",
        secondaryDNS: String = "8.8.8.8",
        dnsOverHTTPS: String = "https://cloudflare-dns.com/dns-query",
        dnsOverTLS: String = "tls://dns.google",
        isActive: Bool = false,
        type: DNSType = .standard
    ) {
        self.id = id
        self.name = name
        self.primaryDNS = primaryDNS
        self.secondaryDNS = secondaryDNS
        self.dnsOverHTTPS = dnsOverHTTPS
        self.dnsOverTLS = dnsOverTLS
        self.isActive = isActive
        self.type = type
    }

    static let presets: [DNSConfiguration] = [
        DNSConfiguration(name: "Cloudflare", primaryDNS: "1.1.1.1", secondaryDNS: "1.0.0.1", dnsOverHTTPS: "https://cloudflare-dns.com/dns-query", dnsOverTLS: "tls://one.one.one.one", type: .doh),
        DNSConfiguration(name: "Google", primaryDNS: "8.8.8.8", secondaryDNS: "8.8.4.4", dnsOverHTTPS: "https://dns.google/dns-query", dnsOverTLS: "tls://dns.google", type: .doh),
        DNSConfiguration(name: "Quad9", primaryDNS: "9.9.9.9", secondaryDNS: "149.112.112.112", dnsOverHTTPS: "https://dns.quad9.net/dns-query", dnsOverTLS: "tls://dns.quad9.net", type: .doh),
        DNSConfiguration(name: "AdGuard", primaryDNS: "94.140.14.14", secondaryDNS: "94.140.15.15", dnsOverHTTPS: "https://dns.adguard-dns.com/dns-query", dnsOverTLS: "tls://dns.adguard-dns.com", type: .doh),
    ]
}

// MARK: - Routing Rule
struct RoutingRule: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var domain: String
    var action: RoutingAction
    var isEnabled: Bool

    enum RoutingAction: String, Codable, CaseIterable {
        case proxy = "Прокси"
        case direct = "Прямое"
        case block = "Блокировать"
    }

    init(
        id: UUID = UUID(),
        name: String = "",
        domain: String = "",
        action: RoutingAction = .proxy,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.domain = domain
        self.action = action
        self.isEnabled = isEnabled
    }

    static let samples: [RoutingRule] = [
        RoutingRule(name: "Google", domain: "*.google.com", action: .proxy, isEnabled: true),
        RoutingRule(name: "YouTube", domain: "*.youtube.com", action: .proxy, isEnabled: true),
        RoutingRule(name: "Telegram", domain: "*.telegram.org", action: .proxy, isEnabled: true),
        RoutingRule(name: "Local Network", domain: "192.168.*.*", action: .direct, isEnabled: true),
        RoutingRule(name: "Ads", domain: "*.doubleclick.net", action: .block, isEnabled: true),
    ]
}

// MARK: - GeoFile
struct GeoFile: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var fileName: String
    var size: String
    var lastUpdated: Date
    var downloadURL: String
    var isDownloaded: Bool

    static let defaults: [GeoFile] = [
        GeoFile(name: "GeoIP Database", fileName: "geoip.dat", size: "5.2 MB", lastUpdated: Date(), downloadURL: "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat", isDownloaded: true),
        GeoFile(name: "GeoSite Database", fileName: "geosite.dat", size: "8.1 MB", lastUpdated: Date(), downloadURL: "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat", isDownloaded: true),
    ]
}

// MARK: - Subscription
struct V2XSubscription: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var url: String
    var lastUpdated: Date?
    var profileCount: Int
    var isActive: Bool
    var autoUpdate: Bool
    var updateInterval: Int // in hours

    init(
        id: UUID = UUID(),
        name: String = "",
        url: String = "",
        lastUpdated: Date? = nil,
        profileCount: Int = 0,
        isActive: Bool = true,
        autoUpdate: Bool = true,
        updateInterval: Int = 24
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.lastUpdated = lastUpdated
        self.profileCount = profileCount
        self.isActive = isActive
        self.autoUpdate = autoUpdate
        self.updateInterval = updateInterval
    }

    static let sample = V2XSubscription(
        name: "V2X Premium",
        url: "https://sub.v2x.network/api/v1/client/subscribe",
        lastUpdated: Date(),
        profileCount: 12,
        isActive: true
    )
}

// MARK: - Threat Shield Event
struct ThreatEvent: Identifiable {
    let id = UUID()
    var type: ThreatType
    var source: String
    var timestamp: Date
    var blocked: Bool

    enum ThreatType: String, CaseIterable {
        case tracker = "Трекер"
        case ad = "Реклама"
        case malware = "Malware"
        case phishing = "Фишинг"

        var icon: String {
            switch self {
            case .tracker: return "eye.slash.fill"
            case .ad: return "nosign"
            case .malware: return "ladybug.fill"
            case .phishing: return "exclamationmark.shield.fill"
            }
        }

        var color: Color {
            switch self {
            case .tracker: return Color(hex: "FFD93D")
            case .ad: return Color(hex: "4D96FF")
            case .malware: return Color(hex: "FF4444")
            case .phishing: return Color(hex: "FF6B6B")
            }
        }
    }
}

// MARK: - Log Entry
struct LogEntry: Identifiable {
    let id = UUID()
    var timestamp: Date
    var level: LogLevel
    var message: String
    var source: String

    enum LogLevel: String {
        case info = "INFO"
        case warning = "WARN"
        case error = "ERROR"
        case debug = "DEBUG"

        var color: Color {
            switch self {
            case .info: return Color(hex: "00F5FF")
            case .warning: return Color(hex: "FFD93D")
            case .error: return Color(hex: "FF4444")
            case .debug: return .gray
            }
        }
    }

    static let samples: [LogEntry] = [
        LogEntry(timestamp: Date(), level: .info, message: "VPN tunnel established successfully", source: "TunnelManager"),
        LogEntry(timestamp: Date().addingTimeInterval(-5), level: .info, message: "Connected to ultra.v2x.network:443", source: "CoreTransport"),
        LogEntry(timestamp: Date().addingTimeInterval(-10), level: .debug, message: "TLS handshake completed with VLESS+Reality", source: "SecurityLayer"),
        LogEntry(timestamp: Date().addingTimeInterval(-15), level: .info, message: "DNS resolver initialized: 1.1.1.1", source: "DNSModule"),
        LogEntry(timestamp: Date().addingTimeInterval(-20), level: .warning, message: "High latency detected: 245ms to jp1.v2x.net", source: "PingMonitor"),
        LogEntry(timestamp: Date().addingTimeInterval(-30), level: .info, message: "Routing rules loaded: 342 rules active", source: "RoutingEngine"),
        LogEntry(timestamp: Date().addingTimeInterval(-45), level: .debug, message: "Quantum stealth obfuscation layer active", source: "StealthModule"),
        LogEntry(timestamp: Date().addingTimeInterval(-60), level: .info, message: "Threat Shield enabled — blocking ads, trackers, malware", source: "ThreatShield"),
    ]
}
