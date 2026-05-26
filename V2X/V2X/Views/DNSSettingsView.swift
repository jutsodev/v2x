// DNSSettingsView.swift
// V2X

import SwiftUI

struct DNSSettingsView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var showAddCustomDNS = false
    @State private var customName = ""
    @State private var customPrimary = ""
    @State private var customSecondary = ""
    @State private var customDoH = ""

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Current DNS
                    currentDNSCard

                    // Presets
                    settingsSection(title: "DNS Presets") {
                        ForEach(Array(profileManager.dnsConfigurations.enumerated()), id: \.element.id) { index, dns in
                            Button {
                                profileManager.setActiveDNS(dns)
                            } label: {
                                dnsRow(dns)
                            }
                            .buttonStyle(LiquidPressButtonStyle())

                            if index < profileManager.dnsConfigurations.count - 1 {
                                Divider()
                                    .background(Color.white.opacity(0.06))
                                    .padding(.leading, 56)
                            }
                        }
                    }

                    // Custom DNS
                    settingsSection(title: "Custom DNS") {
                        Button {
                            showAddCustomDNS = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.v2xCyan)

                                Text("Добавить custom DNS")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.v2xCyan)

                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(LiquidPressButtonStyle())
                    }

                    // Info
                    LiquidGlassCard(cornerRadius: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.v2xBlue)
                                Text("О DNS")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                            }

                            Text("DNS-over-HTTPS (DoH) и DNS-over-TLS (DoT) шифруют DNS-запросы, защищая от перехвата и подмены. Рекомендуется использовать DoH для максимальной безопасности.")
                                .font(.system(size: 12))
                                .foregroundColor(.v2xTextTertiary)
                                .lineSpacing(2)
                        }
                        .padding(14)
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
                    Text("DNS настройки")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $showAddCustomDNS) {
                customDNSSheet
            }
        }
    }

    // MARK: - Current DNS Card
    private var currentDNSCard: some View {
        LiquidGlassCard(cornerRadius: 20, glowColor: .v2xCyan, glowRadius: 5) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "server.rack")
                        .font(.system(size: 20))
                        .foregroundColor(.v2xCyan)

                    Text("Активный DNS")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Text(profileManager.activeDNS?.type.rawValue ?? "Standard")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.v2xCyan)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color.v2xCyan.opacity(0.15))
                        )
                }

                if let dns = profileManager.activeDNS {
                    VStack(spacing: 8) {
                        dnsInfoRow(label: "Primary", value: dns.primaryDNS)
                        dnsInfoRow(label: "Secondary", value: dns.secondaryDNS)
                        if !dns.dnsOverHTTPS.isEmpty {
                            dnsInfoRow(label: "DoH", value: dns.dnsOverHTTPS)
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    private func dnsInfoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.v2xTextTertiary)
                .frame(width: 70, alignment: .leading)

            Text(value)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.v2xTextSecondary)
                .lineLimit(1)

            Spacer()
        }
    }

    private func dnsRow(_ dns: DNSConfiguration) -> some View {
        HStack(spacing: 12) {
            Image(systemName: dns.id == profileManager.activeDNS?.id ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 20))
                .foregroundColor(dns.id == profileManager.activeDNS?.id ? .v2xCyan : .gray)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(dns.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Text(dns.primaryDNS)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.v2xTextTertiary)

                    Text("•")
                        .foregroundColor(.v2xTextTertiary)

                    Text(dns.type.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.v2xCyan)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
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

    // MARK: - Custom DNS Sheet
    private var customDNSSheet: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    customDNSField(title: "Название", text: $customName, placeholder: "My DNS")
                    customDNSField(title: "Primary DNS", text: $customPrimary, placeholder: "1.1.1.1")
                    customDNSField(title: "Secondary DNS", text: $customSecondary, placeholder: "8.8.8.8")
                    customDNSField(title: "DNS-over-HTTPS", text: $customDoH, placeholder: "https://...")

                    LiquidGlassButton("Сохранить", icon: "checkmark.circle.fill", color: .v2xGreen) {
                        let dns = DNSConfiguration(
                            name: customName.isEmpty ? "Custom DNS" : customName,
                            primaryDNS: customPrimary,
                            secondaryDNS: customSecondary,
                            dnsOverHTTPS: customDoH,
                            type: customDoH.isEmpty ? .standard : .doh
                        )
                        profileManager.dnsConfigurations.append(dns)
                        showAddCustomDNS = false
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
            }
            .background(Color.v2xBackground.ignoresSafeArea())
            .navigationTitle("Custom DNS")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { showAddCustomDNS = false }
                        .foregroundColor(.v2xCyan)
                }
            }
        }
    }

    private func customDNSField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.v2xTextSecondary)

            TextField(placeholder, text: text)
                .font(.system(size: 15, design: .monospaced))
                .foregroundColor(.white)
                .padding(12)
                .liquidGlassBackground(cornerRadius: 12)
        }
    }
}
