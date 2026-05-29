import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedTab: AppTab
    @Binding var kitchenSection: KitchenSection

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    private var pendingGroceries: Int {
        store.groceryItems.filter { !$0.completed }.count
    }

    private var activeTimers: [CookingTimerItem] {
        store.timers.filter { !$0.isPaused }
    }

    private var todayMeal: (meal: MealType, recipe: Recipe)? {
        let weekday = Calendar.current.component(.weekday, from: Date()) - 1
        let dinnerSlot = store.weekPlanSlots.first { $0.dayIndex == weekday && $0.mealType == .dinner }
        if let id = dinnerSlot?.recipeID, let recipe = store.recipe(for: id) {
            return (.dinner, recipe)
        }
        let lunchSlot = store.weekPlanSlots.first { $0.dayIndex == weekday && $0.mealType == .lunch }
        if let id = lunchSlot?.recipeID, let recipe = store.recipe(for: id) {
            return (.lunch, recipe)
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 20) {
                        heroBanner
                        statsRow
                        widgetGrid
                        if !activeTimers.isEmpty {
                            activeTimersSection
                        }
                        discoverButton
                        quickTipsCard
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Hero

    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .clipped()

            LinearGradient(
                colors: [Color.clear, Color("AppBackground").opacity(0.85), Color("AppBackground").opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(greeting)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                Text("Ready to cook something delicious?")
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color("AppAccent").opacity(0.5), Color("AppPrimary").opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .compositingGroup()
        .shadow(color: Color.black.opacity(0.22), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 10) {
            HomeStatWidget(
                iconName: "flame.fill",
                value: "\(store.streakDays)",
                label: "Day streak",
                accent: true
            )
            HomeStatWidget(
                iconName: "cart.fill",
                value: "\(pendingGroceries)",
                label: "To buy"
            )
            HomeStatWidget(
                iconName: "timer",
                value: "\(store.timers.count)",
                label: "Timers"
            )
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Widget grid

    private var widgetGrid: some View {
        VStack(spacing: 12) {
            SectionHeaderView(title: "Quick Access", iconName: "square.grid.2x2.fill")

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                HomeFeatureWidget(
                    title: "Recipes",
                    subtitle: recipeSubtitle,
                    imageName: "WidgetRecipes",
                    action: { selectedTab = .recipes }
                )

                HomeFeatureWidget(
                    title: "Shopping",
                    subtitle: shoppingSubtitle,
                    imageName: "WidgetShopping",
                    action: {
                        kitchenSection = .shopping
                        selectedTab = .kitchen
                    }
                )

                HomeFeatureWidget(
                    title: "Timers",
                    subtitle: timerSubtitle,
                    imageName: "WidgetTimer",
                    action: {
                        kitchenSection = .timer
                        selectedTab = .kitchen
                    }
                )

                HomeFeatureWidget(
                    title: "Your Stats",
                    subtitle: "\(store.unlockedAchievementCount()) of 8 badges",
                    imageName: nil,
                    systemIcon: "trophy.fill",
                    action: { selectedTab = .achievements }
                )
            }
            .padding(.horizontal, 16)

            todayMealWidget
            weekPlanWidget
        }
    }

    private var recipeSubtitle: String {
        let count = store.allAvailableRecipes.count
        if count == 0 { return "Discover new meals" }
        return "\(count) recipes in library"
    }

    private var shoppingSubtitle: String {
        pendingGroceries == 0 ? "List is empty" : "\(pendingGroceries) items waiting"
    }

    private var timerSubtitle: String {
        if store.timers.isEmpty { return "No active timers" }
        return "\(store.timers.count) running now"
    }

    @ViewBuilder
    private var todayMealWidget: some View {
        Button {
            FeedbackService.lightTap()
            selectedTab = .recipes
        } label: {
            HStack(spacing: 14) {
                if let today = todayMeal {
                    RecipePlateIllustration(accentIndex: today.recipe.accentIndex)
                        .frame(width: 56, height: 56)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Today's \(today.meal.rawValue)")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                        Text(today.recipe.name)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        MetaChip(iconName: "clock", text: "\(today.recipe.cookingTimeMinutes) min")
                    }
                } else {
                    IconBadge(iconName: "calendar", size: 48)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Plan today's meal")
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text("Set up your week plan to see dinner here")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .lineLimit(2)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(16)
            .elevatedCard(accentLeading: true)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    private var weekPlanWidget: some View {
        NavigationLink {
            WeekPlanView()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Week Plan")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("\(plannedMealsCount) meals scheduled this week")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                IconBadge(iconName: "calendar.badge.clock", size: 44)
            }
            .padding(16)
            .elevatedCard()
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded { FeedbackService.lightTap() })
        .padding(.horizontal, 16)
    }

    private var plannedMealsCount: Int {
        store.weekPlanSlots.filter { $0.recipeID != nil }.count
    }

    // MARK: - Active timers

    private var activeTimersSection: some View {
        VStack(spacing: 10) {
            SectionHeaderView(
                title: "Active Timers",
                iconName: "timer",
                trailing: "\(activeTimers.count)"
            )
            ForEach(activeTimers.prefix(3)) { timer in
                TimelineView(.periodic(from: .now, by: 1.0)) { context in
                    let remaining = timerRemaining(timer, at: context.date)
                    Button {
                        kitchenSection = .timer
                        selectedTab = .kitchen
                    } label: {
                        HStack {
                            Text(timer.dishName)
                                .font(.subheadline.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(1)
                            Spacer()
                            Text(formattedTime(remaining))
                                .font(.title3.monospacedDigit().bold())
                                .foregroundStyle(remaining <= 60 ? Color("AppAccent") : Color("AppPrimary"))
                        }
                        .padding(14)
                        .listCard(accentLeading: remaining <= 60)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private var discoverButton: some View {
        if store.allAvailableRecipes.isEmpty || store.loadedRecipeIDs.count < RecipeCatalog.all.count {
            Button {
                store.discoverMoreRecipes()
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Discover More Recipes")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 16)
        }
    }

    private var quickTipsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                IconBadge(iconName: "lightbulb.fill", size: 36)
                Text("Kitchen Tip")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            Text("Swipe items in your shopping list to mark them complete. Add recipe ingredients with one tap from any recipe detail screen.")
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .elevatedCard()
        .padding(.horizontal, 16)
    }

    private func timerRemaining(_ timer: CookingTimerItem, at date: Date) -> Int {
        guard !timer.isPaused, let end = timer.endDate else { return timer.remainingSeconds }
        return max(0, Int(end.timeIntervalSince(date)))
    }

    private func formattedTime(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

// MARK: - Home components

private struct HomeStatWidget: View {
    let iconName: String
    let value: String
    let label: String
    var accent: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.body)
                .foregroundStyle(accent ? Color("AppAccent") : Color("AppPrimary"))
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .elevatedCard(accentLeading: accent)
    }
}

private struct HomeFeatureWidget: View {
    let title: String
    let subtitle: String
    var imageName: String?
    var systemIcon: String?
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    if let imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 88)
                            .clipped()
                    } else if let systemIcon {
                        ZStack {
                            AppGradients.primaryGlow
                            Image(systemName: systemIcon)
                                .font(.system(size: 36))
                                .foregroundStyle(Color("AppAccent"))
                        }
                        .frame(height: 88)
                    }

                    LinearGradient(
                        colors: [Color.clear, Color("AppSurface").opacity(0.75), Color("AppSurface")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 88)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color("AppTextPrimary"))
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minHeight: 150)
            .listCard()
        }
        .buttonStyle(.plain)
    }
}
