// ConfigImportView.swift
// V2X

import SwiftUI

struct ConfigImportView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var configText = ""
    @State private var selectedProtocol: VPNProtocolType?
    @State private var importMode: ImportMode = .url
    @State private var showSuccess = false
    @State private var importAnimation = false

    enum ImportMode: String, CaseIterable {
        case url = "URL"
        case clipboard = "Буфер"
        case qrcode = "QR код"
        case telegram = "Telegram"
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Import Mode Selector
                    importModeSelector

                    // Protocol Quick Select
                    protocolSelector

                    // Import Area
                    importArea

                    // Import Button
                    importButton

                    // Success Animation
                    if showSuccess {
                        successCard
                            .transition(.v2xPop)
                    }

                    // Supported Protocols
                    supportedProtocolsCard

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
                    Text("Импорт конфигурации")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .onChange(of: profileManager.importResult?.id) { _ in
                if let result = profileManager.importResult, result.success {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showSuccess = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Import Mode Selector
    private var importModeSelector: some View {
        HStack(spacing: 8) {
            ForEach(ImportMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.v2xSnappy) {
                        importMode = mode
                    }
                    HapticManager.shared.triggerImpact(.light)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: modeIcon(mode))
                            .font(.system(size: 18))
                        Text(mode.rawValue)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(importMode == mode ? .white : .v2xTextTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(importMode == mode ? themeManager.currentTheme.accentColor.opacity(0.2) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        importMode == mode ? themeManager.currentTheme.accentColor.opacity(0.4) : Color.clear,
                                        lineWidth: 0.5
                                    )
                            )
                    )
                }
                .buttonStyle(LiquidPressButtonStyle())
            }
        }
    }

    private func modeIcon(_ mode: ImportMode) -> String {
        switch mode {
        case .url: return "link"
        case .clipboard: return "doc.on.clipboard"
        case .qrcode: return "qrcode.viewfinder"
        case .telegram: return "paperplane.fill"
        }
    }

    // MARK: - Protocol Selector
    private var protocolSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button {
                    selectedProtocol = nil
                } label: {
                    Text("Авто")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(selectedProtocol == nil ? .white : .v2xTextSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(selectedProtocol == nil ? Color.v2xCyan.opacity(0.3) : Color.white.opacity(0.05))
                        )
                }

                ForEach(VPNProtocolType.allCases) { proto in
                    Button {
                        selectedProtocol = proto
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: proto.icon)
                                .font(.system(size: 10))
                            Text(proto.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(selectedProtocol == proto ? .white : .v2xTextSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(selectedProtocol == proto ? proto.color.opacity(0.3) : Color.white.opacity(0.05))
                        )
                    }
                }
            }
        }
    }

    // MARK: - Import Area
    private var importArea: some View {
        LiquidGlassCard(cornerRadius: 16) {
            VStack(spacing: 10) {
                HStack {
                    Text(importMode == .clipboard ? "Вставьте конфигурацию" : "Введите ссылку конфигурации")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.v2xTextSecondary)

                    Spacer()

                    if importMode == .clipboard {
                        Button {
                            if let clipboard = UIPasteboard.general.string {
                                configText = clipboard
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.clipboard")
                                    .font(.system(size: 12))
                                Text("Вставить")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.v2xCyan)
                        }
                    }
                }

                ZStack(alignment: .topLeading) {
                    if configText.isEmpty {
                        Text(placeholderText)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.v2xTextTertiary)
                            .padding(12)
                    }

                    TextEditor(text: $configText)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.white)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 120)
                        .padding(8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                        )
                )
            }
            .padding(14)
        }
    }

    private var placeholderText: String {
        switch importMode {
        case .url: return "vless://uuid@server:port?...\ntrojan://password@server:port?..."
        case .clipboard: return "Вставьте конфигурацию из буфера обмена..."
        case .qrcode: return "Нажмите для сканирования QR-кода..."
        case .telegram: return "Вставьте ссылку из Telegram канала..."
        }
    }

    // MARK: - Import Button
    private var importButton: some View {
        Button {
            guard !configText.isEmpty else { return }
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                importAnimation = true
            }
            profileManager.importConfig(from: configText)
        } label: {
            HStack(spacing: 8) {
                if profileManager.isImporting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 18))
                }

                Text(profileManager.isImporting ? "Импортирование..." : "Импортировать конфигурацию")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: themeManager.currentTheme.gradientColors.prefix(2).map { $0 },
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .shadow(color: themeManager.currentTheme.accentColor.opacity(0.3), radius: 10, y: 5)
        }
        .buttonStyle(LiquidPressButtonStyle())
        .disabled(configText.isEmpty || profileManager.isImporting)
        .opacity(configText.isEmpty ? 0.5 : 1)
    }

    // MARK: - Success Card
    private var successCard: some View {
        LiquidGlassCard(cornerRadius: 20, glowColor: .v2xGreen, glowRadius: 10) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.v2xGreen)
                    .symbolEffect(.bounce)

                Text("Конфигурация импортирована успешно")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                if let result = profileManager.importResult {
                    Text("\(result.profileCount) профилей добавлено")
                        .font(.system(size: 13))
                        .foregroundColor(.v2xTextTertiary)

                    ForEach(result.profiles.prefix(3)) { profile in
                        HStack(spacing: 8) {
                            Image(systemName: profile.protocolType.icon)
                                .font(.system(size: 12))
                                .foregroundColor(profile.protocolType.color)
                            Text(profile.name)
                                .font(.system(size: 12))
                                .foregroundColor(.v2xTextSecondary)
                            Spacer()
                            Text(profile.protocolType.rawValue)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(profile.protocolType.color)
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - Supported Protocols
    private var supportedProtocolsCard: some View {
        LiquidGlassCard(cornerRadius: 16) {
            VStack(spacing: 10) {
                HStack {
                    Text("Поддерживаемые протоколы")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }

                ForEach(VPNProtocolType.allCases) { proto in
                    HStack(spacing: 10) {
                        Image(systemName: proto.icon)
                            .font(.system(size: 14))
                            .foregroundColor(proto.color)
                            .frame(width: 24)

                        Text(proto.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)

                        Spacer()

                        Text(proto.urlScheme)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.v2xTextTertiary)
                    }
                }
            }
            .padding(14)
        }
    }
}
