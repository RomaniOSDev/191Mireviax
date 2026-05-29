import SwiftUI

struct AddEditRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    let existingRecipe: Recipe?

    @State private var name = ""
    @State private var category = ""
    @State private var cookingMinutes = 30
    @State private var ingredientsText = ""
    @State private var stepsText = ""
    @State private var shakeTrigger = 0
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Recipe name", text: $name)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: shakeTrigger)
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        TextField("Category", text: $category)
                            .foregroundStyle(Color("AppTextPrimary"))
                        Stepper("Cooking time: \(cookingMinutes) min", value: $cookingMinutes, in: 5...240, step: 5)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    Section("Ingredients (one per line)") {
                        TextEditor(text: $ingredientsText)
                            .frame(minHeight: 100)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    Section("Steps (one per line)") {
                        TextEditor(text: $stepsText)
                            .frame(minHeight: 120)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existingRecipe == nil ? "New Recipe" : "Edit Recipe")
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
                    Button("Save") { save() }
                        .foregroundStyle(Color("AppPrimary"))
                }
                if let existingRecipe, existingRecipe.isUserCreated {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("Delete", role: .destructive) {
                            store.deleteCustomRecipe(id: existingRecipe.id)
                            dismiss()
                        }
                    }
                }
            }
            .onAppear { loadExisting() }
        }
    }

    private func loadExisting() {
        guard let existingRecipe else { return }
        name = existingRecipe.name
        category = existingRecipe.category
        cookingMinutes = existingRecipe.cookingTimeMinutes
        ingredientsText = existingRecipe.ingredients.joined(separator: "\n")
        stepsText = existingRecipe.steps.joined(separator: "\n")
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter a recipe name."
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        let ingredients = ingredientsText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let steps = stepsText
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard !ingredients.isEmpty, !steps.isEmpty else {
            errorMessage = "Add at least one ingredient and one step."
            shakeTrigger += 1
            FeedbackService.warning()
            return
        }
        let cat = category.trimmingCharacters(in: .whitespaces).isEmpty ? "Custom" : category.trimmingCharacters(in: .whitespaces)
        let recipe: Recipe
        if let existingRecipe, existingRecipe.isUserCreated {
            recipe = Recipe(
                id: existingRecipe.id,
                name: trimmedName,
                cookingTimeMinutes: cookingMinutes,
                category: cat,
                ingredients: ingredients,
                steps: steps,
                accentIndex: existingRecipe.accentIndex,
                isUserCreated: true
            )
        } else {
            recipe = Recipe(
                id: "custom-\(UUID().uuidString)",
                name: trimmedName,
                cookingTimeMinutes: cookingMinutes,
                category: cat,
                ingredients: ingredients,
                steps: steps,
                accentIndex: Int.random(in: 0..<6),
                isUserCreated: true
            )
        }
        store.saveCustomRecipe(recipe)
        dismiss()
    }
}
