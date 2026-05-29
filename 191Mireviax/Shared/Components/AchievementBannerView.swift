import SwiftUI

struct AchievementBannerView: View {
    let banner: AchievementBannerManager.BannerItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.circle.fill")
                .font(.title2)
                .foregroundStyle(Color("AppAccent"))
            VStack(alignment: .leading, spacing: 2) {
                Text(banner.title)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(banner.message)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .elevatedCard(accentLeading: true)
        .padding(.horizontal, 16)
    }
}
