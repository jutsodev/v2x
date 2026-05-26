// TrafficGraph.swift
// V2X

import SwiftUI

struct TrafficGraph: View {
    @EnvironmentObject var statsTracker: StatsTracker
    @EnvironmentObject var themeManager: ThemeManager

    let height: CGFloat
    let showLabels: Bool

    init(height: CGFloat = 120, showLabels: Bool = true) {
        self.height = height
        self.showLabels = showLabels
    }

    var body: some View {
        VStack(spacing: 8) {
            if showLabels {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.v2xCyan)
                            .frame(width: 6, height: 6)
                        Text("Download")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.v2xTextSecondary)
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.v2xPurple)
                            .frame(width: 6, height: 6)
                        Text("Upload")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.v2xTextSecondary)
                    }
                }
            }

            GeometryReader { geometry in
                let width = geometry.size.width
                let graphHeight = geometry.size.height
                let dataPoints = statsTracker.trafficHistory
                let maxValue = max(statsTracker.maxDownloadSpeed, statsTracker.maxUploadSpeed, 1)

                ZStack {
                    // Grid lines
                    ForEach(0..<5, id: \.self) { i in
                        let y = graphHeight * CGFloat(i) / 4
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                        .stroke(Color.white.opacity(0.05), lineWidth: 0.5)
                    }

                    // Download line
                    if dataPoints.count > 1 {
                        downloadPath(in: CGSize(width: width, height: graphHeight), maxValue: maxValue)
                            .fill(
                                LinearGradient(
                                    colors: [Color.v2xCyan.opacity(0.3), Color.v2xCyan.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        downloadStrokePath(in: CGSize(width: width, height: graphHeight), maxValue: maxValue)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.v2xCyan, Color.v2xCyan.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                            )
                            .shadow(color: Color.v2xCyan.opacity(0.5), radius: 4)
                    }

                    // Upload line
                    if dataPoints.count > 1 {
                        uploadPath(in: CGSize(width: width, height: graphHeight), maxValue: maxValue)
                            .fill(
                                LinearGradient(
                                    colors: [Color.v2xPurple.opacity(0.2), Color.v2xPurple.opacity(0.0)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        uploadStrokePath(in: CGSize(width: width, height: graphHeight), maxValue: maxValue)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.v2xPurple, Color.v2xPurple.opacity(0.5)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
                            )
                            .shadow(color: Color.v2xPurple.opacity(0.4), radius: 3)
                    }

                    // Current value dots
                    if let last = dataPoints.last {
                        let x = width
                        let downloadY = graphHeight * (1 - CGFloat(last.downloadSpeed / maxValue))
                        let uploadY = graphHeight * (1 - CGFloat(last.uploadSpeed / maxValue))

                        Circle()
                            .fill(Color.v2xCyan)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: downloadY)
                            .shadow(color: Color.v2xCyan.opacity(0.6), radius: 4)

                        Circle()
                            .fill(Color.v2xPurple)
                            .frame(width: 5, height: 5)
                            .position(x: x, y: uploadY)
                            .shadow(color: Color.v2xPurple.opacity(0.5), radius: 3)
                    }
                }
            }
            .frame(height: height)

            if showLabels {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("↓ " + String.formatSpeed(statsTracker.currentDownloadSpeed))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.v2xCyan)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("↑ " + String.formatSpeed(statsTracker.currentUploadSpeed))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.v2xPurple)
                    }
                }
            }
        }
    }

    // MARK: - Path Builders
    private func downloadStrokePath(in size: CGSize, maxValue: Double) -> Path {
        let dataPoints = statsTracker.trafficHistory
        return buildStrokePath(dataPoints: dataPoints.map(\.downloadSpeed), in: size, maxValue: maxValue)
    }

    private func uploadStrokePath(in size: CGSize, maxValue: Double) -> Path {
        let dataPoints = statsTracker.trafficHistory
        return buildStrokePath(dataPoints: dataPoints.map(\.uploadSpeed), in: size, maxValue: maxValue)
    }

    private func downloadPath(in size: CGSize, maxValue: Double) -> Path {
        let dataPoints = statsTracker.trafficHistory
        return buildFillPath(dataPoints: dataPoints.map(\.downloadSpeed), in: size, maxValue: maxValue)
    }

    private func uploadPath(in size: CGSize, maxValue: Double) -> Path {
        let dataPoints = statsTracker.trafficHistory
        return buildFillPath(dataPoints: dataPoints.map(\.uploadSpeed), in: size, maxValue: maxValue)
    }

    private func buildStrokePath(dataPoints: [Double], in size: CGSize, maxValue: Double) -> Path {
        Path { path in
            guard dataPoints.count > 1 else { return }

            let step = size.width / CGFloat(dataPoints.count - 1)

            for (index, value) in dataPoints.enumerated() {
                let x = step * CGFloat(index)
                let y = size.height * (1 - CGFloat(value / maxValue))
                let point = CGPoint(x: x, y: y)

                if index == 0 {
                    path.move(to: point)
                } else {
                    let prevX = step * CGFloat(index - 1)
                    let prevValue = dataPoints[index - 1]
                    let prevY = size.height * (1 - CGFloat(prevValue / maxValue))

                    let controlX1 = prevX + (x - prevX) * 0.5
                    let controlX2 = x - (x - prevX) * 0.5
                    path.addCurve(
                        to: point,
                        control1: CGPoint(x: controlX1, y: prevY),
                        control2: CGPoint(x: controlX2, y: y)
                    )
                }
            }
        }
    }

    private func buildFillPath(dataPoints: [Double], in size: CGSize, maxValue: Double) -> Path {
        var path = buildStrokePath(dataPoints: dataPoints, in: size, maxValue: maxValue)
        let step = size.width / CGFloat(max(dataPoints.count - 1, 1))
        path.addLine(to: CGPoint(x: step * CGFloat(dataPoints.count - 1), y: size.height))
        path.addLine(to: CGPoint(x: 0, y: size.height))
        path.closeSubpath()
        return path
    }
}

// MARK: - Mini Traffic Graph
struct MiniTrafficGraph: View {
    @EnvironmentObject var statsTracker: StatsTracker
    let color: Color
    let dataKey: KeyPath<StatsTracker.TrafficDataPoint, Double>
    let height: CGFloat

    init(color: Color = .v2xCyan, dataKey: KeyPath<StatsTracker.TrafficDataPoint, Double> = \.downloadSpeed, height: CGFloat = 40) {
        self.color = color
        self.dataKey = dataKey
        self.height = height
    }

    var body: some View {
        GeometryReader { geometry in
            let data = statsTracker.trafficHistory.map { $0[keyPath: dataKey] }
            let maxVal = data.max() ?? 1

            Path { path in
                guard data.count > 1 else { return }
                let step = geometry.size.width / CGFloat(data.count - 1)

                for (i, value) in data.enumerated() {
                    let x = step * CGFloat(i)
                    let y = geometry.size.height * (1 - CGFloat(value / maxVal))
                    if i == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(color, style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
            .shadow(color: color.opacity(0.4), radius: 3)
        }
        .frame(height: height)
    }
}
