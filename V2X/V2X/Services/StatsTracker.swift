// StatsTracker.swift
// V2X

import SwiftUI
import Combine

final class StatsTracker: ObservableObject {
    static let shared = StatsTracker()

    @Published var trafficHistory: [TrafficDataPoint] = []
    @Published var dailyStats: [DailyStat] = []
    @Published var totalAllTimeUpload: Int64 = 156_000_000_000
    @Published var totalAllTimeDownload: Int64 = 892_000_000_000
    @Published var totalSessions: Int = 1_247
    @Published var averageSessionDuration: TimeInterval = 3_600 * 2.5

    private var historyTimer: Timer?

    struct TrafficDataPoint: Identifiable {
        let id = UUID()
        var timestamp: Date
        var uploadSpeed: Double
        var downloadSpeed: Double
    }

    struct DailyStat: Identifiable {
        let id = UUID()
        var date: Date
        var upload: Int64
        var download: Int64
        var sessions: Int
        var duration: TimeInterval
    }

    private init() {
        generateHistoricalData()
    }

    func startTracking() {
        historyTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let point = TrafficDataPoint(
                timestamp: Date(),
                uploadSpeed: Double.random(in: 500_000...5_000_000),
                downloadSpeed: Double.random(in: 1_000_000...20_000_000)
            )
            withAnimation(.linear(duration: 0.3)) {
                self.trafficHistory.append(point)
                if self.trafficHistory.count > 60 {
                    self.trafficHistory.removeFirst()
                }
            }
        }
    }

    func stopTracking() {
        historyTimer?.invalidate()
        historyTimer = nil
    }

    private func generateHistoricalData() {
        // Generate last 60 data points
        for i in (0..<60).reversed() {
            let point = TrafficDataPoint(
                timestamp: Date().addingTimeInterval(-Double(i) * 2),
                uploadSpeed: Double.random(in: 500_000...5_000_000),
                downloadSpeed: Double.random(in: 1_000_000...20_000_000)
            )
            trafficHistory.append(point)
        }

        // Generate last 7 days
        let calendar = Calendar.current
        for i in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()) else { continue }
            let stat = DailyStat(
                date: date,
                upload: Int64.random(in: 1_000_000_000...10_000_000_000),
                download: Int64.random(in: 5_000_000_000...50_000_000_000),
                sessions: Int.random(in: 5...25),
                duration: Double.random(in: 3600...36000)
            )
            dailyStats.append(stat)
        }
    }

    var currentUploadSpeed: Double {
        trafficHistory.last?.uploadSpeed ?? 0
    }

    var currentDownloadSpeed: Double {
        trafficHistory.last?.downloadSpeed ?? 0
    }

    var maxUploadSpeed: Double {
        trafficHistory.map(\.uploadSpeed).max() ?? 0
    }

    var maxDownloadSpeed: Double {
        trafficHistory.map(\.downloadSpeed).max() ?? 0
    }
}
