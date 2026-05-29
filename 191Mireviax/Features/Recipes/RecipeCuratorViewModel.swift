import Combine
import SwiftUI

@MainActor
final class RecipeCuratorViewModel: ObservableObject {
    @Published var favoritePulseID: String?
    @Published var showSuccessCheck = false
    @Published var searchText = ""
    @Published var filterOptions = RecipeFilterOptions()
    @Published var showFilterSheet = false
    @Published var showAddRecipe = false
    @Published var showWeekPlan = false

    private var store: AppDataStore?

    func configure(store: AppDataStore) {
        self.store = store
    }

    var recipes: [Recipe] {
        guard let store else { return [] }
        var options = filterOptions
        options.searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return store.filteredRecipes(options: options)
    }

    var categories: [String] {
        store?.recipeCategories ?? []
    }

    var hasRecipes: Bool {
        !(store?.allAvailableRecipes.isEmpty ?? true)
    }

    var hasVisibleRecipes: Bool {
        !recipes.isEmpty
    }

    var canDiscoverMore: Bool {
        guard let store else { return true }
        let allIDs = Set(RecipeCatalog.all.map(\.id))
        let loaded = Set(store.loadedRecipeIDs)
        return loaded != allIDs
    }

    func discoverMore() {
        store?.discoverMoreRecipes()
    }

    func toggleFavorite(recipeID: String) {
        guard let store else { return }
        let added = store.toggleFavorite(recipeID: recipeID)
        if added {
            favoritePulseID = recipeID
            Task {
                try? await Task.sleep(nanoseconds: 400_000_000)
                favoritePulseID = nil
            }
        }
    }

    func isFavorite(recipeID: String) -> Bool {
        store?.isFavorite(recipeID: recipeID) ?? false
    }
}
