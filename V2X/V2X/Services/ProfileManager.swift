// ProfileManager.swift
// V2X

import SwiftUI
import Combine

final class ProfileManager: ObservableObject {
    static let shared = ProfileManager()

    @Published var profiles: [VPNProfile] = VPNProfile.samples
    @Published var subscriptions: [V2XSubscription] = [V2XSubscription.sample]
    @Published var routingRules: [RoutingRule] = RoutingRule.defaults
    @Published var dnsConfigurations: [DNSConfiguration] = DNSConfiguration.presets
    @Published var activeDNS: DNSConfiguration? = DNSConfiguration.presets.first
    @Published var geoFiles: [GeoFile] = GeoFile.defaults

    @Published var showImportSheet = false
    @Published var importProtocol: String = ""
    @Published var importResult: ImportResult?
    @Published var isImporting = false

    @Published var routingEnabled = true
    @Published var geoIPAutoUpdate = true
    @Published var geoSiteAutoUpdate = true

    struct ImportResult: Identifiable {
        let id = UUID()
        let success: Bool
        let message: String
        let profileCount: Int
        let profiles: [VPNProfile]
    }

    private init() {}

    // MARK: - Profile Management
    func addProfile(_ profile: VPNProfile) {
        var newProfile = profile
        newProfile = VPNProfile(
            id: UUID(),
            name: profile.name,
            serverAddress: profile.serverAddress,
            port: profile.port,
            protocolType: profile.protocolType,
            uuid: profile.uuid,
            encryption: profile.encryption,
            network: profile.network,
            security: profile.security,
            sni: profile.sni,
            fingerprint: profile.fingerprint,
            publicKey: profile.publicKey,
            shortId: profile.shortId,
            flow: profile.flow,
            rawConfig: profile.rawConfig,
            isActive: false,
            createdAt: Date()
        )
        profiles.append(newProfile)
    }

    func deleteProfile(_ profile: VPNProfile) {
        profiles.removeAll { $0.id == profile.id }
    }

    func setActiveProfile(_ profile: VPNProfile) {
        for i in profiles.indices {
            profiles[i] = VPNProfile(
                id: profiles[i].id,
                name: profiles[i].name,
                serverAddress: profiles[i].serverAddress,
                port: profiles[i].port,
                protocolType: profiles[i].protocolType,
                uuid: profiles[i].uuid,
                encryption: profiles[i].encryption,
                network: profiles[i].network,
                security: profiles[i].security,
                sni: profiles[i].sni,
                fingerprint: profiles[i].fingerprint,
                publicKey: profiles[i].publicKey,
                shortId: profiles[i].shortId,
                flow: profiles[i].flow,
                rawConfig: profiles[i].rawConfig,
                isActive: profiles[i].id == profile.id,
                lastConnected: profiles[i].lastConnected,
                ping: profiles[i].ping,
                uploadBytes: profiles[i].uploadBytes,
                downloadBytes: profiles[i].downloadBytes,
                createdAt: profiles[i].createdAt,
                tags: profiles[i].tags
            )
        }
    }

    // MARK: - Config Import
    func importConfig(from urlString: String) {
        isImporting = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }

            if let profile = ConfigParser.shared.parseConfig(urlString) {
                self.addProfile(profile)
                self.importResult = ImportResult(
                    success: true,
                    message: "Конфигурация успешно импортирована",
                    profileCount: 1,
                    profiles: [profile]
                )
            } else {
                // Try batch import
                let profiles = ConfigParser.shared.parseMultipleConfigs(urlString)
                if !profiles.isEmpty {
                    profiles.forEach { self.addProfile($0) }
                    self.importResult = ImportResult(
                        success: true,
                        message: "Импортировано \(profiles.count) конфигураций",
                        profileCount: profiles.count,
                        profiles: profiles
                    )
                } else {
                    self.importResult = ImportResult(
                        success: false,
                        message: "Не удалось распознать конфигурацию",
                        profileCount: 0,
                        profiles: []
                    )
                }
            }

            self.isImporting = false
            HapticManager.shared.triggerNotification(self.importResult?.success == true ? .success : .error)
        }
    }

    func importEncryptedConfig(from urlString: String, method: String) {
        isImporting = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }

            // Simulate decryption + import
            let demoProfile = VPNProfile(
                name: "Encrypted Config (\(method))",
                serverAddress: "encrypted.v2x.network",
                port: 443,
                protocolType: .vlessReality,
                rawConfig: urlString
            )
            self.addProfile(demoProfile)
            self.importResult = ImportResult(
                success: true,
                message: "Зашифрованная конфигурация (\(method)) успешно импортирована",
                profileCount: 1,
                profiles: [demoProfile]
            )
            self.isImporting = false
            HapticManager.shared.triggerNotification(.success)
        }
    }

    func showImportSheet(forProtocol protocolName: String) {
        importProtocol = protocolName
        showImportSheet = true
    }

    // MARK: - Routing
    func addRouting(base64: String) {
        guard let decoded = base64.base64Decoded else { return }
        let rule = RoutingRule(
            name: "Imported Rule",
            domain: decoded,
            action: .proxy,
            isEnabled: true
        )
        routingRules.append(rule)
    }

    func addRoutingOnConnect(base64: String) {
        addRouting(base64: base64)
    }

    func disableRouting() {
        routingEnabled = false
    }

    func addRoutingRule(_ rule: RoutingRule) {
        routingRules.append(rule)
    }

    func deleteRoutingRule(_ rule: RoutingRule) {
        routingRules.removeAll { $0.id == rule.id }
    }

    // MARK: - Subscription Management
    func addSubscription(_ subscription: V2XSubscription) {
        subscriptions.append(subscription)
    }

    func refreshSubscription(_ subscription: V2XSubscription) {
        // Simulate subscription refresh
        if let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) {
            subscriptions[index] = V2XSubscription(
                id: subscription.id,
                name: subscription.name,
                url: subscription.url,
                profileCount: subscription.profileCount + Int.random(in: 0...3),
                lastUpdated: Date(),
                isAutoUpdate: subscription.isAutoUpdate,
                autoUpdateInterval: subscription.autoUpdateInterval
            )
        }
    }

    func refreshAllSubscriptions() {
        for subscription in subscriptions {
            refreshSubscription(subscription)
        }
    }

    // MARK: - DNS
    func setActiveDNS(_ dns: DNSConfiguration) {
        activeDNS = dns
    }

    // MARK: - GeoFiles
    func updateGeoFile(_ file: GeoFile) {
        // Simulate geo file update
    }

    // MARK: - Reset
    func resetAll() {
        profiles = []
        subscriptions = []
        routingRules = []
        dnsConfigurations = DNSConfiguration.presets
        activeDNS = DNSConfiguration.presets.first
        geoFiles = GeoFile.defaults
    }

    // MARK: - Export
    func exportAllConfigs() -> String {
        profiles.map(\.rawConfig).filter { !$0.isEmpty }.joined(separator: "\n")
    }
}
