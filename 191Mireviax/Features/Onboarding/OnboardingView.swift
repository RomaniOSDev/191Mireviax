import SwiftUI

private struct OnboardingPage {
    let headline: String
    let description: String
    let iconName: String
    let features: [(icon: String, text: String)]
    let illustration: AnyView
}

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            headline: "Discover Recipes",
            description: "Explore diverse recipes suited to your taste.",
            iconName: "book.fill",
            features: [
                ("magnifyingglass", "Search & filter"),
                ("heart.fill", "Save favorites"),
                ("calendar", "Plan your week")
            ],
            illustration: AnyView(OnboardingRecipeIllustration())
        ),
        OnboardingPage(
            headline: "Manage Ingredients",
            description: "Keep track of pantry items and manage shopping efficiently.",
            iconName: "cart.fill",
            features: [
                ("list.bullet", "Smart grocery lists"),
                ("arrow.up.arrow.down", "Sort by category"),
                ("square.and.arrow.up", "Share with one tap")
            ],
            illustration: AnyView(OnboardingPantryIllustration())
        ),
        OnboardingPage(
            headline: "Start Cooking",
            description: "Select a recipe and begin your culinary journey.",
            iconName: "flame.fill",
            features: [
                ("timer", "Kitchen timers"),
                ("flame.fill", "Activity streak"),
                ("trophy.fill", "Earn badges")
            ],
            illustration: AnyView(OnboardingCookingIllustration())
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 0) {
                onboardingTopBar
                welcomeHero

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        OnboardingPageView(page: page, pageIndex: index + 1, pageCount: pages.count)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .background(Color.clear)

                onboardingFooter
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var onboardingTopBar: some View {
        HStack {
            HStack(spacing: 8) {
                IconBadge(iconName: "fork.knife", size: 32)
                Text("Welcome")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            Spacer()
            Text("\(currentPage + 1) / \(pages.count)")
                .font(.caption.bold())
                .foregroundStyle(Color("AppAccent"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(AppGradients.primaryGlow)
                        .overlay(Capsule().strokeBorder(Color("AppAccent").opacity(0.3), lineWidth: 1))
                )
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var welcomeHero: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Your kitchen companion")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
                Text("Cook smarter every day")
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            Spacer(minLength: 0)
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(Color("AppAccent"))
                .frame(width: 48, height: 48)
                .background(AppGradients.accentBadge)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .padding(14)
        .listCard(accentLeading: true)
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private var onboardingFooter: some View {
        VStack(spacing: 18) {
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            index == currentPage
                                ? AnyShapeStyle(AppGradients.primary)
                                : AnyShapeStyle(Color("AppTextSecondary").opacity(0.22))
                        )
                        .frame(width: index == currentPage ? 32 : 8, height: 8)
                        .overlay {
                            if index == currentPage {
                                Capsule()
                                    .strokeBorder(Color("AppAccent").opacity(0.45), lineWidth: 1)
                            }
                        }
                        .animation(.easeInOut(duration: 0.28), value: currentPage)
                }
            }

            Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                FeedbackService.lightTap()
                if currentPage < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.28)) {
                        currentPage += 1
                    }
                } else {
                    store.completeOnboarding()
                }
            }
            .buttonStyle(PrimaryButtonStyle())

            if currentPage > 0 {
                Button("Back") {
                    FeedbackService.lightTap()
                    withAnimation(.easeInOut(duration: 0.28)) {
                        currentPage -= 1
                    }
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 36)
    }
}

// MARK: - Page

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    let pageCount: Int
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                illustrationCard

                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        IconBadge(iconName: page.iconName, size: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Step \(pageIndex) of \(pageCount)")
                                .font(.caption.bold())
                                .foregroundStyle(Color("AppAccent"))
                            Text(page.headline)
                                .font(.title3.bold())
                                .foregroundStyle(Color("AppTextPrimary"))
                                .lineLimit(2)
                                .minimumScaleFactor(0.85)
                        }
                        Spacer(minLength: 0)
                    }

                    Text(page.description)
                        .font(.body)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 8) {
                        ForEach(page.features, id: \.text) { feature in
                            HStack(spacing: 12) {
                                Image(systemName: feature.icon)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color("AppAccent"))
                                    .frame(width: 32, height: 32)
                                    .background(AppGradients.primaryGlow)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                Text(feature.text)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .listCard()
                        }
                    }
                }
                .padding(18)
                .elevatedCard(accentLeading: true)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .scrollIndicators(.hidden)
        .onAppear {
            withAnimation(.spring(response: 0.42, dampingFraction: 0.74)) {
                appeared = true
            }
        }
        .onDisappear {
            appeared = false
        }
    }

    private var illustrationCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppGradients.primaryGlow)
                .frame(height: 160)

            page.illustration
                .frame(height: 130)
                .scaleEffect(appeared ? 1 : 0.8)
                .opacity(appeared ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .listCard()
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color("AppAccent").opacity(0.4), Color("AppPrimary").opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Illustrations

private struct OnboardingRecipeIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppGradients.surface)
                .frame(width: 150, height: 100)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(AppGradients.surfaceStroke, lineWidth: 1)
                )

            VStack(spacing: 8) {
                Circle()
                    .fill(AppGradients.accentBadge)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "book.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                    )
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(AppGradients.primaryGlow)
                    .frame(width: 88, height: 8)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color("AppAccent").opacity(0.3))
                    .frame(width: 68, height: 8)
            }
        }
    }
}

private struct OnboardingPantryIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppGradients.surface)
                .frame(width: 130, height: 98)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color("AppPrimary").opacity(0.65), Color("AppAccent").opacity(0.25)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )

            VStack(spacing: 14) {
                ForEach(0..<3, id: \.self) { _ in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(AppGradients.accentBadge)
                            .frame(width: 12, height: 12)
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(Color("AppBackground").opacity(0.45))
                            .frame(width: 70, height: 6)
                        Spacer(minLength: 0)
                    }
                    .frame(width: 96)
                }
            }
        }
    }
}

private struct OnboardingCookingIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppGradients.primaryGlow)
                .frame(width: 96, height: 96)
                .offset(y: 10)

            Path { path in
                path.addArc(
                    center: CGPoint(x: 70, y: 78),
                    radius: 48,
                    startAngle: .degrees(205),
                    endAngle: .degrees(-25),
                    clockwise: false
                )
            }
            .stroke(
                LinearGradient(
                    colors: [Color("AppPrimary"), Color("AppAccent")],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 5, lineCap: .round)
            )
            .frame(width: 136, height: 88)

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color("AppAccent").opacity(0.55), Color("AppPrimary").opacity(0.15)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 34
                    )
                )
                .frame(width: 62, height: 20)
                .offset(y: -16)

            Path { path in
                path.move(to: CGPoint(x: 98, y: 26))
                path.addQuadCurve(to: CGPoint(x: 118, y: 6), control: CGPoint(x: 128, y: 36))
            }
            .stroke(Color("AppTextSecondary").opacity(0.5), style: StrokeStyle(lineWidth: 2, lineCap: .round))
        }
        .frame(width: 140, height: 108)
    }
}
