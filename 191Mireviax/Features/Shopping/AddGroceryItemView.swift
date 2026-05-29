import SwiftUI

struct AddGroceryItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var quantity = "1"
    @State private var category: GroceryCategory = .produce
    @State private var shakeTrigger = 0
    @State private var errorMessage: String?

    let onSave: (String, String, GroceryCategory) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Item name", text: $name)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: shakeTrigger)
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        TextField("Quantity", text: $quantity)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Picker("Category", selection: $category) {
                            ForEach(GroceryCategory.allCases) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Item")
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
        }
        .presentationDetents([.medium])
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter an item name."
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        let qty = quantity.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(trimmed, qty.isEmpty ? "1" : qty, category)
        dismiss()
    }
}
