// LocalProfilesView.swift
// V2X

import SwiftUI

struct LocalProfilesView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var vpnManager: VPNManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var showAddProfile = false
    @State private var showImportSheet = false
    @State private var importURL = ""
    @State private var searchText = ""
    @State private var selectedFilter: VPNProtocolType?
    @State private var showDeleteAlert = false
    @State private var profileToDelete: VPNProfile?

    var filteredProfiles: [VPNProfile] {
        var profiles = profileManager.profiles
        if !searchText.isEmpty {
            profiles = profiles.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.serverAddress.localizedCaseInsensitiveContains(searchText) ||
                $0.protocolType.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        if let filter = selectedFilter {
            profiles = profiles.filter { $0.protocolType == filter }
        }
        return profiles
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Search bar
                    searchBar

                    // Protocol filter
                    protocolFilter

                    // Quick Import
                    quickImportCard

                    // Profiles List
                    if filteredProfiles.isEmpty {
                        emptyState
                    } else {
                        profilesList
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
                    Text("Локальные профили")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddProfile = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.v2xCyan)
                            .frame(width: 36, height: 36)
                            .liquidGlassBackground(cornerRadius: 10)
                    }
                }
            }
            .sheet(isPresented: $showAddProfile) {
                ConfigImportView()
            }
            .alert("Удалить профиль?", isPresented: $showDeleteAlert) {
                Button("Отмена", role: .cancel) {}
                Button("Удалить", role: .destructive) {
                    if let profile = profileToDelete {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            profileManager.deleteProfile(profile)
                        }
                    }
                }
            } message: {
                if let profile = profileToDelete {
                    Text("Профиль \"\(profile.name)\" будет удалён безвозвратно.")
                }
            }
        }
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundColor(.v2xTextTertiary)

            TextField("Поиск профилей...", text: $searchText)
                .font(.system(size: 15))
                .foregroundColor(.white)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.v2xTextTertiary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlassBackground(cornerRadius: 14)
    }

    // MARK: - Protocol Filter
    private var protocolFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(title: "Все", isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }

                ForEach(VPNProtocolType.allCases) { proto in
                    filterChip(
                        title: proto.rawValue,
                        isSelected: selectedFilter == proto,
                        color: proto.color
                    ) {
                        selectedFilter = selectedFilter == proto ? nil : proto
                    }
                }
            }
        }
    }

    private func filterChip(title: String, isSelected: Bool, color: Color = .v2xCyan, action: @escaping () -> Void) -> some View {
        Button(action: {
            HapticManager.shared.triggerImpact(.light)
            action()
        }) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .v2xTextSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? color.opacity(0.3) : Color.white.opacity(0.05))
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? color.opacity(0.5) : Color.clear, lineWidth: 0.5)
                        )
                )
        }
        .buttonStyle(LiquidPressButtonStyle())
    }

    // MARK: - Quick Import
    private var quickImportCard: some View {
        LiquidGlassCard(cornerRadius: 16) {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "link.badge.plus")
                        .font(.system(size: 14))
                        .foregroundColor(.v2xCyan)

                    Text("Быстрый импорт")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()
                }

                HStack(spacing: 8) {
                    TextField("vless://... или trojan://...", text: $importURL)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                                )
                        )

                    Button {
                        guard !importURL.isEmpty else { return }
                        profileManager.importConfig(from: importURL)
                        importURL = ""
                    } label: {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.v2xCyan)
                    }
                    .buttonStyle(LiquidPressButtonStyle())
                    .disabled(importURL.isEmpty)
                }
            }
            .padding(14)
        }
    }

    // MARK: - Profiles List
    private var profilesList: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(filteredProfiles.count) профилей")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.v2xTextTertiary)
                Spacer()
            }
            .padding(.leading, 4)

            ForEach(filteredProfiles) { profile in
                profileCard(profile)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
            }
        }
    }

    private func profileCard(_ profile: VPNProfile) -> some View {
        LiquidGlassCard(
            cornerRadius: 16,
            glowColor: profile.isActive ? themeManager.currentTheme.accentColor : nil,
            glowRadius: profile.isActive ? 5 : 0
        ) {
            HStack(spacing: 14) {
                // Protocol icon
                ZStack {
                    Circle()
                        .fill(profile.protocolType.color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: profile.protocolType.icon)
                        .font(.system(size: 18))
                        .foregroundColor(profile.protocolType.color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(profile.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)

                        if profile.isActive {
                            Text("ACTIVE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.v2xGreen)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.v2xGreen.opacity(0.15))
                                )
                        }
                    }

                    HStack(spacing: 8) {
                        Text(profile.protocolType.rawValue)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(profile.protocolType.color)

                        if !profile.serverAddress.isEmpty {
                            Text("•")
                                .foregroundColor(.v2xTextTertiary)

                            Text(profile.displayAddress)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.v2xTextTertiary)
                        }
                    }

                    if let ping = profile.ping {
                        Text("\(ping) ms")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(ping < 50 ? .v2xGreen : ping < 100 ? .v2xYellow : .v2xRed)
                    }
                }

                Spacer()

                // Actions
                VStack(spacing: 8) {
                    Button {
                        profileManager.setActiveProfile(profile)
                        HapticManager.shared.triggerNotification(.success)
                    } label: {
                        Image(systemName: profile.isActive ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 22))
                            .foregroundColor(profile.isActive ? .v2xGreen : .gray)
                    }

                    Button {
                        profileToDelete = profile
                        showDeleteAlert = true
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(.v2xRed.opacity(0.6))
                    }
                }
            }
            .padding(14)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.v2xTextTertiary)

            Text("Нет профилей")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.v2xTextSecondary)

            Text("Добавьте конфигурацию через ссылку\nили импортируйте из Telegram")
                .font(.system(size: 13))
                .foregroundColor(.v2xTextTertiary)
                .multilineTextAlignment(.center)

            LiquidGlassButton("Добавить профиль", icon: "plus.circle.fill") {
                showAddProfile = true
            }
        }
        .padding(.vertical, 40)
    }
}
