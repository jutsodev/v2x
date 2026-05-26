// ConfigParser.swift
// V2X

import Foundation

final class ConfigParser {
    static let shared = ConfigParser()

    private init() {}

    // MARK: - Parse Config URL
    func parseConfig(_ configString: String) -> VPNProfile? {
        let trimmed = configString.trimmingCharacters(in: .whitespacesAndNewlines)

        // Try base64 decode first
        if let decoded = trimmed.base64Decoded, decoded.isValidV2XConfig {
            return parseDirectURL(decoded)
        }

        if trimmed.isValidV2XConfig {
            return parseDirectURL(trimmed)
        }

        // Try parsing as JSON (VMess format)
        if let data = trimmed.data(using: .utf8),
           let _ = try? JSONSerialization.jsonObject(with: data) {
            return parseVMessJSON(trimmed)
        }

        return nil
    }

    // MARK: - Parse Direct URL
    private func parseDirectURL(_ urlString: String) -> VPNProfile? {
        guard let protocolType = urlString.configProtocolType else { return nil }

        switch protocolType {
        case .vless, .vlessReality:
            return parseVLESS(urlString)
        case .trojan:
            return parseTrojan(urlString)
        case .vmess:
            return parseVMess(urlString)
        case .hysteria2:
            return parseHysteria2(urlString)
        case .tuic:
            return parseTUIC(urlString)
        case .shadowsocks:
            return parseShadowsocks(urlString)
        case .wireguard:
            return parseWireGuard(urlString)
        }
    }

    // MARK: - VLESS Parser
    private func parseVLESS(_ urlString: String) -> VPNProfile? {
        let clean = urlString
            .replacingOccurrences(of: "vless://", with: "")
        let components = clean.extractConfigComponents()

        // Extract UUID and address
        guard let atIndex = clean.firstIndex(of: "@") else { return nil }
        let uuid = String(clean[clean.startIndex..<atIndex])

        let afterAt = String(clean[clean.index(after: atIndex)...])
        let addressPart: String
        if let queryIndex = afterAt.firstIndex(of: "?") {
            addressPart = String(afterAt[afterAt.startIndex..<queryIndex])
        } else if let hashIndex = afterAt.firstIndex(of: "#") {
            addressPart = String(afterAt[afterAt.startIndex..<hashIndex])
        } else {
            addressPart = afterAt
        }

        let addressComponents = addressPart.split(separator: ":")
        let address = String(addressComponents.first ?? "")
        let port = Int(addressComponents.last ?? "443") ?? 443

        let isReality = components["security"] == "reality"

        return VPNProfile(
            name: components["name"] ?? "VLESS Server",
            serverAddress: address,
            port: port,
            protocolType: isReality ? .vlessReality : .vless,
            uuid: uuid,
            encryption: components["encryption"] ?? "none",
            network: components["type"] ?? "tcp",
            security: components["security"] ?? "tls",
            sni: components["sni"] ?? "",
            fingerprint: components["fp"] ?? "chrome",
            publicKey: components["pbk"] ?? "",
            shortId: components["sid"] ?? "",
            flow: components["flow"] ?? "xtls-rprx-vision",
            rawConfig: urlString
        )
    }

    // MARK: - Trojan Parser
    private func parseTrojan(_ urlString: String) -> VPNProfile? {
        let clean = urlString.replacingOccurrences(of: "trojan://", with: "")
        let components = clean.extractConfigComponents()

        guard let atIndex = clean.firstIndex(of: "@") else { return nil }
        let password = String(clean[clean.startIndex..<atIndex])

        let afterAt = String(clean[clean.index(after: atIndex)...])
        let addressPart: String
        if let queryIndex = afterAt.firstIndex(of: "?") {
            addressPart = String(afterAt[afterAt.startIndex..<queryIndex])
        } else if let hashIndex = afterAt.firstIndex(of: "#") {
            addressPart = String(afterAt[afterAt.startIndex..<hashIndex])
        } else {
            addressPart = afterAt
        }

        let addressComponents = addressPart.split(separator: ":")
        let address = String(addressComponents.first ?? "")
        let port = Int(addressComponents.last ?? "443") ?? 443

        return VPNProfile(
            name: components["name"] ?? "Trojan Server",
            serverAddress: address,
            port: port,
            protocolType: .trojan,
            uuid: password,
            network: components["type"] ?? "tcp",
            security: "tls",
            sni: components["sni"] ?? "",
            rawConfig: urlString
        )
    }

    // MARK: - VMess Parser
    private func parseVMess(_ urlString: String) -> VPNProfile? {
        let clean = urlString.replacingOccurrences(of: "vmess://", with: "")

        guard let decoded = clean.base64Decoded,
              let data = decoded.data(using: .utf8) else {
            return parseVMessDirect(urlString)
        }

        return parseVMessJSON(String(data: data, encoding: .utf8) ?? decoded)
    }

    private func parseVMessDirect(_ urlString: String) -> VPNProfile? {
        let clean = urlString.replacingOccurrences(of: "vmess://", with: "")
        let components = clean.extractConfigComponents()

        return VPNProfile(
            name: components["name"] ?? "VMess Server",
            protocolType: .vmess,
            rawConfig: urlString
        )
    }

