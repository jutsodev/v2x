// URLSchemeItem.swift
// V2X

import SwiftUI

struct URLSchemeItem: Identifiable {
    let id = UUID()
    let scheme: String
    let description: String
    let category: URLSchemeCategory

    var displayScheme: String {
        scheme
    }

    enum URLSchemeCategory: String, CaseIterable {
        case tunnel = "Управление туннелем"
        case config = "Конфигурация"
        case importProtocol = "Импорт по протоколу"
        case routing = "Роутинг"
        case settings = "Настройки"
        case security = "Безопасность"
    }

    static let allSchemes: [URLSchemeItem] = [
        // Tunnel
        URLSchemeItem(scheme: "v2x://connect", description: "Запустить туннель", category: .tunnel),
        URLSchemeItem(scheme: "v2x://open", description: "Запустить туннель (алиас)", category: .tunnel),
        URLSchemeItem(scheme: "v2x://disconnect", description: "Остановить соединение", category: .tunnel),
        URLSchemeItem(scheme: "v2x://close", description: "Остановить соединение (алиас)", category: .tunnel),
        URLSchemeItem(scheme: "v2x://toggle", description: "Переключить состояние", category: .tunnel),
        URLSchemeItem(scheme: "v2x://reconnect", description: "Переподключиться", category: .tunnel),
        URLSchemeItem(scheme: "v2x://status", description: "Получить статус", category: .tunnel),

        // Config
        URLSchemeItem(scheme: "v2x://add/{url}", description: "Добавить конфигурацию из URL", category: .config),
        URLSchemeItem(scheme: "v2x://crypt/{url}", description: "Добавить зашифрованную конфигурацию", category: .config),
        URLSchemeItem(scheme: "v2x://crypt2/{url}", description: "Добавить конфигурацию (crypto v2)", category: .config),
        URLSchemeItem(scheme: "v2x://crypt3/{url}", description: "Добавить конфигурацию (crypto v3)", category: .config),
        URLSchemeItem(scheme: "v2x://subscribe/{url}", description: "Добавить подписку", category: .config),
        URLSchemeItem(scheme: "v2x://delete/{name}", description: "Удалить конфигурацию", category: .config),
        URLSchemeItem(scheme: "v2x://export", description: "Экспорт конфигурации", category: .config),
        URLSchemeItem(scheme: "v2x://import/clipboard", description: "Импорт из буфера обмена", category: .config),

        // Import by protocol
        URLSchemeItem(scheme: "v2x://import/vless", description: "Импорт VLESS конфигурации", category: .importProtocol),
        URLSchemeItem(scheme: "v2x://import/trojan", description: "Импорт Trojan конфигурации", category: .importProtocol),
        URLSchemeItem(scheme: "v2x://import/vmess", description: "Импорт VMess конфигурации", category: .importProtocol),
        URLSchemeItem(scheme: "v2x://import/hysteria2", description: "Импорт Hysteria2 конфигурации", category: .importProtocol),
        URLSchemeItem(scheme: "v2x://import/tuic", description: "Импорт TUIC конфигурации", category: .importProtocol),
        URLSchemeItem(scheme: "v2x://import/shadowsocks", description: "Импорт Shadowsocks конфигурации", category: .importProtocol),
        URLSchemeItem(scheme: "v2x://import/wireguard", description: "Импорт WireGuard конфигурации", category: .importProtocol),
        URLSchemeItem(scheme: "v2x://import/any", description: "Импорт любой конфигурации", category: .importProtocol),

        // Routing
        URLSchemeItem(scheme: "v2x://routing/add/{base64}", description: "Добавить правило роутинга", category: .routing),
        URLSchemeItem(scheme: "v2x://routing/onadd/{base64}", description: "Добавить и активировать правило", category: .routing),
        URLSchemeItem(scheme: "v2x://routing/off", description: "Отключить все правила роутинга", category: .routing),
        URLSchemeItem(scheme: "v2x://routing/reset", description: "Сбросить правила роутинга", category: .routing),
        URLSchemeItem(scheme: "v2x://routing/geoip/update", description: "Обновить GeoIP базу", category: .routing),
        URLSchemeItem(scheme: "v2x://routing/geosite/update", description: "Обновить GeoSite базу", category: .routing),

        // Settings
        URLSchemeItem(scheme: "v2x://settings/theme/{name}", description: "Переключить тему", category: .settings),
        URLSchemeItem(scheme: "v2x://settings/dns/{server}", description: "Установить DNS сервер", category: .settings),
        URLSchemeItem(scheme: "v2x://settings/tunnel/persistent", description: "Включить постоянный туннель", category: .settings),
        URLSchemeItem(scheme: "v2x://settings/tunnel/ondemand", description: "Включить режим по требованию", category: .settings),
        URLSchemeItem(scheme: "v2x://settings/reset", description: "Сбросить все настройки", category: .settings),

        // Security
        URLSchemeItem(scheme: "v2x://security/quantum/on", description: "Включить Quantum Stealth", category: .security),
        URLSchemeItem(scheme: "v2x://security/quantum/off", description: "Отключить Quantum Stealth", category: .security),
        URLSchemeItem(scheme: "v2x://security/shield/on", description: "Включить Threat Shield", category: .security),
        URLSchemeItem(scheme: "v2x://security/shield/off", description: "Отключить Threat Shield", category: .security),
        URLSchemeItem(scheme: "v2x://security/ai/on", description: "Включить AI Smart Connect", category: .security),
        URLSchemeItem(scheme: "v2x://security/ai/off", description: "Отключить AI Smart Connect", category: .security),
    ]
}

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let source: String
    let message: String

    enum LogLevel: String, CaseIterable {
        case info = "INFO"
        case warning = "WARN"
        case error = "ERR"
        case debug = "DBG"

        var color: Color {
            switch self {
            case .info: return .v2xCyan
            case .warning: return .v2xYellow
            case .error: return .v2xRed
            case .debug: return .v2xTextTertiary
            }
        }
    }

    static let samples: [LogEntry] = {
        let sources = ["VPNCore", "TunnelMgr", "ConfigParser", "NetworkExt", "DNSResolver", "ThreatShield", "AIConnect", "ProtoHandler"]
        let infoMessages = [
            "Tunnel interface initialized successfully",
            "DNS resolver configured: 1.1.1.1, 8.8.8.8",
            "Network extension loaded",
            "Profile 'V2X Ultra' activated",
            "Connection established to server",
            "Traffic stats updated: 5.52 GB total",
            "GeoIP database updated (v2025.05)",
            "Subscription refreshed: 12 servers found",
            "TLS handshake completed (Chrome 120 fingerprint)",
            "Route table updated with 3 new rules",
            "Packet fragmentation enabled (100 bytes)",
            "Memory usage: 45 MB / 256 MB limit",
            "Session started at 2025-05-26 11:00:00",
            "VLESS protocol handler initialized",
            "Quantum stealth mode activated",
            "AI analysis complete: score 94%",
            "Threat shield: 142 threats blocked today",
            "WebSocket transport connected",
            "REALITY handshake successful",
            "QUIC connection established (0-RTT)",
        ]
        let warnMessages = [
            "High latency detected: 180ms",
            "DNS resolution slow: 450ms",
            "Memory approaching limit: 200 MB / 256 MB",
            "Server response delayed: 2.5s",
            "Reconnecting due to network change",
            "Certificate pinning mismatch (non-critical)",
            "Fallback to secondary DNS server",
            "Ping timeout to US-East server",
        ]
        let errorMessages = [
            "Connection refused by remote server",
            "TLS certificate validation failed",
            "Socket write error: broken pipe",
            "DNS resolution failed for proxy.v2x.io",
            "Out of memory: reducing buffer size",
        ]
        let debugMessages = [
            "Sending CONNECT request to proxy",
            "Received 1024 bytes from upstream",
            "Routing decision: PROXY for google.com",
            "Encryption: AES-256-GCM cipher selected",
            "Buffer flush: 4096 bytes written",
            "GeoIP lookup: US for 8.8.8.8",
            "Obfuscation layer 2 applied",
            "Fragment #3 of 5 sent",
            "PADDING: 64 random bytes added",
            "Header rewrite: Host → cdn.example.com",
        ]

        var entries: [LogEntry] = []
        let now = Date()

        for i in 0..<50 {
            let timeOffset = TimeInterval(-i * Int.random(in: 3...30))
            let date = now.addingTimeInterval(timeOffset)
            let source = sources.randomElement()!

            let (level, message): (LogLevel, String)
            let roll = Int.random(in: 0...100)
            if roll < 50 {
                level = .info
                message = infoMessages.randomElement()!
            } else if roll < 65 {
                level = .debug
                message = debugMessages.randomElement()!
            } else if roll < 85 {
                level = .warning
                message = warnMessages.randomElement()!
            } else {
                level = .error
                message = errorMessages.randomElement()!
            }

            entries.append(LogEntry(timestamp: date, level: level, source: source, message: message))
        }

        return entries.sorted { $0.timestamp > $1.timestamp }
    }()
}
