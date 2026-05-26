// ExportConfigView.swift
// V2X

import SwiftUI

struct ExportConfigView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProfiles: Set<UUID> = []
    @State private var exportFormat: ExportFormat = .url
    @State private var exportedText = ""
    @State private var showCopied = false
    @State private var selectAll = false

    enum ExportFormat: String, CaseIterable {
        case url = "URL"
        case base64 = "Base64"
        case json = "JSON"
        case qrcode = "QR код"
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Format selector
                    formatSelector

                    // Profile selection
                    profileSelection

                    // Export button
                    exportButton

                    // Result
                    if !exportedText.isEmpty {
                        exportResult
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
                    Text("Экспорт конфигурации")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var formatSelector: some View {
        HStack(spacing: 8) {
            ForEach(ExportFormat.allCases, id: \.self) { format in
                Button {
                    withAnimation(.v2xSnappy) {
                        exportFormat = format
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: formatIcon(format))
                            .font(.system(size: 18))
                        Text(format.rawValue)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(exportFormat == format ? .white : .v2xTextTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(exportFormat == format ? themeManager.currentTheme.accentColor.opacity(0.2) : Color.clear)
                    )
                }
                .buttonStyle(LiquidPressButtonStyle())
            }
        }
    }

    private func formatIcon(_ format: ExportFormat) -> String {
        switch format {
        case .url: return "link"
        case .base64: return "lock.fill"
        case .json: return "curlybraces"
        case .qrcode: return "qrcode"
        }
    }

    private var profileSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Выберите профили")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.v2xTextTertiary)
                    .textCase(.uppercase)

                Spacer()

                Button {
                    selectAll.toggle()
                    if selectAll {
                        selectedProfiles = Set(profileManager.profiles.map(\.id))
                    } else {
                        selectedProfiles.removeAll()
                    }
                } label: {
                    Text(selectAll ? "Снять все" : "Выбрать все")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.v2xCyan)
                }
            }
            .padding(.leading, 4)

            GlassSectionCard {
                ForEach(Array(profileManager.profiles.enumerated()), id: \.element.id) { index, profile in
                    Button {
                        if selectedProfiles.contains(profile.id) {
                            selectedProfiles.remove(profile.id)
                        } else {
                            selectedProfiles.insert(profile.id)
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: selectedProfiles.contains(profile.id) ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundColor(selectedProfiles.contains(profile.id) ? .v2xCyan : .gray)

                            Image(systemName: profile.protocolType.icon)
                                .font(.system(size: 14))
                                .foregroundColor(profile.protocolType.color)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(profile.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)

                                Text(profile.protocolType.rawValue)
                                    .font(.system(size: 11))
                                    .foregroundColor(.v2xTextTertiary)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    if index < profileManager.profiles.count - 1 {
                        Divider().background(Color.white.opacity(0.06)).padding(.leading, 56)
                    }
                }
            }
        }
    }

    private var exportButton: some View {
        Button {
            performExport()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up.fill")
                    .font(.system(size: 16))
                Text("Экспортировать (\(selectedProfiles.count))")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: themeManager.currentTheme.gradientColors.prefix(2).map { $0 },
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .buttonStyle(LiquidPressButtonStyle())
        .disabled(selectedProfiles.isEmpty)
        .opacity(selectedProfiles.isEmpty ? 0.5 : 1)
    }

    private var exportResult: some View {
        LiquidGlassCard(cornerRadius: 16) {
            VStack(spacing: 10) {
                HStack {
                    Text("Результат экспорта")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        UIPasteboard.general.string = exportedText
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            showCopied = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showCopied = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 12))
                            Text(showCopied ? "Скопировано!" : "Копировать")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(showCopied ? .v2xGreen : .v2xCyan)
                    }
                }

                Text(exportedText)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.v2xTextSecondary)
                    .lineLimit(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.03))
                    )
            }
            .padding(14)
        }
    }

    private func performExport() {
        let selected = profileManager.profiles.filter { selectedProfiles.contains($0.id) }

        switch exportFormat {
        case .url:
            exportedText = selected.map { profile in
                "\(profile.protocolType.urlScheme)://\(profile.serverAddress):\(profile.port)#\(profile.name)"
            }.joined(separator: "\n")

        case .base64:
            let urls = selected.map { profile in
                "\(profile.protocolType.urlScheme)://\(profile.serverAddress):\(profile.port)#\(profile.name)"
            }.joined(separator: "\n")
            exportedText = urls.base64Encoded ?? ""

        case .json:
            let configs = selected.map { profile in
                """
                {"name":"\(profile.name)","protocol":"\(profile.protocolType.rawValue)","server":"\(profile.serverAddress)","port":\(profile.port)}
                """
            }
            exportedText = "[\(configs.joined(separator: ","))]"

        case .qrcode:
            exportedText = selected.map { profile in
                "\(profile.protocolType.urlScheme)://\(profile.serverAddress):\(profile.port)#\(profile.name)"
            }.joined(separator: "\n")
        }

        HapticManager.shared.triggerNotification(.success)
    }
}