    private func parseVMessJSON(_ jsonString: String) -> VPNProfile? {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        return VPNProfile(
            name: json["ps"] as? String ?? "VMess Server",
            serverAddress: json["add"] as? String ?? "",
            port: (json["port"] as? Int) ?? Int(json["port"] as? String ?? "443") ?? 443,
            protocolType: .vmess,
            uuid: json["id"] as? String ?? "",
            encryption: json["scy"] as? String ?? "auto",
            network: json["net"] as? String ?? "tcp",
            security: json["tls"] as? String ?? "",
            sni: json["sni"] as? String ?? json["host"] as? String ?? "",
            rawConfig: jsonString
        )
    }

    // MARK: - Hysteria2 Parser
    private func parseHysteria2(_ urlString: String) -> VPNProfile? {
        let clean = urlString
            .replacingOccurrences(of: "hysteria2://", with: "")
            .replacingOccurrences(of: "hy2://", with: "")
        let components = clean.extractConfigComponents()

        guard let atIndex = clean.firstIndex(of: "@") else { return nil }
        let password = String(clean[clean.startIndex..<atIndex])

        let afterAt = String(clean[clean.index(after: atIndex)...])
        let addressPart: String
        if let queryIndex = afterAt.firstIndex(of: "?") {
            addressPart = String(afterAt[afterAt.startIndex..<queryIndex])
        } else if let hashIndex = afterAt.firstIndex(of: "#") {
            addressPart = String(afterAt[afterAt.startIndex..<hashIndex])
        } else {
            addressPart = afterAt
        }

        let addressComponents = addressPart.split(separator: ":")
        let address = String(addressComponents.first ?? "")
        let port = Int(addressComponents.last ?? "443") ?? 443

        return VPNProfile(
            name: components["name"] ?? "Hysteria2 Server",
            serverAddress: address,
            port: port,
            protocolType: .hysteria2,
            uuid: password,
            sni: components["sni"] ?? "",
            rawConfig: urlString
        )
    }

    // MARK: - TUIC Parser
    private func parseTUIC(_ urlString: String) -> VPNProfile? {
        let clean = urlString.replacingOccurrences(of: "tuic://", with: "")
        let components = clean.extractConfigComponents()

        guard let atIndex = clean.firstIndex(of: "@") else { return nil }
        let credentials = String(clean[clean.startIndex..<atIndex])
        let credParts = credentials.split(separator: ":")
        let uuid = String(credParts.first ?? "")

        let afterAt = String(clean[clean.index(after: atIndex)...])
        let addressPart: String
        if let queryIndex = afterAt.firstIndex(of: "?") {
            addressPart = String(afterAt[afterAt.startIndex..<queryIndex])
        } else {
            addressPart = afterAt
        }

        let addressComponents = addressPart.split(separator: ":")
        let address = String(addressComponents.first ?? "")
        let port = Int(addressComponents.last ?? "443") ?? 443

        return VPNProfile(
            name: components["name"] ?? "TUIC Server",
            serverAddress: address,
            port: port,
            protocolType: .tuic,
            uuid: uuid,
            sni: components["sni"] ?? "",
            rawConfig: urlString
        )
    }

    // MARK: - Shadowsocks Parser
    private func parseShadowsocks(_ urlString: String) -> VPNProfile? {
        let clean = urlString.replacingOccurrences(of: "ss://", with: "")
        let components = clean.extractConfigComponents()

        // SS format: method:password@server:port or base64@server:port
        guard let atIndex = clean.firstIndex(of: "@") else {
            // Try base64 format
            if let decoded = clean.base64Decoded {
                return parseShadowsocks("ss://\(decoded)")
            }
            return nil
        }

        let credentials = String(clean[clean.startIndex..<atIndex])
        let afterAt = String(clean[clean.index(after: atIndex)...])

        let addressPart: String
        if let queryIndex = afterAt.firstIndex(of: "?") {
            addressPart = String(afterAt[afterAt.startIndex..<queryIndex])
        } else if let hashIndex = afterAt.firstIndex(of: "#") {
            addressPart = String(afterAt[afterAt.startIndex..<hashIndex])
        } else {
            addressPart = afterAt
        }

        let addressComponents = addressPart.split(separator: ":")
        let address = String(addressComponents.first ?? "")
        let port = Int(addressComponents.last ?? "443") ?? 443

        let decodedCreds = credentials.base64Decoded ?? credentials
        let credParts = decodedCreds.split(separator: ":", maxSplits: 1)
        let method = String(credParts.first ?? "aes-256-gcm")
        let password = credParts.count > 1 ? String(credParts[1]) : ""

        return VPNProfile(
            name: components["name"] ?? "Shadowsocks Server",
            serverAddress: address,
            port: port,
            protocolType: .shadowsocks,
            uuid: password,
            encryption: method,
            rawConfig: urlString
        )
    }

    // MARK: - WireGuard Parser
    private func parseWireGuard(_ urlString: String) -> VPNProfile? {
        let clean = urlString
            .replacingOccurrences(of: "wireguard://", with: "")
            .replacingOccurrences(of: "wg://", with: "")
        let components = clean.extractConfigComponents()

        return VPNProfile(
            name: components["name"] ?? "WireGuard Server",
            protocolType: .wireguard,
            rawConfig: urlString
        )
    }

    // MARK: - Batch Import
    func parseMultipleConfigs(_ input: String) -> [VPNProfile] {
        let lines = input.components(separatedBy: .newlines)
        var profiles: [VPNProfile] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            if let profile = parseConfig(trimmed) {
                profiles.append(profile)
            }
        }

        // If no profiles found, try base64 decode the entire input
        if profiles.isEmpty, let decoded = input.base64Decoded {
            profiles = parseMultipleConfigs(decoded)
        }

        return profiles
    }
}
