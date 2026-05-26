// ShakeDetector.swift
// V2X

import SwiftUI
import Combine

final class ShakeDetector: ObservableObject {
    static let shared = ShakeDetector()

    @Published var isShakeToDisconnectEnabled = true
    @Published var shakeCount = 0
    @Published var lastShake: Date?

    private var cancellables = Set<AnyCancellable>()

    private init() {
        NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)
            .sink { [weak self] _ in
                self?.handleShake()
            }
            .store(in: &cancellables)
    }

    private func handleShake() {
        guard isShakeToDisconnectEnabled else { return }

        shakeCount += 1
        lastShake = Date()

        if VPNManager.shared.connectionState == .connected {
            HapticManager.shared.triggerPattern(.shake)
            VPNManager.shared.disconnect()
        }
    }
}
