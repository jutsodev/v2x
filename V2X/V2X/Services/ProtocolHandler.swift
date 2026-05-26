// ProtocolHandler.swift
// V2X

import SwiftUI
import Combine

class ProtocolHandler: ObservableObject {
    static let shared = ProtocolHandler()

    @Published var activeProtocol: VPNProtocolType = .vless
    @Published var transportType: TransportType = .tcp
    @Published var security: SecurityType = .tls
    @Published var alpn: [String] = ["h2", "http/1.1"]
    @Published var fingerprint: String = "chrome"
    @Published var serverName: String = ""
    @Published var path: String = "/"
    @Published var host: String = ""
    @Published var obfsType: ObfuscationType = .none
    @Published var mux: Bool = false
    @Published var muxConcurrency: Int = 8
    @Published var realityPublicKey: String = ""
    @Published var realityShortId: String = ""
    @Published var realitySpiderX: String = ""
    @Published var allowInsecure: Bool = false
    @Published var fragment: Bool = false
    @Published var fragmentSize: String = "100-200"
    @Published var fragmentInterval: String = "10-20"

    enum TransportType: String, CaseIterable, Identifiable {
        case tcp = "TCP"
        case ws = "WebSocket"
        case grpc = "gRPC"
        case http = "HTTP/2"
        case quic = "QUIC"
        case httpupgrade = "HTTPUpgrade"
        case splithttp = "SplitHTTP"
        case kcp = "mKCP"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .tcp: return "cable.connector"
            case .ws: return "globe"
            case .grpc: return "arrow.triangle.branch"
            case .http: return "network"
            case .quic: return "bolt"
            case .httpupgrade: return "arrow.up.forward"
            case .splithttp: return "rectangle.split.2x1"
            case .kcp: return "wave.3.right"
            }
        }

        var supportsPath: Bool {
            self == .ws || self == .http || self == .httpupgrade || self == .splithttp
        }

        var supportsHost: Bool {
            self == .ws || self == .http || self == .httpupgrade || self == .splithttp
        }
    }

    enum SecurityType: String, CaseIterable, Identifiable {
        case none = "None"
        case tls = "TLS"
        case reality = "REALITY"
        case xtls = "XTLS"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .none: return "lock.open"
            case .tls: return "lock.fill"
            case .reality: return "lock.shield.fill"
            case .xtls: return "lock.trianglebadge.exclamationmark.fill"
            }
        }

        var color: Color {
            switch self {
            case .none: return .gray
            case .tls: return .v2xGreen
            case .reality: return .v2xPurple
            case .xtls: return .v2xCyan
            }
        }
    }

    enum ObfuscationType: String, CaseIterable, Identifiable {
        case none = "None"
        case http = "HTTP"
        case tls = "TLS"
        case quic = "QUIC"

        var id: String { rawValue }
    }

    private init() {}

    func buildVLESSConfig(uuid: String, address: String, port: Int) -> String {
        var params: [String] = []
        params.append("type=\(transportType.rawValue.lowercased())")
        params.append("security=\(security.rawValue.lowercased())")

        if security == .tls || security == .reality {
            if !serverName.isEmpty {
                params.append("sni=\(serverName)")
            }
            if !fingerprint.isEmpty {
                params.append("fp=\(fingerprint)")
            }
            if !alpn.isEmpty {
                params.append("alpn=\(alpn.joined(separator: ","))")
            }
        }

        if security == .reality {
            if !realityPublicKey.isEmpty {
                params.append("pbk=\(realityPublicKey)")
            }
            if !realityShortId.isEmpty {
                params.append("sid=\(realityShortId)")
            }
            if !realitySpiderX.isEmpty {
                params.append("spx=\(realitySpiderX)")
            }
        }

        if transportType.supportsPath && !path.isEmpty {
            params.append("path=\(path)")
        }
        if transportType.supportsHost && !host.isEmpty {
            params.append("host=\(host)")
        }

        if fragment {
            params.append("fragment=\(fragmentSize),\(fragmentInterval)")
        }

        let queryString = params.joined(separator: "&")
        return "vless://\(uuid)@\(address):\(port)?\(queryString)#V2X%20Server"
    }

    func buildTrojanConfig(password: String, address: String, port: Int) -> String {
        var params: [String] = []
        params.append("type=\(transportType.rawValue.lowercased())")
        params.append("security=\(security.rawValue.lowercased())")

        if !serverName.isEmpty {
            params.append("sni=\(serverName)")
        }
        if !fingerprint.isEmpty {
            params.append("fp=\(fingerprint)")
        }
        if !alpn.isEmpty {
            params.append("alpn=\(alpn.joined(separator: ","))")
        }

        if transportType.supportsPath && !path.isEmpty {
            params.append("path=\(path)")
        }
        if transportType.supportsHost && !host.isEmpty {
            params.append("host=\(host)")
        }

        let queryString = params.joined(separator: "&")
        return "trojan://\(password)@\(address):\(port)?\(queryString)#V2X%20Trojan"
    }

    func buildVMessConfig(uuid: String, address: String, port: Int, alterId: Int = 0) -> String {
        let config: [String: Any] = [
            "v": "2",
            "ps": "V2X VMess",
            "add": address,
            "port": "\(port)",
            "id": uuid,
            "aid": "\(alterId)",
            "net": transportType.rawValue.lowercased(),
            "type": "none",
            "host": host,
            "path": path,
            "tls": security == .tls ? "tls" : "",
            "sni": serverName,
            "alpn": alpn.joined(separator: ","),
            "fp": fingerprint
        ]

        if let jsonData = try? JSONSerialization.data(withJSONObject: config),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return "vmess://\(jsonString.base64Encoded)"
        }
        return ""
    }

    func buildHysteria2Config(password: String, address: String, port: Int) -> String {
        var params: [String] = []
        if !serverName.isEmpty {
            params.append("sni=\(serverName)")
        }
        params.append("insecure=\(allowInsecure ? "1" : "0")")
        if !alpn.isEmpty {
            params.append("alpn=\(alpn.joined(separator: ","))")
        }

        let queryString = params.joined(separator: "&")
        return "hysteria2://\(password)@\(address):\(port)?\(queryString)#V2X%20Hysteria2"
    }

    func buildTUICConfig(uuid: String, password: String, address: String, port: Int) -> String {
        var params: [String] = []
        if !serverName.isEmpty {
            params.append("sni=\(serverName)")
        }
        params.append("congestion_control=bbr")
        params.append("udp_relay_mode=native")
        if !alpn.isEmpty {
            params.append("alpn=\(alpn.joined(separator: ","))")
        }

        let queryString = params.joined(separator: "&")
        return "tuic://\(uuid):\(password)@\(address):\(port)?\(queryString)#V2X%20TUIC"
    }

    func buildShadowsocksConfig(password: String, method: String, address: String, port: Int) -> String {
        let userInfo = "\(method):\(password)".base64Encoded
        return "ss://\(userInfo)@\(address):\(port)#V2X%20Shadowsocks"
    }

    func buildWireGuardConfig(privateKey: String, publicKey: String, address: String, port: Int, endpoint: String) -> String {
        var params: [String] = []
        params.append("publickey=\(publicKey)")
        params.append("address=\(address)")
        params.append("mtu=1280")

        let queryString = params.joined(separator: "&")
        return "wireguard://\(privateKey)@\(endpoint):\(port)?\(queryString)#V2X%20WireGuard"
    }

    func getAvailableTransports(for protocol: VPNProtocolType) -> [TransportType] {
        switch `protocol` {
        case .vless, .vlessReality:
            return [.tcp, .ws, .grpc, .http, .quic, .httpupgrade, .splithttp, .kcp]
        case .trojan:
            return [.tcp, .ws, .grpc, .http]
        case .vmess:
            return [.tcp, .ws, .grpc, .http, .quic, .kcp]
        case .hysteria2:
            return [.quic]
        case .tuic:
            return [.quic]
        case .shadowsocks:
            return [.tcp, .ws]
        case .wireguard:
            return [.quic]
        }
    }

    func getAvailableSecurity(for protocol: VPNProtocolType) -> [SecurityType] {
        switch `protocol` {
        case .vless:
            return [.none, .tls, .reality, .xtls]
        case .vlessReality:
            return [.reality]
        case .trojan:
            return [.tls]
        case .vmess:
            return [.none, .tls]
        case .hysteria2:
            return [.tls]
        case .tuic:
            return [.tls]
        case .shadowsocks:
            return [.none, .tls]
        case .wireguard:
            return [.none]
        }
    }

    static let availableFingerprints = [
        "chrome", "firefox", "safari", "edge",
        "ios", "android", "random", "randomized",
        "chrome_120", "chrome_115", "chrome_110",
        "firefox_120", "firefox_115",
        "safari_17", "safari_16",
        "edge_120"
    ]

    static let availableALPN = [
        "h2", "http/1.1", "h3", "h3-29"
    ]

    static let shadowsocksMethods = [
        "aes-256-gcm", "aes-128-gcm",
        "chacha20-ietf-poly1305",
        "2022-blake3-aes-256-gcm",
        "2022-blake3-aes-128-gcm",
        "2022-blake3-chacha20-poly1305",
        "xchacha20-ietf-poly1305",
        "none"
    ]
}

