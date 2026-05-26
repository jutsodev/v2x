// SubscriptionManager.swift
// V2X

import SwiftUI
import Combine

final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var subscriptions: [V2XSubscription] = [V2XSubscription.sample]
    @Published var isRefreshing = false
    @Published var lastRefresh: Date? = Date()
    @Published var totalProfiles: Int = 12

    private init() {}

    func addSubscription(name: String, url: String) {
        let subscription = V2XSubscription(
            name: name,
            url: url,
            lastUpdated: nil,
            profileCount: 0,
            isActive: true,
            autoUpdate: true,
            updateInterval: 24
        )
        subscriptions.append(subscription)
        refreshSubscription(subscription)
    }

    func refreshSubscription(_ subscription: V2XSubscription) {
        isRefreshing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }

            if let index = self.subscriptions.firstIndex(where: { $0.id == subscription.id }) {
                self.subscriptions[index] = V2XSubscription(
                    id: subscription.id,
                    name: subscription.name,
                    url: subscription.url,
                    lastUpdated: Date(),
                    profileCount: Int.random(in: 5...20),
                    isActive: subscription.isActive,
                    autoUpdate: subscription.autoUpdate,
                    updateInterval: subscription.updateInterval
                )
            }

            self.totalProfiles = self.subscriptions.reduce(0) { $0 + $1.profileCount }
            self.lastRefresh = Date()
            self.isRefreshing = false
            HapticManager.shared.triggerNotification(.success)
        }
    }

    func refreshAll() {
        isRefreshing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self = self else { return }

            for i in self.subscriptions.indices {
                self.subscriptions[i] = V2XSubscription(
                    id: self.subscriptions[i].id,
                    name: self.subscriptions[i].name,
                    url: self.subscriptions[i].url,
                    lastUpdated: Date(),
                    profileCount: Int.random(in: 5...20),
                    isActive: self.subscriptions[i].isActive,
                    autoUpdate: self.subscriptions[i].autoUpdate,
                    updateInterval: self.subscriptions[i].updateInterval
                )
            }

            self.totalProfiles = self.subscriptions.reduce(0) { $0 + $1.profileCount }
            self.lastRefresh = Date()
            self.isRefreshing = false
            HapticManager.shared.triggerNotification(.success)
        }
    }

    func deleteSubscription(_ subscription: V2XSubscription) {
        subscriptions.removeAll { $0.id == subscription.id }
        totalProfiles = subscriptions.reduce(0) { $0 + $1.profileCount }
    }
}
