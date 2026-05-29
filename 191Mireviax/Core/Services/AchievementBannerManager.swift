import Combine
import Foundation
import SwiftUI

@MainActor
final class AchievementBannerManager: ObservableObject {
    struct BannerItem: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let message: String
    }

    @Published private(set) var currentBanner: BannerItem?
    private var queue: [BannerItem] = []
    private var isShowing = false

    func enqueue(title: String, message: String) {
        queue.append(BannerItem(title: title, message: message))
        showNextIfNeeded()
    }

    private func showNextIfNeeded() {
        guard !isShowing, currentBanner == nil, let next = queue.first else { return }
        queue.removeFirst()
        isShowing = true
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            currentBanner = next
        }
        FeedbackService.success()
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.easeInOut(duration: 0.3)) {
                currentBanner = nil
            }
            try? await Task.sleep(nanoseconds: 350_000_000)
            isShowing = false
            showNextIfNeeded()
        }
    }
}
