// RoutingView.swift
// V2X

import SwiftUI

struct RoutingView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var showAddRule = false
    @State private var newRuleName = ""
    @State private var newRuleDomain = ""
    @State private var newRuleAction: RoutingRule.RoutingAction = .proxy

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Routing Status
                    routingStatusCard

                    // GeoFiles
                    settingsSection(title: "GeoFiles") {
                        ForEach(Array(profileManager.geoFiles.enumerated()), id: \.element.id) { index, file in
                            geoFileRow(file)

                            if index < profileManager.geoFiles.count - 1 {
                                Divider()
                                    .background(Color.white.opacity(0.06))
                                    .padding(.leading, 56)
                            }
                        }
                    }

                    // Auto Update
                    settingsSection(title: "Автообновление") {
                        SettingsToggleRow(
                            icon: "arrow.triangle.2.circlepath",
                            iconColor: .v2xGreen,
                            title: "GeoIP автообновление",
                            isOn: $profileManager.geoIPAutoUpdate
                        )

                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 56)

                        SettingsToggleRow(
                            icon: "arrow.triangle.2.circlepath",
                            iconColor: .v2xPurple,
                            title: "GeoSite автообновление",
                            isOn: $profileManager.geoSiteAutoUpdate
                        )
                    }

                    // Routing Rules
                    settingsSection(title: "Правила роутинга (\(profileManager.routingRules.count))") {
                        ForEach(Array(profileManager.routingRules.enumerated()), id: \.element.id) { index, rule in
                            routingRuleRow(rule)

                            if index < profileManager.routingRules.count - 1 {
                                Divider()
                                    .background(Color.white.opacity(0.06))
                                    .padding(.leading, 56)
                            }
                        }

                        Button {
                            showAddRule = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.v2xCyan)
                                Text("Добавить правило")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.v2xCyan)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(LiquidPressButtonStyle())
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
                    Text("Роутинг")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showAddRule) {
                addRuleSheet
            }
        }
    }

    private var routingStatusCard: some View {
        LiquidGlassCard(cornerRadius: 20) {
            HStack(spacing: 16) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 24))
                    .foregroundColor(profileManager.routingEnabled ? .v2xGreen : .gray)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Роутинг")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)

                    Text("\(profileManager.routingRules.count) активных правил")
                        .font(.system(size: 12))
                        .foregroundColor(.v2xTextTertiary)
                }

                Spacer()

                LiquidGlassToggle(isOn: $profileManager.routingEnabled)
            }
            .padding(16)
        }
    }

    private func geoFileRow(_ file: GeoFile) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "globe")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.v2xCyan)
                .frame(width: 32, height: 32)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.v2xCyan.opacity(0.12))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    Text(file.fileName)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.v2xTextTertiary)
                    Text("•")
                        .foregroundColor(.v2xTextTertiary)
                    Text(file.size)
                        .font(.system(size: 11))
                        .foregroundColor(.v2xTextTertiary)
                }
            }

            Spacer()

            Button {
                profileManager.updateGeoFile(file)
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 14))
                    .foregroundColor(.v2xCyan)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func routingRuleRow(_ rule: RoutingRule) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(ruleColor(rule.action))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(rule.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Text(rule.domain)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.v2xTextTertiary)
            }

            Spacer()

            Text(rule.action.rawValue)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(ruleColor(rule.action))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(ruleColor(rule.action).opacity(0.12))
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func ruleColor(_ action: RoutingRule.RoutingAction) -> Color {
        switch action {
        case .proxy: return .v2xCyan
        case .direct: return .v2xGreen
        case .block: return .v2xRed
        }
    }

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)
            GlassSectionCard { content() }
        }
    }

    private var addRuleSheet: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Название")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.v2xTextSecondary)
                        TextField("Rule Name", text: $newRuleName)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(12)
                            .liquidGlassBackground(cornerRadius: 12)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Домен / IP")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.v2xTextSecondary)
                        TextField("*.example.com", text: $newRuleDomain)
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(12)
                            .liquidGlassBackground(cornerRadius: 12)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Действие")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.v2xTextSecondary)

                        HStack(spacing: 8) {
                            ForEach(RoutingRule.RoutingAction.allCases, id: \.self) { action in
                                Button {
                                    newRuleAction = action
                                } label: {
                                    Text(action.rawValue)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(newRuleAction == action ? .white : .v2xTextSecondary)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(newRuleAction == action ? ruleColor(action).opacity(0.3) : Color.white.opacity(0.05))
                                        )
                                }
                            }
                        }
                    }

                    LiquidGlassButton("Добавить", icon: "plus.circle.fill", color: .v2xGreen) {
                        let rule = RoutingRule(
                            name: newRuleName.isEmpty ? "New Rule" : newRuleName,
                            domain: newRuleDomain,
                            action: newRuleAction
                        )
                        profileManager.addRoutingRule(rule)
                        showAddRule = false
                        newRuleName = ""
                        newRuleDomain = ""
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
            }
            .background(Color.v2xBackground.ignoresSafeArea())
            .navigationTitle("Новое правило")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { showAddRule = false }
                        .foregroundColor(.v2xCyan)
                }
            }
        }
    }
}
