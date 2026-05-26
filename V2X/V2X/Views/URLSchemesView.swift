// URLSchemesView.swift
// V2X

import SwiftUI

struct URLSchemesView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    private let schemesByCategory: [(URLSchemeItem.URLSchemeCategory, [URLSchemeItem])] = {
        let allSchemes = URLSchemeItem.allSchemes
        let categories = URLSchemeItem.URLSchemeCategory.allCases
        return categories.compactMap { category in
            let items = allSchemes.filter { $0.category == category }
            return items.isEmpty ? nil : (category, items)
        }
    }()

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header card
                    headerCard

                    // Scheme sections
                    ForEach(schemesByCategory, id: \.0) { category, schemes in
                        schemeCategorySection(title: category.rawValue, schemes: schemes)
                    }

                    // Info card
                    infoCard

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .liquidGlassBackground(cornerRadius: 10)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Схемы URL-адресов")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        LiquidGlassCard(cornerRadius: 20) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "link.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.v2xCyan, .v2xPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("V2X URL Schemes")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)

                        Text("Используйте v2x:// ссылки для управления приложением из Shortcuts, Safari и других приложений")
                            .font(.system(size: 12))
                            .foregroundColor(.v2xTextTertiary)
                            .lineLimit(3)
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Scheme Category Section
    private func schemeCategorySection(title: String, schemes: [URLSchemeItem]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.v2xTextTertiary)
                .textCase(.uppercase)
                .tracking(1)
                .padding(.leading, 4)

            GlassSectionCard {
                ForEach(Array(schemes.enumerated()), id: \.element.id) { index, scheme in
                    schemeRow(scheme)

                    if index < schemes.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 16)
                    }
                }
            }
        }
    }

    // MARK: - Scheme Row
    private func schemeRow(_ scheme: URLSchemeItem) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(scheme.displayScheme)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.v2xCyan)

                Text(scheme.description)
                    .font(.system(size: 11))
                    .foregroundColor(.v2xTextTertiary)
                    .lineLimit(1)
            }

            Spacer()

            CopyButton(text: scheme.scheme)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Info Card
    private var infoCard: some View {
        LiquidGlassCard(cornerRadius: 16) {
            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.v2xBlue)

                    Text("Поддерживаемые протоколы")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()
                }

                Text("V2X поддерживает импорт конфигураций из всех популярных протоколов: VLESS, Trojan, VMess, VLESS+Reality, Hysteria2, TUIC, Shadowsocks, WireGuard и другие.")
                    .font(.system(size: 12))
                    .foregroundColor(.v2xTextTertiary)
                    .lineSpacing(2)

                // Protocol badges
                FlowLayout(spacing: 6) {
                    ForEach(VPNProtocolType.allCases) { proto in
                        protocolBadge(proto)
                    }
                }
            }
            .padding(16)
        }
    }

    private func protocolBadge(_ proto: VPNProtocolType) -> some View {
        HStack(spacing: 4) {
            Image(systemName: proto.icon)
                .font(.system(size: 10))
            Text(proto.rawValue)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(proto.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(proto.color.opacity(0.12))
                .overlay(
                    Capsule()
                        .stroke(proto.color.opacity(0.2), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
