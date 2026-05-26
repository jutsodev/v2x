// NetworkModels.swift
// V2X

import SwiftUI

// MARK: - Server Node
struct ServerNode: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var country: String
    var flag: String
    var address: String
    var port: Int
    var protocolType: String
    var ping: Int?
    var load: Double
    var isOnline: Bool
    var isPremium: Bool

    init(
        id: UUID = UUID(),
        name: String,
        country: String,
        flag: String,
        address: String,
        port: Int = 443,
        protocolType: String = "VLESS",
        ping: Int? = nil,
        load: Double = 0.3,
        isOnline: Bool = true,
        isPremium: Bool = false
    ) {
        self.id = id
        self.name = name
        self.country = country
        self.flag = flag
        self.address = address
        self.port = port
        self.protocolType = protocolType
        self.ping = ping
        self.load = load
        self.isOnline = isOnline
        self.isPremium = isPremium
    }

    var pingColor: Color {
        guard let ping = ping else { return .gray }
        if ping < 50 { return .v2xGreen }
        if ping < 100 { return .v2xYellow }
        return .v2xRed
    }

    var loadColor: Color {
        if load < 0.3 { return .v2xGreen }
        if load < 0.7 { return .v2xYellow }
        return .v2xRed
    }

    var formattedLoad: String {
        "\(Int(load * 100))%"
    }

    static let sampleServers: [ServerNode] = [
        ServerNode(name: "US East 1", country: "United States", flag: "🇺🇸", address: "us-east-1.v2x.io", port: 443, protocolType: "VLESS", ping: 32, load: 0.25, isPremium: true),
        ServerNode(name: "US West 1", country: "United States", flag: "🇺🇸", address: "us-west-1.v2x.io", port: 443, protocolType: "VLESS", ping: 45, load: 0.35),
        ServerNode(name: "Germany 1", country: "Germany", flag: "🇩🇪", address: "de-1.v2x.io", port: 443, protocolType: "Trojan", ping: 28, load: 0.2, isPremium: true),
        ServerNode(name: "Netherlands 1", country: "Netherlands", flag: "🇳🇱", address: "nl-1.v2x.io", port: 443, protocolType: "VLESS", ping: 35, load: 0.4),
        ServerNode(name: "Japan 1", country: "Japan", flag: "🇯🇵", address: "jp-1.v2x.io", port: 443, protocolType: "VMess", ping: 68, load: 0.55),
        ServerNode(name: "Singapore 1", country: "Singapore", flag: "🇸🇬", address: "sg-1.v2x.io", port: 443, protocolType: "Hysteria2", ping: 52, load: 0.3),
        ServerNode(name: "UK London 1", country: "United Kingdom", flag: "🇬🇧", address: "uk-1.v2x.io", port: 443, protocolType: "TUIC", ping: 42, load: 0.45),
        ServerNode(name: "France 1", country: "France", flag: "🇫🇷", address: "fr-1.v2x.io", port: 443, protocolType: "Shadowsocks", ping: 38, load: 0.3),
        ServerNode(name: "Canada 1", country: "Canada", flag: "🇨🇦", address: "ca-1.v2x.io", port: 443, protocolType: "WireGuard", ping: 55, load: 0.6),
        ServerNode(name: "Australia 1", country: "Australia", flag: "🇦🇺", address: "au-1.v2x.io", port: 443, protocolType: "VLESS+Reality", ping: 120, load: 0.15),
    ]
}

