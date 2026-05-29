import SwiftUI

// MARK: - Depth (performance: `.list` has no shadow — use in scrolling LazyVStacks)

enum AppCardDepth {
    /// Gradient + border only — best for list rows.
    case list
    /// Single rasterized shadow — section cards, empty states.
    case card
    /// Stronger shadow — hero banners, tab bar (use sparingly).
    case hero
}

// MARK: - Reusable gradients (asset colors only)

enum AppGradients {
    static var background: LinearGradient {
        LinearGradient(
            colors: [Color("AppBackground"), Color("AppSurface"), Color("AppBackground")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surface: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface"),
                Color("AppSurface").opacity(0.88),
                Color("AppBackground").opacity(0.35)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var surfaceHighlight: LinearGradient {
        LinearGradient(
            colors: [Color.white.opacity(0.1), Color.clear],
            startPoint: .top,
            endPoint: .center
        )
    }

    static var surfaceStroke: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppTextPrimary").opacity(0.14),
                Color("AppTextPrimary").opacity(0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primary: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppPrimary").opacity(0.78)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryGlow: LinearGradient {
        LinearGradient(
            colors: [Color("AppAccent").opacity(0.5), Color("AppPrimary").opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentBadge: LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent").opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var glassBar: LinearGradient {
        LinearGradient(
            colors: [
                Color("AppSurface").opacity(0.95),
                Color("AppSurface").opacity(0.82)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func accentLeading(width: CGFloat = 6, cornerRadius: CGFloat = 18) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [Color("AppPrimary").opacity(0.55), Color("AppAccent").opacity(0.15), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width)
    }
}

// MARK: - Card modifier

struct DepthCardModifier: ViewModifier {
    var depth: AppCardDepth = .card
    var accentLeading: Bool = false
    var cornerRadius: CGFloat = 18

    func body(content: Content) -> some View {
        content
            .background(cardBackground)
            .overlay(cardBorder)
            .modifier(CardShadowModifier(depth: depth, cornerRadius: cornerRadius))
    }

    private var cardBackground: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppGradients.surface)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppGradients.surfaceHighlight)
            if accentLeading {
                AppGradients.accentLeading(cornerRadius: cornerRadius)
            }
        }
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(AppGradients.surfaceStroke, lineWidth: 1)
    }
}

private struct CardShadowModifier: ViewModifier {
    let depth: AppCardDepth
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        switch depth {
        case .list:
            content
        case .card:
            content
                .compositingGroup()
                .shadow(color: Color.black.opacity(0.22), radius: 6, x: 0, y: 3)
        case .hero:
            content
                .compositingGroup()
                .shadow(color: Color.black.opacity(0.28), radius: 12, x: 0, y: 6)
        }
    }
}

extension View {
    func depthCard(_ depth: AppCardDepth = .card, accentLeading: Bool = false, cornerRadius: CGFloat = 18) -> some View {
        modifier(DepthCardModifier(depth: depth, accentLeading: accentLeading, cornerRadius: cornerRadius))
    }

    /// Scrolling lists — gradient depth, no shadow.
    func listCard(accentLeading: Bool = false) -> some View {
        depthCard(.list, accentLeading: accentLeading)
    }

    /// Section / standalone cards — one shadow.
    func elevatedCard(accentLeading: Bool = false) -> some View {
        depthCard(.card, accentLeading: accentLeading)
    }

    /// Hero banners, tab bar — use rarely.
    func heroCard(accentLeading: Bool = false, cornerRadius: CGFloat = 18) -> some View {
        depthCard(.hero, accentLeading: accentLeading, cornerRadius: cornerRadius)
    }
}
