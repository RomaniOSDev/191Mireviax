import SwiftUI

struct AddTimerChainView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    @State private var title = ""
    @State private var stages: [TimerChainStage] = [
        TimerChainStage(name: "Step 1", durationSeconds: 600)
    ]
    @State private var shakeTrigger = 0
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Chain title", text: $title)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: shakeTrigger)
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    Section("Stages") {
                        ForEach($stages) { $stage in
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Stage name", text: $stage.name)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                Stepper(
                                    "Duration: \(stage.durationSeconds / 60) min",
                                    value: Binding(
                                        get: { stage.durationSeconds / 60 },
                                        set: { stage.durationSeconds = max(1, $0) * 60 }
                                    ),
                                    in: 1...180
                                )
                                .foregroundStyle(Color("AppTextPrimary"))
                            }
                        }
                        Button("Add Stage") {
                            stages.append(TimerChainStage(name: "Step \(stages.count + 1)", durationSeconds: 300))
                            FeedbackService.lightTap()
                        }
                        .foregroundStyle(Color("AppPrimary"))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Timer Chain")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") { startChain() }
                        .foregroundStyle(Color("AppPrimary"))
                }
            }
        }
    }

    private func startChain() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Enter a chain title."
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        store.startTimerChain(title: trimmed, stages: stages)
        dismiss()
    }
}