// MARK: - DNS Configuration
struct DNSConfiguration: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var primaryDNS: String
    var secondaryDNS: String
    var dnsOverHTTPS: String
    var dnsOverTLS: String
    var type: DNSType
    var isCustom: Bool

    init(
        id: UUID = UUID(),
        name: String,
        primaryDNS: String,
        secondaryDNS: String = "",
        dnsOverHTTPS: String = "",
        dnsOverTLS: String = "",
        type: DNSType = .standard,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.primaryDNS = primaryDNS
        self.secondaryDNS = secondaryDNS
        self.dnsOverHTTPS = dnsOverHTTPS
        self.dnsOverTLS = dnsOverTLS
        self.type = type
        self.isCustom = isCustom
    }

    enum DNSType: String, Codable, CaseIterable, Hashable {
        case standard = "Standard"
        case doh = "DoH"
        case dot = "DoT"
        case dnscrypt = "DNSCrypt"
    }

    static let presets: [DNSConfiguration] = [
        DNSConfiguration(name: "Cloudflare", primaryDNS: "1.1.1.1", secondaryDNS: "1.0.0.1", dnsOverHTTPS: "https://cloudflare-dns.com/dns-query", type: .doh),
        DNSConfiguration(name: "Google", primaryDNS: "8.8.8.8", secondaryDNS: "8.8.4.4", dnsOverHTTPS: "https://dns.google/dns-query", type: .doh),
        DNSConfiguration(name: "Quad9", primaryDNS: "9.9.9.9", secondaryDNS: "149.112.112.112", dnsOverHTTPS: "https://dns.quad9.net/dns-query", type: .doh),
        DNSConfiguration(name: "AdGuard", primaryDNS: "94.140.14.14", secondaryDNS: "94.140.15.15", dnsOverHTTPS: "https://dns.adguard-dns.com/dns-query", type: .doh),
        DNSConfiguration(name: "NextDNS", primaryDNS: "45.90.28.167", secondaryDNS: "45.90.30.167", dnsOverHTTPS: "https://dns.nextdns.io", type: .doh),
        DNSConfiguration(name: "OpenDNS", primaryDNS: "208.67.222.222", secondaryDNS: "208.67.220.220", type: .standard),
        DNSConfiguration(name: "Comodo Secure", primaryDNS: "8.26.56.26", secondaryDNS: "8.20.247.20", type: .standard),
        DNSConfiguration(name: "Yandex DNS", primaryDNS: "77.88.8.8", secondaryDNS: "77.88.8.1", type: .standard),
    ]
}

// MARK: - Routing Rule
struct RoutingRule: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var domain: String
    var action: RoutingAction
    var isEnabled: Bool
    var priority: Int

    init(
        id: UUID = UUID(),
        name: String,
        domain: String,
        action: RoutingAction = .proxy,
        isEnabled: Bool = true,
        priority: Int = 0
    ) {
        self.id = id
        self.name = name
        self.domain = domain
        self.action = action
        self.isEnabled = isEnabled
        self.priority = priority
    }

    enum RoutingAction: String, Codable, CaseIterable, Hashable {
        case proxy = "Proxy"
        case direct = "Direct"
        case block = "Block"
    }

    static let defaults: [RoutingRule] = [
        RoutingRule(name: "Block Ads", domain: "*.doubleclick.net", action: .block, priority: 1),
        RoutingRule(name: "Direct LAN", domain: "192.168.0.0/16", action: .direct, priority: 2),
        RoutingRule(name: "Direct Localhost", domain: "localhost", action: .direct, priority: 3),
        RoutingRule(name: "Proxy All", domain: "*", action: .proxy, priority: 100),
        RoutingRule(name: "Block Trackers", domain: "*.analytics.google.com", action: .block, priority: 1),
        RoutingRule(name: "Direct Apple", domain: "*.apple.com", action: .direct, priority: 5),
    ]
}

// MARK: - GeoFile
struct GeoFile: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var fileName: String
    var url: String
    var size: String
    var lastUpdated: Date?
    var isUpdating: Bool

    init(
        id: UUID = UUID(),
        name: String,
        fileName: String,
        url: String = "",
        size: String = "0 KB",
        lastUpdated: Date? = Date(),
        isUpdating: Bool = false
    ) {
        self.id = id
        self.name = name
        self.fileName = fileName
        self.url = url
        self.size = size
        self.lastUpdated = lastUpdated
        self.isUpdating = isUpdating
    }

    static let defaults: [GeoFile] = [
        GeoFile(name: "GeoIP Database", fileName: "geoip.dat", url: "https://github.com/v2fly/geoip/releases/latest", size: "4.2 MB", lastUpdated: Date()),
        GeoFile(name: "GeoSite Database", fileName: "geosite.dat", url: "https://github.com/v2fly/domain-list-community/releases/latest", size: "2.8 MB", lastUpdated: Date()),
        GeoFile(name: "GeoIP Country", fileName: "country.mmdb", url: "https://github.com/Loyalsoldier/geoip/releases/latest", size: "5.1 MB", lastUpdated: Date()),
    ]
}

// MARK: - V2X Subscription
struct V2XSubscription: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var url: String
    var profileCount: Int
    var lastUpdated: Date?
    var isAutoUpdate: Bool
    var autoUpdateInterval: Int
    var userAgent: String

    init(
        id: UUID = UUID(),
        name: String,
        url: String,
        profileCount: Int = 0,
        lastUpdated: Date? = nil,
        isAutoUpdate: Bool = true,
        autoUpdateInterval: Int = 3600,
        userAgent: String = "V2X/1.0"
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.profileCount = profileCount
        self.lastUpdated = lastUpdated
        self.isAutoUpdate = isAutoUpdate
        self.autoUpdateInterval = autoUpdateInterval
        self.userAgent = userAgent
    }

    static let sample = V2XSubscription(
        name: "V2X Premium",
        url: "https://sub.v2x.network/premium",
        profileCount: 12,
        lastUpdated: Date(),
        isAutoUpdate: true,
        autoUpdateInterval: 3600
    )
}

