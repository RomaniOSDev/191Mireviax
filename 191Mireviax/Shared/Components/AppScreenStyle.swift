import SwiftUI
import UIKit

enum AppNavigationAppearance {
    static func apply() {
        let background = UIColor(named: "AppBackground") ?? .clear
        let surface = UIColor(named: "AppSurface") ?? background

        let nav = UINavigationBarAppearance()
        nav.configureWithTransparentBackground()
        nav.backgroundColor = .clear
        nav.titleTextAttributes = [.foregroundColor: UIColor(named: "AppTextPrimary") ?? .white]
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "AppTextPrimary") ?? .white]

        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().isTranslucent = true

        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear
        UIScrollView.appearance().backgroundColor = .clear

        let picker = UISegmentedControl.appearance()
        picker.selectedSegmentTintColor = UIColor(named: "AppPrimary")
        picker.setTitleTextAttributes([.foregroundColor: UIColor(named: "AppTextPrimary") ?? .white], for: .selected)
        picker.setTitleTextAttributes([.foregroundColor: UIColor(named: "AppTextSecondary") ?? .gray], for: .normal)
        picker.backgroundColor = surface.withAlphaComponent(0.6)

        UIPageControl.appearance().backgroundColor = .clear
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "AppPrimary")
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(named: "AppTextSecondary")?.withAlphaComponent(0.4)
    }
}

enum AppHostingBackgroundClearer {
    static func apply() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        for window in windowScene.windows {
            window.backgroundColor = UIColor(named: "AppBackground")
            if let root = window.rootViewController?.view {
                root.backgroundColor = .clear
                root.isOpaque = false
            }
        }
    }
}
