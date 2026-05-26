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
