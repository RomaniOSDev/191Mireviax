import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var store = AppDataStore.shared
    @StateObject private var bannerManager = AchievementBannerManager()

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if store.hasSeenOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if let banner = bannerManager.currentBanner {
                AchievementBannerView(banner: banner)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .environmentObject(store)
        .environmentObject(bannerManager)
        .preferredColorScheme(.dark)
        .onAppear {
            AppNavigationAppearance.apply()
            applyWindowBackground()
            store.configure(bannerManager: bannerManager)
            store.checkAchievements()
        }
    }

    private func applyWindowBackground() {
        AppHostingBackgroundClearer.apply()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        for window in windowScene.windows {
            window.backgroundColor = UIColor(named: "AppBackground")
            window.rootViewController?.view.backgroundColor = .clear
        }
    }
}

#Preview {
    ContentView()
}
