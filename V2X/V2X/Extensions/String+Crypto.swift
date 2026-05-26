// String+Crypto.swift
// V2X

import Foundation

extension String {
    // MARK: - Base64 Encoding/Decoding
    var base64Encoded: String? {
        data(using: .utf8)?.base64EncodedString()
    }

    var base64Decoded: String? {
        // Handle URL-safe base64
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Pad if necessary
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: base64) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Config Parsing Helpers
    var isValidV2XConfig: Bool {
        let schemes = ["vless://", "trojan://", "vmess://", "hysteria2://", "tuic://", "ss://", "wireguard://"]
        return schemes.contains { self.lowercased().hasPrefix($0) }
    }

    var configProtocolType: VPNProtocolType? {
        let lower = self.lowercased()
        if lower.hasPrefix("vless://") {
            return lower.contains("reality") ? .vlessReality : .vless
        }
        if lower.hasPrefix("trojan://") { return .trojan }
        if lower.hasPrefix("vmess://") { return .vmess }
        if lower.hasPrefix("hysteria2://") || lower.hasPrefix("hy2://") { return .hysteria2 }
        if lower.hasPrefix("tuic://") { return .tuic }
        if lower.hasPrefix("ss://") { return .shadowsocks }
        if lower.hasPrefix("wireguard://") || lower.hasPrefix("wg://") { return .wireguard }
        return nil
    }

    func extractConfigComponents() -> [String: String] {
        var components: [String: String] = [:]

        // Extract fragment (name)
        if let hashIndex = self.lastIndex(of: "#") {
            let fragment = String(self[self.index(after: hashIndex)...])
            components["name"] = fragment.removingPercentEncoding ?? fragment
        }

        // Extract query parameters
        if let queryStart = self.firstIndex(of: "?"),
           let queryEnd = self.lastIndex(of: "#") ?? self.endIndex as String.Index? {
            let queryString = String(self[self.index(after: queryStart)..<queryEnd])
            let pairs = queryString.split(separator: "&")
            for pair in pairs {
                let kv = pair.split(separator: "=", maxSplits: 1)
                if kv.count == 2 {
                    components[String(kv[0])] = String(kv[1])
                }
            }
        }

        return components
    }

    // MARK: - Traffic Formatting
    static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }

    static func formatSpeed(_ bytesPerSecond: Double) -> String {
        return formatBytes(Int64(bytesPerSecond)) + "/s"
    }

    // MARK: - Time Formatting
    static func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - URL Validation
    var isValidURL: Bool {
        if let url = URL(string: self), url.scheme != nil, url.host != nil {
            return true
        }
        return false
    }

    var isValidIPAddress: Bool {
        let parts = self.split(separator: ".")
        if parts.count == 4 {
            return parts.allSatisfy { part in
                if let num = Int(part) {
                    return num >= 0 && num <= 255
                }
                return false
            }
        }
        return false
    }

    // MARK: - Server Address Masking
    var maskedAddress: String {
        guard self.count > 6 else { return "***" }
        let prefix = String(self.prefix(3))
        let suffix = String(self.suffix(3))
        return "\(prefix)***\(suffix)"
    }
}

// MARK: - Data Extensions
extension Data {
    var hexString: String {
        map { String(format: "%02hhx", $0) }.joined()
    }

    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var index = hexString.startIndex
        for _ in 0..<len {
            let nextIndex = hexString.index(index, offsetBy: 2)
            guard let byte = UInt8(hexString[index..<nextIndex], radix: 16) else { return nil }
            data.append(byte)
            index = nextIndex
        }
        self = data
    }
}
