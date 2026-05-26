// AISmartConnect.swift
// V2X

import SwiftUI
import Combine

final class AISmartConnect: ObservableObject {
    static let shared = AISmartConnect()

    @Published var isEnabled = true
    @Published var isAnalyzing = false
    @Published var selectedServer: ServerNode?
    @Published var recommendedProtocol: VPNProtocolType = .vlessReality
    @Published var analysisResults: [AnalysisResult] = []
    @Published var confidence: Double = 0.94
    @Published var lastAnalysis: Date?
    @Published var networkScore: Double = 0.87
    @Published var stabilityScore: Double = 0.92
    @Published var speedScore: Double = 0.89
    @Published var latencyScore: Double = 0.95

    @Published var availableServers: [ServerNode] = ServerNode.sampleServers

    struct AnalysisResult: Identifiable {
        let id = UUID()
        var server: ServerNode
        var score: Double
        var protocol_: VPNProtocolType
        var estimatedPing: Int
        var estimatedSpeed: String
        var reason: String
    }

    private var analysisTimer: Timer?
    private init() {
        generateInitialAnalysis()
    }

    func startAnalysis() {
        isAnalyzing = true
        analysisResults.removeAll()

        // Simulate AI analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.generateAnalysisStep(step: 0)
        }
    }

    private func generateAnalysisStep(step: Int) {
        guard step < availableServers.count else {
            finalizeAnalysis()
            return
        }

        let server = availableServers[step]
        let score = Double.random(in: 0.6...0.99)
        let protocols: [VPNProtocolType] = [.vlessReality, .trojan, .hysteria2, .vless]

        let result = AnalysisResult(
            server: server,
            score: score,
            protocol_: protocols.randomElement() ?? .vlessReality,
            estimatedPing: Int.random(in: 15...200),
            estimatedSpeed: "\(Int.random(in: 100...1000)) Mbps",
            reason: generateReason(score: score)
        )

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            analysisResults.append(result)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.generateAnalysisStep(step: step + 1)
        }
    }

    private func finalizeAnalysis() {
        let sorted = analysisResults.sorted { $0.score > $1.score }
        if let best = sorted.first {
            selectedServer = best.server
            recommendedProtocol = best.protocol_
            confidence = best.score
        }

        lastAnalysis = Date()
        isAnalyzing = false

        // Update scores
        networkScore = Double.random(in: 0.8...0.99)
        stabilityScore = Double.random(in: 0.85...0.99)
        speedScore = Double.random(in: 0.75...0.95)
        latencyScore = Double.random(in: 0.88...0.99)

        HapticManager.shared.triggerNotification(.success)
    }

    private func generateInitialAnalysis() {
        for server in availableServers {
            let score = Double.random(in: 0.6...0.99)
            let protocols: [VPNProtocolType] = [.vlessReality, .trojan, .hysteria2]
            analysisResults.append(AnalysisResult(
                server: server,
                score: score,
                protocol_: protocols.randomElement() ?? .vlessReality,
                estimatedPing: server.ping ?? 0,
                estimatedSpeed: "\(Int.random(in: 100...1000)) Mbps",
                reason: generateReason(score: score)
            ))
        }
        analysisResults.sort { $0.score > $1.score }
        if let best = analysisResults.first {
            selectedServer = best.server
            recommendedProtocol = best.protocol_
            confidence = best.score
        }
        lastAnalysis = Date()
    }

    private func generateReason(score: Double) -> String {
        if score > 0.9 { return "Оптимальная нагрузка, минимальная задержка" }
        if score > 0.8 { return "Стабильное соединение, хорошая скорость" }
        if score > 0.7 { return "Приемлемая скорость, средняя задержка" }
        return "Высокая нагрузка, возможны задержки"
    }

    func toggleAI() {
        isEnabled.toggle()
        if isEnabled {
            startAnalysis()
        }
        HapticManager.shared.triggerImpact(.medium)
    }
}