// MARK: - Connection State Machine
class ConnectionStateMachine: ObservableObject {
    @Published var state: ConnectionPhase = .idle
    @Published var progress: Double = 0
    @Published var statusMessage: String = "Готов к подключению"
    @Published var phases: [PhaseInfo] = []

    enum ConnectionPhase: String, CaseIterable {
        case idle = "Ожидание"
        case resolvingDNS = "DNS резолвинг"
        case connecting = "Подключение"
        case handshaking = "TLS хендшейк"
        case authenticating = "Аутентификация"
        case establishing = "Установка туннеля"
        case connected = "Подключено"
        case disconnecting = "Отключение"
        case error = "Ошибка"

        var icon: String {
            switch self {
            case .idle: return "circle"
            case .resolvingDNS: return "server.rack"
            case .connecting: return "network"
            case .handshaking: return "lock.fill"
            case .authenticating: return "person.fill.checkmark"
            case .establishing: return "arrow.triangle.branch"
            case .connected: return "checkmark.circle.fill"
            case .disconnecting: return "xmark.circle"
            case .error: return "exclamationmark.triangle.fill"
            }
        }

        var color: Color {
            switch self {
            case .idle: return .gray
            case .resolvingDNS, .connecting, .handshaking, .authenticating, .establishing:
                return .v2xCyan
            case .connected: return .v2xGreen
            case .disconnecting: return .v2xYellow
            case .error: return .v2xRed
            }
        }
    }

