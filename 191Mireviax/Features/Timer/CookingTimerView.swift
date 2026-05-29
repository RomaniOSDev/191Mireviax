import SwiftUI

struct CookingTimerView: View {
    @EnvironmentObject private var store: AppDataStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = CookingTimerViewModel()
    @State private var showChainSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 0) {
                    timerPresetsBar
                    if store.timers.isEmpty {
                        ScrollView {
                            EmptyStateView(
                                symbolName: "timer",
                                title: "No Active Timers - Tap to Add Your First Timer",
                                subtitle: "Use presets above or add a custom timer"
                            )
                            .overlay {
                                ClockIllustration()
                                    .offset(y: -50)
                            }
                            .padding(.top, 32)
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(store.timers) { timer in
                                    TimelineView(.periodic(from: .now, by: 1.0)) { context in
                                        let remaining = remainingSeconds(for: timer, at: context.date)
                                        TimerListCell(
                                            dishName: timer.dishName,
                                            remainingSeconds: remaining,
                                            totalSeconds: timer.durationSeconds,
                                            isPaused: timer.isPaused,
                                            isNew: viewModel.newlyAddedID == timer.id,
                                            onTogglePause: {
                                                viewModel.togglePause(id: timer.id)
                                            }
                                        )
                                    }
                                    .contextMenu {
                                        Button("Edit") {
                                            viewModel.editingTimer = timer
                                            viewModel.showAddSheet = true
                                        }
                                        Button("Delete", role: .destructive) {
                                            viewModel.deleteTimer(id: timer.id)
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 100)
                        }
                    }
                }
            }
            .navigationTitle("Timer")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        ToolbarIconButton(iconName: "link") {
                            showChainSheet = true
                        }
                        ToolbarIconButton(iconName: "plus") {
                            viewModel.editingTimer = nil
                            viewModel.showAddSheet = true
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button("Add Timer") {
                    viewModel.editingTimer = nil
                    viewModel.showAddSheet = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [Color.clear, Color("AppBackground").opacity(0.95)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            }
            .sheet(isPresented: $showChainSheet) {
                AddTimerChainView()
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddTimerView(
                    existingTimer: viewModel.editingTimer,
                    defaultDuration: store.lastUsedDurationSec
                ) { dishName, duration in
                    if let existing = viewModel.editingTimer {
                        var updated = existing
                        updated.dishName = dishName
                        updated.durationSeconds = duration
                        updated.remainingSeconds = duration
                        updated.isPaused = false
                        updated.endDate = Date().addingTimeInterval(TimeInterval(duration))
                        viewModel.updateTimer(updated)
                    } else {
                        viewModel.addTimer(dishName: dishName, durationSeconds: duration)
                    }
                }
            }
            .onAppear { viewModel.configure(store: store) }
            .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                store.syncTimersOnForeground()
                viewModel.resumeTicking()
            case .background:
                store.pauseAllTimers()
                viewModel.pauseTicking()
            case .inactive:
                break
            @unknown default:
                break
            }
            }
        }
    }

    private var timerPresetsBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Presets")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.horizontal, 20)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(TimerPresetCatalog.all) { preset in
                        TimerPresetChip(
                            name: preset.name,
                            durationText: CookingTimerViewModel.formattedRemaining(preset.durationSeconds)
                        ) {
                            store.startTimerFromPreset(preset)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 10)
    }

    private func remainingSeconds(for timer: CookingTimerItem, at date: Date) -> Int {
        guard !timer.isPaused, let endDate = timer.endDate else {
            return timer.remainingSeconds
        }
        return max(0, Int(endDate.timeIntervalSince(date)))
    }
}
