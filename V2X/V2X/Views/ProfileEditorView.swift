// ProfileEditorView.swift
// V2X

import SwiftUI

struct ProfileEditorView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var profileManager: ProfileManager
    @StateObject private var protocolHandler = ProtocolHandler.shared
    @Environment(\.dismiss) private var dismiss

    @State private var profileName = ""
    @State private var serverAddress = ""
    @State private var serverPort = "443"
    @State private var uuid = ""
    @State private var password = ""
    @State private var alterId = "0"
    @State private var selectedProtocol: VPNProtocolType = .vless
    @State private var selectedTransport: ProtocolHandler.TransportType = .tcp
    @State private var selectedSecurity: ProtocolHandler.SecurityType = .tls
    @State private var sni = ""
    @State private var fingerprint = "chrome"
    @State private var wsPath = "/"
    @State private var wsHost = ""
    @State private var grpcServiceName = ""
    @State private var alpn = "h2,http/1.1"
    @State private var realityPublicKey = ""
    @State private var realityShortId = ""
    @State private var realitySpiderX = ""
    @State private var allowInsecure = false
    @State private var enableFragment = false
    @State private var fragmentSize = "100-200"
    @State private var fragmentInterval = "10-20"
    @State private var enableMux = false
    @State private var muxConcurrency = "8"
    @State private var ssMethod = "aes-256-gcm"
    @State private var wgPrivateKey = ""
    @State private var wgPublicKey = ""
    @State private var wgEndpoint = ""
    @State private var wgAddress = "10.0.0.2/32"
    @State private var showAdvanced = false
    @State private var showGeneratedConfig = false
    @State private var generatedConfig = ""

    var editing: VPNProfile?

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Basic Settings
                    settingsSection(title: "Основные") {
                        fieldRow(title: "Название", text: $profileName, placeholder: "My V2X Server")
                        sectionDivider

                        // Protocol selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Протокол")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.v2xTextSecondary)
                                .padding(.horizontal, 16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(VPNProtocolType.allCases) { proto in
                                        Button {
                                            selectedProtocol = proto
                                            updateAvailableOptions()
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: proto.icon)
                                                    .font(.system(size: 10))
                                                Text(proto.rawValue)
                                                    .font(.system(size: 11, weight: .semibold))
                                            }
                                            .foregroundColor(selectedProtocol == proto ? .white : .v2xTextSecondary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                Capsule()
                                                    .fill(selectedProtocol == proto ? proto.color.opacity(0.3) : Color.white.opacity(0.05))
                                                    .overlay(
                                                        Capsule()
                                                            .stroke(selectedProtocol == proto ? proto.color.opacity(0.4) : Color.clear, lineWidth: 0.5)
                                                    )
                                            )
                                        }
                                        .buttonStyle(LiquidPressButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 6)
                    }

                    // Server Settings
                    settingsSection(title: "Сервер") {
                        fieldRow(title: "Адрес", text: $serverAddress, placeholder: "server.v2x.io")
                        sectionDivider
                        fieldRow(title: "Порт", text: $serverPort, placeholder: "443")
                        sectionDivider
                        credentialField
                    }

                    // Transport
                    settingsSection(title: "Транспорт") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Тип транспорта")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.v2xTextSecondary)
                                .padding(.horizontal, 16)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(protocolHandler.getAvailableTransports(for: selectedProtocol)) { transport in
                                        LiquidGlassChip(
                                            title: transport.rawValue,
                                            icon: transport.icon,
                                            isSelected: selectedTransport == transport
                                        ) {
                                            selectedTransport = transport
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 6)

                        if selectedTransport.supportsPath {
                            sectionDivider
                            fieldRow(title: "Path", text: $wsPath, placeholder: "/", monospaced: true)
                        }

                        if selectedTransport.supportsHost {
                            sectionDivider
                            fieldRow(title: "Host", text: $wsHost, placeholder: "cdn.example.com", monospaced: true)
                        }

                        if selectedTransport == .grpc {
                            sectionDivider
                            fieldRow(title: "Service Name", text: $grpcServiceName, placeholder: "grpc-service", monospaced: true)
                        }
                    }

                    // Security
                    settingsSection(title: "Безопасность") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Тип шифрования")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.v2xTextSecondary)
                                .padding(.horizontal, 16)

                            HStack(spacing: 6) {
                                ForEach(protocolHandler.getAvailableSecurity(for: selectedProtocol)) { sec in
                                    LiquidGlassChip(
                                        title: sec.rawValue,
                                        icon: sec.icon,
                                        color: sec.color,
                                        isSelected: selectedSecurity == sec
                                    ) {
                                        selectedSecurity = sec
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .padding(.vertical, 6)

                        if selectedSecurity == .tls || selectedSecurity == .reality {
                            sectionDivider
                            fieldRow(title: "SNI", text: $sni, placeholder: "example.com", monospaced: true)
                            sectionDivider
                            fieldRow(title: "Fingerprint", text: $fingerprint, placeholder: "chrome")
                            sectionDivider
                            fieldRow(title: "ALPN", text: $alpn, placeholder: "h2,http/1.1", monospaced: true)
                        }

                        if selectedSecurity == .reality {
                            sectionDivider
                            fieldRow(title: "Public Key", text: $realityPublicKey, placeholder: "Reality public key", monospaced: true)
                            sectionDivider
                            fieldRow(title: "Short ID", text: $realityShortId, placeholder: "Short ID", monospaced: true)
                            sectionDivider
                            fieldRow(title: "SpiderX", text: $realitySpiderX, placeholder: "/", monospaced: true)
                        }

                        if selectedSecurity != .reality {
                            sectionDivider
                            SettingsToggleRow(
                                icon: "shield.slash",
                                iconColor: .v2xYellow,
                                title: "Allow Insecure",
                                isOn: $allowInsecure
                            )
                        }
                    }

                    // Advanced
                    Button {
                        withAnimation(.v2xSnappy) {
                            showAdvanced.toggle()
                        }
                    } label: {
                        HStack {
                            Text("Расширенные настройки")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.v2xTextTertiary)
                            Spacer()
                            Image(systemName: showAdvanced ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.v2xTextTertiary)
                        }
                        .padding(.leading, 4)
                    }

                    if showAdvanced {
                        advancedSettings
                    }

                    // Generate & Save
                    actionButtons

                    // Generated config
                    if showGeneratedConfig && !generatedConfig.isEmpty {
                        generatedConfigCard
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
                    Text(editing != nil ? "Редактировать" : "Новый профиль")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Credential Field
    @ViewBuilder
    private var credentialField: some View {
        switch selectedProtocol {
        case .vless, .vlessReality:
            fieldRow(title: "UUID", text: $uuid, placeholder: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", monospaced: true)
        case .trojan:
            fieldRow(title: "Пароль", text: $password, placeholder: "trojan password", isSecure: true)
        case .vmess:
            fieldRow(title: "UUID", text: $uuid, placeholder: "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx", monospaced: true)
            sectionDivider
            fieldRow(title: "Alter ID", text: $alterId, placeholder: "0")
        case .hysteria2:
            fieldRow(title: "Пароль", text: $password, placeholder: "hysteria2 password", isSecure: true)
        case .tuic:
            fieldRow(title: "UUID", text: $uuid, placeholder: "UUID", monospaced: true)
            sectionDivider
            fieldRow(title: "Пароль", text: $password, placeholder: "TUIC password", isSecure: true)
        case .shadowsocks:
            fieldRow(title: "Пароль", text: $password, placeholder: "Shadowsocks password", isSecure: true)
            sectionDivider
            VStack(alignment: .leading, spacing: 8) {
                Text("Метод шифрования")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.v2xTextSecondary)
                    .padding(.horizontal, 16)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(ProtocolHandler.shadowsocksMethods, id: \.self) { method in
                            LiquidGlassChip(
                                title: method,
                                isSelected: ssMethod == method
                            ) {
                                ssMethod = method
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 6)

        case .wireguard:
            fieldRow(title: "Private Key", text: $wgPrivateKey, placeholder: "WireGuard private key", monospaced: true)
            sectionDivider
            fieldRow(title: "Public Key", text: $wgPublicKey, placeholder: "Server public key", monospaced: true)
            sectionDivider
            fieldRow(title: "Endpoint", text: $wgEndpoint, placeholder: "endpoint:port", monospaced: true)
            sectionDivider
            fieldRow(title: "Address", text: $wgAddress, placeholder: "10.0.0.2/32", monospaced: true)
        }
    }

    // MARK: - Advanced Settings
    private var advancedSettings: some View {
        settingsSection(title: "Расширенные") {
            SettingsToggleRow(
                icon: "rectangle.split.3x3",
                iconColor: .v2xCyan,
                title: "Фрагментация",
                subtitle: "Разбивать пакеты для обхода DPI",
                isOn: $enableFragment
            )

            if enableFragment {
                sectionDivider
                fieldRow(title: "Размер фрагмента", text: $fragmentSize, placeholder: "100-200", monospaced: true)
                sectionDivider
                fieldRow(title: "Интервал", text: $fragmentInterval, placeholder: "10-20", monospaced: true)
            }

            sectionDivider

            SettingsToggleRow(
                icon: "arrow.triangle.merge",
                iconColor: .v2xPurple,
                title: "Мультиплексирование (Mux)",
                isOn: $enableMux
            )

            if enableMux {
                sectionDivider
                fieldRow(title: "Concurrency", text: $muxConcurrency, placeholder: "8")
            }
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                generateConfig()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 14))
                    Text("Предварительный просмотр")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.v2xCyan)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .liquidGlassBackground(cornerRadius: 14)
            }
            .buttonStyle(LiquidPressButtonStyle())

            Button {
                saveProfile()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                    Text("Сохранить профиль")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [.v2xGreen, .v2xCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
            .buttonStyle(LiquidPressButtonStyle())
        }
    }

    // MARK: - Generated Config
    private var generatedConfigCard: some View {
        LiquidGlassCard(cornerRadius: 16) {
            VStack(spacing: 10) {
                HStack {
                    Text("Сгенерированная конфигурация")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    CopyButton(text: generatedConfig)
                }

                Text(generatedConfig)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.v2xTextSecondary)
                    .lineLimit(nil)
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

    // MARK: - Helpers
    private func fieldRow(title: String, text: Binding<String>, placeholder: String, monospaced: Bool = false, isSecure: Bool = false) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.v2xTextSecondary)
                .frame(width: 90, alignment: .leading)

            if isSecure {
                SecureField(placeholder, text: text)
                    .font(.system(size: 14, design: monospaced ? .monospaced : .default))
                    .foregroundColor(.white)
            } else {
                TextField(placeholder, text: text)
                    .font(.system(size: 14, design: monospaced ? .monospaced : .default))
                    .foregroundColor(.white)
                    .autocapitalization(.none)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
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

    private var sectionDivider: some View {
        Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)
    }

    private func updateAvailableOptions() {
        let transports = protocolHandler.getAvailableTransports(for: selectedProtocol)
        if !transports.contains(selectedTransport) {
            selectedTransport = transports.first ?? .tcp
        }

        let securities = protocolHandler.getAvailableSecurity(for: selectedProtocol)
        if !securities.contains(selectedSecurity) {
            selectedSecurity = securities.first ?? .none
        }

        if selectedProtocol == .vlessReality {
            selectedSecurity = .reality
        }
    }

    private func generateConfig() {
        let port = Int(serverPort) ?? 443

        protocolHandler.transportType = selectedTransport
        protocolHandler.security = selectedSecurity
        protocolHandler.serverName = sni
        protocolHandler.fingerprint = fingerprint
        protocolHandler.path = wsPath
        protocolHandler.host = wsHost
        protocolHandler.alpn = alpn.split(separator: ",").map(String.init)
        protocolHandler.realityPublicKey = realityPublicKey
        protocolHandler.realityShortId = realityShortId
        protocolHandler.realitySpiderX = realitySpiderX
        protocolHandler.allowInsecure = allowInsecure
        protocolHandler.fragment = enableFragment
        protocolHandler.fragmentSize = fragmentSize
        protocolHandler.fragmentInterval = fragmentInterval
        protocolHandler.mux = enableMux
        protocolHandler.muxConcurrency = Int(muxConcurrency) ?? 8

        switch selectedProtocol {
        case .vless, .vlessReality:
            generatedConfig = protocolHandler.buildVLESSConfig(uuid: uuid, address: serverAddress, port: port)
        case .trojan:
            generatedConfig = protocolHandler.buildTrojanConfig(password: password, address: serverAddress, port: port)
        case .vmess:
            generatedConfig = protocolHandler.buildVMessConfig(uuid: uuid, address: serverAddress, port: port, alterId: Int(alterId) ?? 0)
        case .hysteria2:
            generatedConfig = protocolHandler.buildHysteria2Config(password: password, address: serverAddress, port: port)
        case .tuic:
            generatedConfig = protocolHandler.buildTUICConfig(uuid: uuid, password: password, address: serverAddress, port: port)
        case .shadowsocks:
            generatedConfig = protocolHandler.buildShadowsocksConfig(password: password, method: ssMethod, address: serverAddress, port: port)
        case .wireguard:
            generatedConfig = protocolHandler.buildWireGuardConfig(privateKey: wgPrivateKey, publicKey: wgPublicKey, address: wgAddress, port: port, endpoint: wgEndpoint)
        }

        withAnimation(.v2xSnappy) {
            showGeneratedConfig = true
        }
    }

    private func saveProfile() {
        if generatedConfig.isEmpty {
            generateConfig()
        }
        profileManager.importConfig(from: generatedConfig)
        HapticManager.shared.triggerNotification(.success)
        dismiss()
    }
}