    struct PhaseInfo: Identifiable {
        let id = UUID()
        let phase: ConnectionPhase
        var status: PhaseStatus
        var duration: Double?
        var detail: String?

        enum PhaseStatus {
            case pending, active, completed, failed
        }
    }

    func startConnection() {
        phases = ConnectionPhase.allCases
            .filter { $0 != .idle && $0 != .disconnecting && $0 != .error && $0 != .connected }
            .map { PhaseInfo(phase: $0, status: .pending) }

        let delays: [(ConnectionPhase, Double, String)] = [
            (.resolvingDNS, 0.3, "Резолвинг DNS: 1.1.1.1 → 104.16.123.96"),
            (.connecting, 0.5, "TCP подключение к серверу..."),
            (.handshaking, 0.8, "TLS 1.3 хендшейк (Chrome 120)"),
            (.authenticating, 0.4, "Проверка учётных данных..."),
            (.establishing, 0.6, "Настройка TUN интерфейса..."),
        ]

        var totalDelay: Double = 0

        for (index, (phase, duration, detail)) in delays.enumerated() {
            totalDelay += duration

            let activateDelay = totalDelay - duration
            let completeDelay = totalDelay

            DispatchQueue.main.asyncAfter(deadline: .now() + activateDelay) { [weak self] in
                self?.state = phase
                self?.statusMessage = detail
                self?.progress = Double(index) / Double(delays.count)
                if index < (self?.phases.count ?? 0) {
                    self?.phases[index].status = .active
                    self?.phases[index].detail = detail
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + completeDelay) { [weak self] in
                if index < (self?.phases.count ?? 0) {
                    self?.phases[index].status = .completed
                    self?.phases[index].duration = duration * 1000
                }
                self?.progress = Double(index + 1) / Double(delays.count)

                if index == delays.count - 1 {
                    self?.state = .connected
                    self?.statusMessage = "Подключено"
                    self?.progress = 1.0
                }
            }
        }
    }

    func startDisconnection() {
        state = .disconnecting
        statusMessage = "Отключение..."
        progress = 0.5

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.state = .idle
            self?.statusMessage = "Готов к подключению"
            self?.progress = 0
            self?.phases.removeAll()
        }
    }

    func reset() {
        state = .idle
        progress = 0
        statusMessage = "Готов к подключению"
        phases.removeAll()
    }
}
