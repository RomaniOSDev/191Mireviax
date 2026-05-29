import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject private var store: AppDataStore
    let recipe: Recipe
    @State private var isFavorite = false
    @State private var portionMultiplier = 1.0
    @State private var noteText = ""
    @State private var duplicateWarning: String?
    @State private var showDuplicateAlert = false
    @State private var showEditSheet = false

    private var scaledIngredients: [String] {
        recipe.ingredients.map { IngredientScaler.scaled($0, multiplier: portionMultiplier) }
    }

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroHeader
                portionSelector
                actionButtons

                DetailSectionCard(title: "Ingredients", iconName: "leaf.fill") {
                    ForEach(scaledIngredients, id: \.self) { ingredient in
                        IngredientRowCell(text: ingredient)
                    }
                }

                DetailSectionCard(title: "Steps", iconName: "list.number") {
                    ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                        StepRowCell(index: index + 1, text: step)
                    }
                }

                DetailSectionCard(title: "Notes", iconName: "note.text") {
                    TextField("Add your notes…", text: $noteText, axis: .vertical)
                        .lineLimit(3...6)
                        .foregroundStyle(Color("AppTextPrimary"))
                        .padding(12)
                        .background(Color("AppBackground").opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onChange(of: noteText) { newValue in
                            store.setNote(newValue, for: recipe.id)
                        }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            AddEditRecipeView(existingRecipe: recipe)
        }
        .alert("Already on List", isPresented: $showDuplicateAlert) {
            Button("OK", role: .cancel) { FeedbackService.lightTap() }
        } message: {
            Text(duplicateWarning ?? "Some items may already be on your shopping list.")
        }
        .onAppear {
            isFavorite = store.isFavorite(recipeID: recipe.id)
            noteText = store.note(for: recipe.id)
            store.markRecipeViewed(recipe.id)
        }
    }

    private var heroHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            RecipePlateIllustration(accentIndex: recipe.accentIndex)
                .frame(width: 88, height: 88)
            VStack(alignment: .leading, spacing: 10) {
                Text(recipe.name)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack(spacing: 6) {
                    MetaChip(iconName: "clock", text: "\(recipe.cookingTimeMinutes) min", highlighted: true)
                    MetaChip(iconName: "tag", text: recipe.category)
                }
                HStack(spacing: 8) {
                    Button {
                        isFavorite = store.toggleFavorite(recipeID: recipe.id)
                    } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundStyle(isFavorite ? Color("AppAccent") : Color("AppTextSecondary"))
                            .frame(width: 44, height: 44)
                            .background(Color("AppSurface"))
                            .clipShape(Circle())
                    }
                    if recipe.isUserCreated {
                        Button { showEditSheet = true } label: {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color("AppPrimary"))
                                .frame(width: 44, height: 44)
                                .background(Color("AppSurface"))
                                .clipShape(Circle())
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .elevatedCard(accentLeading: true)
    }

    private var portionSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Portions")
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppTextSecondary"))
            HStack(spacing: 10) {
                SelectableChip(title: "×0.5", isSelected: portionMultiplier == 0.5) { setPortion(0.5) }
                SelectableChip(title: "×1", isSelected: portionMultiplier == 1.0) { setPortion(1.0) }
                SelectableChip(title: "×2", isSelected: portionMultiplier == 2.0) { setPortion(2.0) }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button("Add Ingredients to Shopping List") {
                let warnings = store.addRecipeIngredientsToGroceryList(recipe, multiplier: portionMultiplier)
                if warnings.isEmpty {
                    FeedbackService.success()
                } else {
                    duplicateWarning = "\(warnings.joined(separator: ", ")) already on your list."
                    showDuplicateAlert = true
                }
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Start Timers for This Recipe") {
                store.startTimersForRecipe(recipe)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    private func setPortion(_ multiplier: Double) {
        portionMultiplier = multiplier
        FeedbackService.lightTap()
    }
}
