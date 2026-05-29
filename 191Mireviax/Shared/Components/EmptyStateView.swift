import SwiftUI

struct EmptyStateView: View {
    let symbolName: String
    let title: String
    let subtitle: String?
    var illustration: AnyView?

    init(symbolName: String, title: String, subtitle: String? = nil) {
        self.symbolName = symbolName
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color("AppPrimary").opacity(0.35), Color("AppAccent").opacity(0.08)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 56
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(Circle().strokeBorder(Color("AppAccent").opacity(0.25), lineWidth: 1))
                if let illustration {
                    illustration
                        .frame(height: 80)
                } else {
                    Image(systemName: symbolName)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(Color("AppAccent"))
                }
            }
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .elevatedCard()
        .padding(.horizontal, 24)
    }
}
