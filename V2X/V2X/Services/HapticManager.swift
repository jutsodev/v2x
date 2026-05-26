// HapticManager.swift
// V2X

import SwiftUI
import UIKit

final class HapticManager: ObservableObject {
    static let shared = HapticManager()

    @Published var isHapticsEnabled = true

    private let lightGenerator = UIImpactFeedbackGenerator(style: .light)
    private let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        prepareGenerators()
    }

    private func prepareGenerators() {
        lightGenerator.prepare()
        mediumGenerator.prepare()
        heavyGenerator.prepare()
        softGenerator.prepare()
        rigidGenerator.prepare()
        selectionGenerator.prepare()
        notificationGenerator.prepare()
    }

    func triggerImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsEnabled else { return }

        switch style {
        case .light:
            lightGenerator.impactOccurred()
        case .medium:
            mediumGenerator.impactOccurred()
        case .heavy:
            heavyGenerator.impactOccurred()
        case .soft:
            softGenerator.impactOccurred()
        case .rigid:
            rigidGenerator.impactOccurred()
        @unknown default:
            mediumGenerator.impactOccurred()
        }
    }

    func triggerSelection() {
        guard isHapticsEnabled else { return }
        selectionGenerator.selectionChanged()
    }

    func triggerNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticsEnabled else { return }
        notificationGenerator.notificationOccurred(type)
    }

    func triggerPattern(_ pattern: HapticPattern) {
        guard isHapticsEnabled else { return }

        switch pattern {
        case .connection:
            triggerImpact(.medium)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.triggerImpact(.heavy)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.triggerNotification(.success)
            }
        case .disconnection:
            triggerImpact(.rigid)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.triggerImpact(.soft)
            }
        case .shake:
            triggerImpact(.heavy)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                self.triggerImpact(.heavy)
            }
        case .import_:
            triggerImpact(.light)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.triggerNotification(.success)
            }
        case .error:
            triggerNotification(.error)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.triggerNotification(.error)
            }
        case .tap:
            triggerImpact(.light)
        case .toggle:
            triggerImpact(.medium)
        }
    }

    enum HapticPattern {
        case connection
        case disconnection
        case shake
        case import_
        case error
        case tap
        case toggle
    }
}
