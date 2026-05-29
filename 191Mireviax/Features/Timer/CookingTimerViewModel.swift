import Combine
import SwiftUI

@MainActor
final class CookingTimerViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var editingTimer: CookingTimerItem?
    @Published var newlyAddedID: UUID?
    /// Updates every second to refresh countdown labels.
    @Published private(set) var tickDate = Date()

    private var store: AppDataStore?
    private var timerCancellable: AnyCancellable?
    private var storeCancellable: AnyCancellable?

    func configure(store: AppDataStore) {
        self.store = store
        storeCancellable = store.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        startTicking()
    }

    func addTimer(dishName: String, durationSeconds: Int) {
        let item = CookingTimerItem(dishName: dishName, durationSeconds: durationSeconds)
        store?.addTimer(item)
        newlyAddedID = item.id
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            newlyAddedID = nil
        }
    }

    func updateTimer(_ timer: CookingTimerItem) {
        store?.updateTimer(timer)
    }

    func deleteTimer(id: UUID) {
        store?.deleteTimer(id: id)
    }

    func togglePause(id: UUID) {
        store?.toggleTimerPause(id: id)
    }

    func remainingSeconds(for timer: CookingTimerItem, at date: Date = Date()) -> Int {
        guard !timer.isPaused, let endDate = timer.endDate else {
            return timer.remainingSeconds
        }
        return max(0, Int(endDate.timeIntervalSince(date)))
    }

    static func formattedRemaining(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    private func startTicking() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard let store else { return }
        tickDate = Date()

        var completedIDs: [UUID] = []
        for timer in store.timers where !timer.isPaused {
            let remaining = remainingSeconds(for: timer, at: tickDate)
            if remaining <= 0 {
                completedIDs.append(timer.id)
            }
        }
        for id in completedIDs {
            store.completeTimer(id: id)
        }
    }

    func pauseTicking() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    func resumeTicking() {
        guard timerCancellable == nil else { return }
        startTicking()
    }
}
