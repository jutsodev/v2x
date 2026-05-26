// ShareProxyView.swift
// V2X

import SwiftUI

struct ShareProxyView: View {
    @EnvironmentObject var vpnManager: VPNManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var isSharing = false
    @State private var httpPort = "10809"
    @State private var socksPort = "10808"
    @State private var allowLAN = true
    @State private var username = ""
    @State private var password = ""
    @State private var requireAuth = false
    @State private var connectedDevices: [ConnectedDevice] = []
    @State private var showQR = false

    struct ConnectedDevice: Identifiable {
        let id = UUID()
        let name: String
        let ip: String
        let connectedAt: Date
        let bytesTransferred: Double
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Status Card
                    proxyStatusCard

                    // Port Configuration
                    portConfigSection

                    // Security
                    securitySection

                    // Connected Devices
                    if isSharing {
                        connectedDevicesSection
                    }

                    // Share Instructions
                    instructionsSection

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
                    Text("Поделиться прокси")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Proxy Status Card
    private var proxyStatusCard: some View {
        LiquidGlassCard(
            cornerRadius: 24,
            glowColor: isSharing ? .v2xCyan : nil,
            glowRadius: isSharing ? 10 : 0
        ) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(isSharing ? Color.v2xCyan.opacity(0.15) : Color.gray.opacity(0.1))
                        .frame(width: 70, height: 70)

                    Image(systemName: isSharing ? "wifi" : "wifi.slash")
                        .font(.system(size: 30))
                        .foregroundColor(isSharing ? .v2xCyan : .gray)
                }

                Text(isSharing ? "Прокси активен" : "Прокси неактивен")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                if isSharing {
                    VStack(spacing: 4) {
                        HStack(spacing: 4) {
                            Text("HTTP:")
                                .font(.system(size: 12))
                                .foregroundColor(.v2xTextTertiary)
                            Text("\(NetworkMonitor.shared.localIPv4):\(httpPort)")
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(.v2xCyan)
                        }
                        HStack(spacing: 4) {
                            Text("SOCKS5:")
                                .font(.system(size: 12))
                                .foregroundColor(.v2xTextTertiary)
                            Text("\(NetworkMonitor.shared.localIPv4):\(socksPort)")
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(.v2xPurple)
                        }
                    }
                }

                Button {
                    withAnimation(.v2xSnappy) {
                        isSharing.toggle()
                        if isSharing {
                            generateSampleDevices()
                        } else {
                            connectedDevices.removeAll()
                        }
                    }
                    HapticManager.shared.triggerImpact(.medium)
                } label: {
                    Text(isSharing ? "Остановить" : "Запустить прокси")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    isSharing
                                        ? LinearGradient(colors: [.v2xRed, .v2xOrange], startPoint: .leading, endPoint: .trailing)
                                        : LinearGradient(colors: [.v2xCyan, .v2xPurple], startPoint: .leading, endPoint: .trailing)
                                )
                        )
                }
                .buttonStyle(LiquidPressButtonStyle())
            }
            .padding(20)
        }
    }

    // MARK: - Port Config
    private var portConfigSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Конфигурация портов")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            GlassSectionCard {
                HStack {
                    Text("HTTP порт")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.v2xTextSecondary)
                    Spacer()
                    TextField("10809", text: $httpPort)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.v2xCyan)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)

                HStack {
                    Text("SOCKS5 порт")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.v2xTextSecondary)
                    Spacer()
                    TextField("10808", text: $socksPort)
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.v2xPurple)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)

                SettingsToggleRow(
                    icon: "network",
                    iconColor: .v2xGreen,
                    title: "Разрешить LAN",
                    subtitle: "Доступ с других устройств в сети",
                    isOn: $allowLAN
                )
            }
        }
    }

    // MARK: - Security
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Аутентификация")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            GlassSectionCard {
                SettingsToggleRow(
                    icon: "lock.fill",
                    iconColor: .v2xYellow,
                    title: "Требовать авторизацию",
                    isOn: $requireAuth
                )

                if requireAuth {
                    Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)

                    HStack {
                        Text("Логин")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.v2xTextSecondary)
                        Spacer()
                        TextField("username", text: $username)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.trailing)
                            .autocapitalization(.none)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    Divider().background(Color.white.opacity(0.06)).padding(.leading, 16)

                    HStack {
                        Text("Пароль")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.v2xTextSecondary)
                        Spacer()
                        SecureField("password", text: $password)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }
            }
        }
    }

    // MARK: - Connected Devices
    private var connectedDevicesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Подключённые устройства (\(connectedDevices.count))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.v2xTextTertiary)
                    .textCase(.uppercase)
                Spacer()
                GlowingDot(color: .v2xGreen, size: 6)
            }
            .padding(.leading, 4)

            ForEach(connectedDevices) { device in
                LiquidGlassCard(cornerRadius: 14) {
                    HStack(spacing: 12) {
                        Image(systemName: "desktopcomputer")
                            .font(.system(size: 18))
                            .foregroundColor(.v2xCyan)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(device.name)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white)
                            Text(device.ip)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.v2xTextTertiary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String.formatBytes(Int64(device.bytesTransferred)))
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.v2xCyan)
                            Text(device.connectedAt.timeAgoString)
                                .font(.system(size: 10))
                                .foregroundColor(.v2xTextTertiary)
                        }
                    }
                    .padding(12)
                }
            }
        }
    }

    // MARK: - Instructions
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Как подключиться")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .padding(.leading, 4)

            LiquidGlassCard(cornerRadius: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    stepRow(number: 1, text: "Откройте настройки Wi-Fi на втором устройстве")
                    stepRow(number: 2, text: "Установите HTTP прокси: \(NetworkMonitor.shared.localIPv4):\(httpPort)")
                    stepRow(number: 3, text: "Или настройте SOCKS5: \(NetworkMonitor.shared.localIPv4):\(socksPort)")
                    if requireAuth {
                        stepRow(number: 4, text: "Введите логин и пароль при запросе")
                    }
                }
                .padding(16)
            }
        }
    }

    private func stepRow(number: Int, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(number)")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(Color.v2xCyan.opacity(0.3)))

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.v2xTextSecondary)
        }
    }

    private func generateSampleDevices() {
        connectedDevices = [
            ConnectedDevice(name: "MacBook Pro", ip: "192.168.1.45", connectedAt: Date().addingTimeInterval(-300), bytesTransferred: 125_000_000),
            ConnectedDevice(name: "iPad Air", ip: "192.168.1.67", connectedAt: Date().addingTimeInterval(-120), bytesTransferred: 45_000_000),
            ConnectedDevice(name: "TV Samsung", ip: "192.168.1.102", connectedAt: Date().addingTimeInterval(-60), bytesTransferred: 280_000_000),
        ]
    }
}