// MARK: - Import Result
struct ImportResult: Identifiable {
    let id = UUID()
    let success: Bool
    let profileCount: Int
    let profiles: [VPNProfile]
    let error: String?
    let timestamp: Date

    init(
        success: Bool,
        profileCount: Int = 0,
        profiles: [VPNProfile] = [],
        error: String? = nil
    ) {
        self.success = success
        self.profileCount = profileCount
        self.profiles = profiles
        self.error = error
        self.timestamp = Date()
    }
}

// MARK: - Threat Event
struct ThreatEvent: Identifiable {
    let id = UUID()
    let type: ThreatType
    let domain: String
    let timestamp: Date
    let severity: ThreatSeverity

    enum ThreatType: String, CaseIterable {
        case tracker = "Трекер"
        case ad = "Реклама"
        case malware = "Malware"
        case phishing = "Phishing"
        case crypto = "Криптомайнер"
        case fingerprint = "Fingerprinting"

        var icon: String {
            switch self {
            case .tracker: return "eye.slash.fill"
            case .ad: return "xmark.rectangle.fill"
            case .malware: return "ladybug.fill"
            case .phishing: return "exclamationmark.shield.fill"
            case .crypto: return "bitcoinsign.circle.fill"
            case .fingerprint: return "hand.raised.fill"
            }
        }

        var color: Color {
            switch self {
            case .tracker: return .v2xPurple
            case .ad: return .v2xYellow
            case .malware: return .v2xRed
            case .phishing: return .v2xOrange
            case .crypto: return .v2xCyan
            case .fingerprint: return .v2xGreen
            }
        }
    }

    enum ThreatSeverity: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"

        var color: Color {
            switch self {
            case .low: return .v2xGreen
            case .medium: return .v2xYellow
            case .high: return .v2xOrange
            case .critical: return .v2xRed
            }
        }
    }

    static let sampleDomains: [String] = [
        "tracking.google-analytics.com",
        "ads.doubleclick.net",
        "pixel.facebook.com",
        "sb.scorecardresearch.com",
        "cdn.mxpnl.com",
        "adservice.google.com",
        "pagead2.googlesyndication.com",
        "stats.wp.com",
        "beacon.krxd.net",
        "tags.tiqcdn.com",
        "analytics.tiktok.com",
        "ct.pinterest.com",
        "bat.bing.com",
        "mc.yandex.ru",
        "counter.yadro.ru",
        "malware.badsite.ru",
        "phish.evil.com",
        "cryptominer.js.pool",
        "fp.device.collector",
        "tracker.ads.network",
    ]
}

// MARK: - Connection Statistics
struct ConnectionStatistics: Codable {
    var sessionUpload: Double
    var sessionDownload: Double
    var totalUpload: Double
    var totalDownload: Double
    var currentUploadSpeed: Double
    var currentDownloadSpeed: Double
    var peakUploadSpeed: Double
    var peakDownloadSpeed: Double
    var connectionStartTime: Date?
    var packetsIn: Int
    var packetsOut: Int
    var ping: Int

    init() {
        self.sessionUpload = 628.14 * 1024 * 1024
        self.sessionDownload = 5.52 * 1024 * 1024 * 1024
        self.totalUpload = 4.24 * 1024 * 1024 * 1024 * 1024
        self.totalDownload = 9.76 * 1024 * 1024 * 1024 * 1024
        self.currentUploadSpeed = 2.4 * 1024 * 1024
        self.currentDownloadSpeed = 12.8 * 1024 * 1024
        self.peakUploadSpeed = 15.2 * 1024 * 1024
        self.peakDownloadSpeed = 85.6 * 1024 * 1024
        self.connectionStartTime = Date().addingTimeInterval(-868)
        self.packetsIn = 1_542_867
        self.packetsOut = 892_341
        self.ping = 32
    }

    var formattedUploadSpeed: String {
        String.formatSpeed(currentUploadSpeed)
    }

    var formattedDownloadSpeed: String {
        String.formatSpeed(currentDownloadSpeed)
    }

    var connectionDuration: TimeInterval {
        guard let start = connectionStartTime else { return 0 }
        return Date().timeIntervalSince(start)
    }

    var formattedDuration: String {
        String.formatDuration(connectionDuration)
    }
}
