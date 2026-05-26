// LogsView.swift
// V2X

import SwiftUI

struct LogsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var logs: [LogEntry] = LogEntry.samples
    @State private var filterLevel: LogEntry.LogLevel?
    @State private var searchText = ""
    @State private var autoScroll = true
    @State private var showClearAlert = false

    var filteredLogs: [LogEntry] {
        var result = logs
        if let level = filterLevel {
            result = result.filter { $0.level == level }
        }
        if !searchText.isEmpty {
            result = result.filter {
                $0.message.localizedCaseInsensitiveContains(searchText) ||
                $0.source.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter bar
                filterBar

                // Logs list
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 2) {
                            ForEach(filteredLogs) { log in
                                logRow(log)
                                    .id(log.id)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                }
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
                    Text("Логи")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 8) {
                        Button {
                            showClearAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(.v2xRed)
                        }

                        Button {
                            // Export logs
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 14))
                                .foregroundColor(.v2xCyan)
                        }
                    }
                }
            }
            .alert("Очистить логи?", isPresented: $showClearAlert) {
                Button("Отмена", role: .cancel) {}
                Button("Очистить", role: .destructive) {
                    logs.removeAll()
                }
            }
        }
    }

    private var filterBar: some View {
        VStack(spacing: 8) {
            // Search
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 13))
                    .foregroundColor(.v2xTextTertiary)

                TextField("Поиск в логах...", text: $searchText)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.04))
            )

            // Level filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    levelFilterButton("Все", level: nil, count: logs.count)
                    levelFilterButton("INFO", level: .info, count: logs.filter { $0.level == .info }.count)
                    levelFilterButton("WARN", level: .warning, count: logs.filter { $0.level == .warning }.count)
                    levelFilterButton("ERROR", level: .error, count: logs.filter { $0.level == .error }.count)
                    levelFilterButton("DEBUG", level: .debug, count: logs.filter { $0.level == .debug }.count)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "0A0A0A"))
    }

    private func levelFilterButton(_ title: String, level: LogEntry.LogLevel?, count: Int) -> some View {
        Button {
            filterLevel = level
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                Text("\(count)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
            }
            .foregroundColor(filterLevel == level ? .white : .v2xTextSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(filterLevel == level ? (level?.color ?? Color.v2xCyan).opacity(0.25) : Color.white.opacity(0.04))
            )
        }
    }

    private func logRow(_ log: LogEntry) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(log.level.rawValue)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(log.level.color)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(log.message)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(3)

                HStack(spacing: 6) {
                    Text(log.source)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.v2xTextTertiary)

                    Text(log.timestamp, style: .time)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.v2xTextTertiary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
    }
}
