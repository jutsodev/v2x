// ServerListView.swift
// V2X

import SwiftUI

struct ServerListView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var selectedCountry: String?
    @State private var sortMode: SortMode = .ping
    @State private var isPingAll = false

    enum SortMode: String, CaseIterable {
        case name = "Имя"
        case ping = "Пинг"
        case load = "Нагрузка"
    }

    private var servers: [ServerNode] {
        ServerNode.sampleServers
    }

    private var filteredServers: [ServerNode] {
        var result = servers
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.country.localizedCaseInsensitiveContains(searchText) ||
                $0.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let country = selectedCountry {
            result = result.filter { $0.country == country }
        }

        switch sortMode {
        case .name:
            result.sort { $0.name < $1.name }
        case .ping:
            result.sort { ($0.ping ?? 999) < ($1.ping ?? 999) }
        case .load:
            result.sort { $0.load < $1.load }
        }
        return result
    }

    private var countries: [String] {
        Array(Set(servers.map(\.country))).sorted()
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Search
                    LiquidGlassSearchBar(text: $searchText, placeholder: "Поиск серверов...")

                    // Sort & Filter
                    HStack(spacing: 8) {
                        LiquidGlassSegmentedControl(
                            options: SortMode.allCases.map(\.rawValue),
                            selectedIndex: Binding(
                                get: { SortMode.allCases.firstIndex(of: sortMode) ?? 0 },
                                set: { sortMode = SortMode.allCases[$0] }
                            )
                        )

                        Button {
                            isPingAll = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isPingAll = false
                            }
                        } label: {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 16))
                                .foregroundColor(.v2xCyan)
                                .frame(width: 44, height: 36)
                                .liquidGlassBackground(cornerRadius: 10)
                        }
                    }

                    // Country Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            LiquidGlassChip(title: "Все", isSelected: selectedCountry == nil) {
                                selectedCountry = nil
                            }
                            ForEach(countries, id: \.self) { country in
                                let flag = servers.first { $0.country == country }?.flag ?? "🌍"
                                LiquidGlassChip(title: "\(flag) \(country)", isSelected: selectedCountry == country) {
                                    selectedCountry = selectedCountry == country ? nil : country
                                }
                            }
                        }
                    }

                    // Server List
                    VStack(spacing: 8) {
                        ForEach(filteredServers) { server in
                            serverCard(server)
                        }
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
                    Text("Серверы (\(filteredServers.count))")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func serverCard(_ server: ServerNode) -> some View {
        LiquidGlassCard(cornerRadius: 16) {
            HStack(spacing: 14) {
                // Flag
                Text(server.flag)
                    .font(.system(size: 28))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(server.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)

                        if server.isPremium {
                            StatusBadge(text: "PRO", color: .v2xYellow, icon: "crown.fill")
                        }
                    }

                    HStack(spacing: 6) {
                        Text(server.protocolType)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.v2xCyan)

                        Text("•")
                            .foregroundColor(.v2xTextTertiary)

                        Text(server.address)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.v2xTextTertiary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Metrics
                VStack(alignment: .trailing, spacing: 4) {
                    if let ping = server.ping {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(server.pingColor)
                                .frame(width: 6, height: 6)
                            Text("\(ping) ms")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(server.pingColor)
                        }
                    }

                    HStack(spacing: 3) {
                        Text("Load:")
                            .font(.system(size: 10))
                            .foregroundColor(.v2xTextTertiary)
                        Text(server.formattedLoad)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(server.loadColor)
                    }
                }

                // Connect button
                Button {
                    HapticManager.shared.triggerNotification(.success)
                } label: {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.v2xCyan)
                        .frame(width: 36, height: 36)
                        .liquidGlassBackground(cornerRadius: 10)
                }
                .buttonStyle(LiquidPressButtonStyle())
            }
            .padding(12)
        }
    }
}
