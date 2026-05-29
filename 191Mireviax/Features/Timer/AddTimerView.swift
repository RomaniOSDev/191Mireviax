import SwiftUI

struct AddTimerView: View {
    @Environment(\.dismiss) private var dismiss
    let existingTimer: CookingTimerItem?
    let defaultDuration: Int
    let onSave: (String, Int) -> Void

    @State private var dishName = ""
    @State private var selectedDate = Date()
    @State private var shakeTrigger = 0
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Dish name", text: $dishName)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: shakeTrigger)
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    Section("Duration") {
                        DatePicker(
                            "Time",
                            selection: $selectedDate,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existingTimer == nil ? "New Timer" : "Edit Timer")
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
                    Button("Save") {
                        save()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear {
                if let existing = existingTimer {
                    dishName = existing.dishName
                    selectedDate = dateFromSeconds(existing.remainingSeconds)
                } else {
                    selectedDate = dateFromSeconds(defaultDuration)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func dateFromSeconds(_ seconds: Int) -> Date {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        var components = DateComponents()
        components.hour = hours
        components.minute = minutes
        return Calendar.current.date(from: components) ?? Date()
    }

    private func secondsFromDate(_ date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        let total = hours * 3600 + minutes * 60
        return max(60, total)
    }

    private func save() {
        let trimmed = dishName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a dish name."
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        let duration = secondsFromDate(selectedDate)
        onSave(trimmed, duration)
        FeedbackService.success()
        dismiss()
    }
}
