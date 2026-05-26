// AISmartConnectView.swift
// V2X

import SwiftUI

struct AISmartConnectView: View {
    @EnvironmentObject var aiSmartConnect: AISmartConnect
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // AI Status Card
                    aiStatusCard

                    // Network Analysis
                    if aiSmartConnect.isEnabled {
                        networkAnalysisCard
                        serverRecommendations
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .liquidGlassBackground(cornerRadius: 10)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("AI Smart Connect")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var aiStatusCard: some View {
        LiquidGlassCard(cornerRadius: 24, glowColor: aiSmartConnect.isEnabled ? .v2xCyan : nil, glowRadius: 10) {
            VStack(spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.v2xCyan.opacity(0.15))
                            .frame(width: 56, height: 56)

                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 26))
                            .foregroundColor(.v2xCyan)
                            .symbolEffect(.pulse, isActive: aiSmartConnect.isAnalyzing)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Smart Connect")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text(aiSmartConnect.isAnalyzing ? "Анализ сети..." : "Нейросеть оптимизирует маршрут")
                            .font(.system(size: 12))
                            .foregroundColor(.v2xTextTertiary)
                    }

                    Spacer()

                    LiquidGlassToggle(isOn: Binding(
                        get: { aiSmartConnect.isEnabled },
                        set: { _ in aiSmartConnect.toggleAI() }
                    ))
                }

                if aiSmartConnect.isEnabled {
                    // Confidence bar
                    VStack(spacing: 6) {
                        HStack {
                            Text("Уверенность AI")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.v2xTextTertiary)
                            Spacer()
                            Text("\(Int(aiSmartConnect.confidence * 100))%")
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.v2xCyan)
                        }

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.06))

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [.v2xCyan, .v2xPurple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * aiSmartConnect.confidence)
                            }
                        }
                        .frame(height: 6)
                    }

                    // Re-analyze button
                    Button {
                        aiSmartConnect.startAnalysis()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 13))
                            Text("Повторный анализ")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.v2xCyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .liquidGlassBackground(cornerRadius: 12)
                    }
                    .buttonStyle(LiquidPressButtonStyle())
                    .disabled(aiSmartConnect.isAnalyzing)
                }
            }
            .padding(18)
        }
    }

    private var networkAnalysisCard: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 14) {
                HStack {
                    Text("Анализ сети")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    if let date = aiSmartConnect.lastAnalysis {
                        Text(date, style: .relative)
                            .font(.system(size: 11))
                            .foregroundColor(.v2xTextTertiary)
                    }
                }

                HStack(spacing: 16) {
                    ScoreGauge(label: "Сеть", score: aiSmartConnect.networkScore, color: .v2xCyan)
                    ScoreGauge(label: "Стабильность", score: aiSmartConnect.stabilityScore, color: .v2xGreen)
                    ScoreGauge(label: "Скорость", score: aiSmartConnect.speedScore, color: .v2xPurple)
                    ScoreGauge(label: "Задержка", score: aiSmartConnect.latencyScore, color: .v2xYellow)
                }

                // Recommended protocol
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundColor(.v2xYellow)

                    Text("Рекомендуемый протокол:")
                        .font(.system(size: 12))
                        .foregroundColor(.v2xTextTertiary)

                    Text(aiSmartConnect.recommendedProtocol.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(aiSmartConnect.recommendedProtocol.color)

                    Spacer()
                }
                .padding(10)
                .liquidGlassBackground(cornerRadius: 10)
            }
            .padding(16)
        }
    }

    private var serverRecommendations: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Рекомендации серверов")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            ForEach(Array(aiSmartConnect.analysisResults.prefix(5).enumerated()), id: \.element.id) { index, result in
                serverRecommendationCard(result, rank: index + 1)
            }
        }
    }

    private func serverRecommendationCard(_ result: AISmartConnect.AnalysisResult, rank: Int) -> some View {
        LiquidGlassCard(cornerRadius: 16) {
            HStack(spacing: 12) {
                // Rank
                ZStack {
                    Circle()
                        .fill(rank == 1 ? Color.v2xGreen.opacity(0.2) : Color.white.opacity(0.05))
                        .frame(width: 32, height: 32)

                    Text("#\(rank)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(rank == 1 ? .v2xGreen : .v2xTextTertiary)
                }

                Text(result.server.flag)
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 2) {
                    Text(result.server.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Text(result.reason)
                        .font(.system(size: 11))
                        .foregroundColor(.v2xTextTertiary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(result.score * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(result.score > 0.8 ? .v2xGreen : .v2xYellow)

                    Text("\(result.estimatedPing) ms")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.v2xTextTertiary)
                }
            }
            .padding(12)
        }
    }
}
