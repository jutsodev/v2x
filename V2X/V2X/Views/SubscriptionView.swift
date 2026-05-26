// SubscriptionView.swift
// V2X

import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    @State private var showAddSubscription = false
    @State private var newSubName = ""
    @State private var newSubURL = ""

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Refresh All
                    refreshAllCard

                    // Subscriptions List
                    if subscriptionManager.subscriptions.isEmpty {
                        emptyState
                    } else {
                        subscriptionsList
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
                    Text("Подписка")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showAddSubscription = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.v2xCyan)
                            .frame(width: 36, height: 36)
                            .liquidGlassBackground(cornerRadius: 10)
                    }
                }
            }
            .sheet(isPresented: $showAddSubscription) {
                addSubscriptionSheet
            }
        }
    }

    private var refreshAllCard: some View {
        Button {
            subscriptionManager.refreshAll()
        } label: {
            LiquidGlassCard(cornerRadius: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.v2xCyan)
                        .rotationEffect(subscriptionManager.isRefreshing ? .degrees(360) : .degrees(0))
                        .animation(
                            subscriptionManager.isRefreshing
                                ? .linear(duration: 1).repeatForever(autoreverses: false)
                                : .default,
                            value: subscriptionManager.isRefreshing
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Обновить все подписки")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)

                        if let last = subscriptionManager.lastRefresh {
                            Text("Обновлено: \(last, style: .relative) назад")
                                .font(.system(size: 11))
                                .foregroundColor(.v2xTextTertiary)
                        }
                    }

                    Spacer()

                    Text("\(subscriptionManager.totalProfiles) профилей")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.v2xCyan)
                }
                .padding(14)
            }
        }
        .buttonStyle(LiquidPressButtonStyle())
        .disabled(subscriptionManager.isRefreshing)
    }

    private var subscriptionsList: some View {
        VStack(spacing: 10) {
            ForEach(subscriptionManager.subscriptions) { sub in
                subscriptionCard(sub)
            }
        }
    }

    private func subscriptionCard(_ sub: V2XSubscription) -> some View {
        LiquidGlassCard(cornerRadius: 16) {
            VStack(spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sub.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)

                        Text(sub.url.truncated(to: 40))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.v2xTextTertiary)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(sub.profileCount) серверов")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.v2xCyan)

                        if let updated = sub.lastUpdated {
                            Text(updated, style: .relative)
                                .font(.system(size: 10))
                                .foregroundColor(.v2xTextTertiary)
                        }
                    }
                }

                HStack(spacing: 8) {
                    Button {
                        subscriptionManager.refreshSubscription(sub)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 12))
                            Text("Обновить")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.v2xCyan)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .liquidGlassBackground(cornerRadius: 10)
                    }
                    .buttonStyle(LiquidPressButtonStyle())

                    Button {
                        subscriptionManager.deleteSubscription(sub)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                                .font(.system(size: 12))
                            Text("Удалить")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(.v2xRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .liquidGlassBackground(cornerRadius: 10)
                    }
                    .buttonStyle(LiquidPressButtonStyle())
                }
            }
            .padding(14)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.v2xTextTertiary)
            Text("Нет подписок")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.v2xTextSecondary)
            Text("Добавьте подписку для автоматического обновления серверов")
                .font(.system(size: 13))
                .foregroundColor(.v2xTextTertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    private var addSubscriptionSheet: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Название")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.v2xTextSecondary)
                        TextField("Subscription Name", text: $newSubName)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(12)
                            .liquidGlassBackground(cornerRadius: 12)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("URL подписки")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.v2xTextSecondary)
                        TextField("https://...", text: $newSubURL)
                            .font(.system(size: 15, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(12)
                            .liquidGlassBackground(cornerRadius: 12)
                            .autocapitalization(.none)
                    }

                    LiquidGlassButton("Добавить подписку", icon: "plus.circle.fill", color: .v2xGreen) {
                        subscriptionManager.addSubscription(name: newSubName, url: newSubURL)
                        showAddSubscription = false
                        newSubName = ""
                        newSubURL = ""
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(newSubURL.isEmpty)
                }
                .padding(16)
            }
            .background(Color.v2xBackground.ignoresSafeArea())
            .navigationTitle("Новая подписка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { showAddSubscription = false }
                        .foregroundColor(.v2xCyan)
                }
            }
        }
    }
}
