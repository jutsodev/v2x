// ThreatShield.swift
// V2X

import SwiftUI
import Combine

final class ThreatShield: ObservableObject {
    static let shared = ThreatShield()

    @Published var isEnabled = true
    @Published var blockTrackers = true
    @Published var blockAds = true
    @Published var blockMalware = true
    @Published var blockPhishing = true

    @Published var totalBlocked: Int = 14_832
    @Published var trackersBlocked: Int = 8_241
    @Published var adsBlocked: Int = 5_126
    @Published var malwareBlocked: Int = 892
    @Published var phishingBlocked: Int = 573

    @Published var recentEvents: [ThreatEvent] = []
    @Published var isShieldAnimating = false

    private var eventTimer: Timer?

    private init() {
        generateRecentEvents()
        startEventSimulation()
    }

    func toggle() {
        isEnabled.toggle()
        HapticManager.shared.triggerImpact(.medium)

        if isEnabled {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                isShieldAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isShieldAnimating = false
            }
            startEventSimulation()
        } else {
            stopEventSimulation()
        }
    }

    private func generateRecentEvents() {
        let domains = [
            "tracker.facebook.com", "ads.google.com", "analytics.tiktok.com",
            "pixel.quantserve.com", "cdn.doubleverify.com", "telemetry.microsoft.com",
            "malware-site.xyz", "phishing-bank.com", "suspicious-download.net",
            "ad-server.ru", "tracker.yandex.ru", "cdn.adnxs.com"
        ]

        let types: [ThreatEvent.ThreatType] = [.tracker, .ad, .malware, .phishing]
        let severities: [ThreatEvent.ThreatSeverity] = [.low, .medium, .high, .critical]

        for i in 0..<20 {
            let event = ThreatEvent(
                type: types[i % types.count],
                domain: domains[i % domains.count],
                timestamp: Date().addingTimeInterval(-Double(i * 30)),
                severity: severities[i % severities.count]
            )
            recentEvents.append(event)
        }
    }

    private func startEventSimulation() {
        eventTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isEnabled else { return }
            self.simulateNewEvent()
        }
    }

    private func stopEventSimulation() {
        eventTimer?.invalidate()
        eventTimer = nil
    }

    private func simulateNewEvent() {
        let domains = ["tracker.fb.com", "ads.doubleclick.net", "pixel.twitter.com", "analytics.google.com"]
        let types: [ThreatEvent.ThreatType] = [.tracker, .ad, .tracker, .ad, .malware]
        let severities: [ThreatEvent.ThreatSeverity] = [.low, .medium, .high]

        let event = ThreatEvent(
            type: types.randomElement() ?? .tracker,
            domain: domains.randomElement() ?? "unknown",
            timestamp: Date(),
            severity: severities.randomElement() ?? .medium
        )

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            recentEvents.insert(event, at: 0)
            if recentEvents.count > 50 {
                recentEvents.removeLast()
            }
        }

        totalBlocked += 1
        switch event.type {
        case .tracker: trackersBlocked += 1
        case .ad: adsBlocked += 1
        case .malware: malwareBlocked += 1
        case .phishing: phishingBlocked += 1
        case .crypto, .fingerprint: trackersBlocked += 1
        }
    }
}
