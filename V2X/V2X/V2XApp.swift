// V2XApp.swift
// V2X — Your Indestructible Tunnel to Free Internet
// Copyright © 2025 V2X Team. All rights reserved.

import SwiftUI

@main
struct V2XApp: App {
    @StateObject private var vpnManager = VPNManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var profileManager = ProfileManager.shared
    @StateObject private var statsTracker = StatsTracker.shared
    @StateObject private var threatShield = ThreatShield.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var aiSmartConnect = AISmartConnect.shared
    @StateObject private var hapticManager = HapticManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vpnManager)
                .environmentObject(themeManager)
                .environmentObject(profileManager)
                .environmentObject(statsTracker)
                .environmentObject(threatShield)
                .environmentObject(subscriptionManager)
                .environmentObject(aiSmartConnect)
                .environmentObject(hapticManager)
                .preferredColorScheme(.dark)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
                .onShake {
                    if vpnManager.connectionState == .connected {
                        hapticManager.triggerImpact(.heavy)
                        vpnManager.disconnect()
                    }
                }
        }
    }

    private func handleDeepLink(_ url: URL) {
        guard let scheme = url.scheme?.lowercased() else { return }

        switch scheme {
        case "v2x":
            handleV2XScheme(url)
        case "vless", "trojan", "vmess", "hysteria2", "tuic", "ss", "wireguard":
            profileManager.importConfig(from: url.absoluteString)
        default:
            break
        }
    }

    private func handleV2XScheme(_ url: URL) {
        let host = url.host?.lowercased() ?? ""
        let path = url.path

        switch host {
        case "connect", "open":
            vpnManager.connect()
        case "disconnect", "close":
            vpnManager.disconnect()
        case "toggle":
            vpnManager.toggle()
        case "add":
            let configURL = String(path.dropFirst())
            profileManager.importConfig(from: configURL)
        case "crypt", "crypt2", "crypt3":
            let configURL = String(path.dropFirst())
            profileManager.importEncryptedConfig(from: configURL, method: host)
        case "import":
            let protocolType = String(path.dropFirst())
            profileManager.showImportSheet(forProtocol: protocolType)
        case "routing":
            handleRoutingScheme(path: path)
        default:
            break
        }
    }

    private func handleRoutingScheme(path: String) {
        let components = path.split(separator: "/").map(String.init)
        guard let action = components.first else { return }

        switch action {
        case "add":
            if let base64 = components.dropFirst().first {
                profileManager.addRouting(base64: base64)
            }
        case "onadd":
            if let base64 = components.dropFirst().first {
                profileManager.addRoutingOnConnect(base64: base64)
            }
        case "off":
            profileManager.disableRouting()
        default:
            break
        }
    }
}

// MARK: - Shake Gesture Detection
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}
