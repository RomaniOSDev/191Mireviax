import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 20) {
                        progressHero
                        ActivityCalendarView()
                        SectionHeaderView(
                            title: "Badges",
                            iconName: "trophy.fill",
                            trailing: "\(store.unlockedAchievementCount())/8"
                        )
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(AchievementCatalog.all) { achievement in
                                AchievementGridCell(
                                    achievement: achievement,
                                    isUnlocked: store.isAchievementUnlocked(achievement.id)
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var progressHero: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(.title3.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("Keep cooking to unlock more badges")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color("AppSurface"), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: CGFloat(store.unlockedAchievementCount()) / 8.0)
                        .stroke(
                            AngularGradient(
                                colors: [Color("AppAccent"), Color("AppPrimary"), Color("AppAccent")],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    Text("\(store.unlockedAchievementCount())/8")
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                }
                .frame(width: 56, height: 56)
            }
            HStack(spacing: 10) {
                StatPill(iconName: "book.fill", value: "\(store.recipesViewed)", label: "Recipes")
                StatPill(iconName: "bolt.fill", value: "\(store.listsCompleted)", label: "Sessions")
                StatPill(iconName: "flame.fill", value: "\(store.streakDays)d", label: "Streak")
            }
        }
        .padding(16)
        .elevatedCard(accentLeading: true)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
