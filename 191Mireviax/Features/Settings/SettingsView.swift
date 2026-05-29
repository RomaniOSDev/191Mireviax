import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 8) {
                        statsHero

                        SectionHeaderView(title: "Preferences", iconName: "slider.horizontal.3")
                        unitsCell
                        SettingsToggleCell(
                            title: "Home Screen Badge (items left)",
                            iconName: "app.badge",
                            isOn: Binding(
                                get: { store.homeScreenBadgeEnabled },
                                set: { store.homeScreenBadgeEnabled = $0 }
                            )
                        )

                        SectionHeaderView(title: "Legal", iconName: "doc.text.fill")
                        legalSection

                        SectionHeaderView(title: "Data", iconName: "externaldrive.fill")
                        ExportDataButton()
                        ImportDataButton()

                        Button {
                            showResetAlert = true
                        } label: {
                            SettingsListCell(
                                title: "Reset All Data",
                                iconName: "trash.fill",
                                destructive: true,
                                showChevron: false
                            )
                        }
                        .buttonStyle(.plain)

                        Text("Version \(appVersion)")
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 16)
                            .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { FeedbackService.lightTap() }
                Button("Reset", role: .destructive) {
                    store.resetAllData()
                    FeedbackService.warning()
                }
            } message: {
                Text("This will permanently delete all your recipes, lists, timers, and progress.")
            }
        }
    }

    private var legalSection: some View {
        VStack(spacing: 0) {
            Button {
                FeedbackService.lightTap()
                rateApp()
            } label: {
                SettingsListCell(title: "Rate Us", iconName: "star.fill", showChevron: false)
            }
            .buttonStyle(.plain)

            Button {
                FeedbackService.lightTap()
                openPolicy()
            } label: {
                SettingsListCell(title: "Privacy", iconName: "hand.raised.fill", showChevron: false)
            }
            .buttonStyle(.plain)

            Button {
                FeedbackService.lightTap()
                openTerms()
            } label: {
                SettingsListCell(title: "Terms", iconName: "doc.plaintext.fill", showChevron: false)
            }
            .buttonStyle(.plain)
        }
    }

    private func openPolicy() {
        if let url = AppLinks.privacyPolicy.url {
            UIApplication.shared.open(url)
        }
    }

    private func openTerms() {
        if let url = AppLinks.termsOfUse.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private var statsHero: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Statistics")
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
                IconBadge(iconName: "chart.bar.fill", size: 40)
            }
            HStack(spacing: 10) {
                StatPill(
                    iconName: "tray.full.fill",
                    value: "\(store.loadedRecipeIDs.count + store.groceryItems.count)",
                    label: "Entries"
                )
                StatPill(iconName: "clock.fill", value: "\(store.totalMinutesUsed)", label: "Minutes")
                StatPill(iconName: "flame.fill", value: "\(store.streakDays)d", label: "Streak")
            }
        }
        .padding(16)
        .elevatedCard(accentLeading: true)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var unitsCell: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                IconBadge(iconName: "ruler", size: 40)
                Text("Units")
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color("AppTextPrimary"))
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            HStack(spacing: 10) {
                ForEach(MeasurementSystem.allCases) { system in
                    SelectableChip(
                        title: system.title,
                        isSelected: store.measurementSystem == system.rawValue
                    ) {
                        store.measurementSystem = system.rawValue
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
        .elevatedCard()
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

struct SettingsRow: View {
    let title: String
    let iconName: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundStyle(Color("AppPrimary"))
                .frame(width: 28)
            Text(title)
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
        }
    }
}
