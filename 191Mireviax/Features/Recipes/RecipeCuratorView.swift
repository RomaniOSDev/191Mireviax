import SwiftUI

struct RecipeCuratorView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = RecipeCuratorViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                if viewModel.hasRecipes {
                    VStack(spacing: 0) {
                        AppSearchField(placeholder: "Search recipes…", text: $viewModel.searchText)
                        if viewModel.hasVisibleRecipes {
                            recipeScroll
                        } else {
                            EmptyStateView(
                                symbolName: "magnifyingglass",
                                title: "No recipes match your filters",
                                subtitle: "Try adjusting search or filters"
                            )
                            .padding(.top, 24)
                        }
                    }
                } else {
                    ScrollView {
                        EmptyStateView(
                            symbolName: "fork.knife",
                            title: "Browse our selection of mouth-watering recipes!",
                            subtitle: "Tap Discover to load curated recipes"
                        )
                        .overlay {
                            ChefHatIllustration()
                                .offset(y: -50)
                        }
                        .padding(.top, 40)

                        if viewModel.canDiscoverMore {
                            Button("Discover More Recipes") {
                                viewModel.discoverMore()
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        NavigationLink {
                            WeekPlanView()
                        } label: {
                            Image(systemName: "calendar")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(Color("AppTextSecondary"))
                                .frame(width: 40, height: 40)
                                .background(Color("AppSurface").opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        ToolbarIconButton(
                            iconName: viewModel.filterOptions.isActive
                                ? "line.3.horizontal.decrease.circle.fill"
                                : "line.3.horizontal.decrease.circle",
                            isActive: viewModel.filterOptions.isActive
                        ) {
                            viewModel.showFilterSheet = true
                        }
                        ToolbarIconButton(iconName: "plus") {
                            viewModel.showAddRecipe = true
                        }
                    }
                }
            }
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .sheet(isPresented: $viewModel.showFilterSheet) {
                RecipeFilterSheet(options: $viewModel.filterOptions, categories: viewModel.categories)
            }
            .sheet(isPresented: $viewModel.showAddRecipe) {
                AddEditRecipeView(existingRecipe: nil)
            }
            .onAppear { viewModel.configure(store: store) }
        }
    }

    private var recipeScroll: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.recipes) { recipe in
                    RecipeListCell(
                        recipe: recipe,
                        isFavorite: viewModel.isFavorite(recipeID: recipe.id),
                        isPulsing: viewModel.favoritePulseID == recipe.id,
                        onFavoriteTap: {
                            viewModel.toggleFavorite(recipeID: recipe.id)
                        }
                    )
                }

                if viewModel.canDiscoverMore {
                    Button("Discover More Recipes") {
                        viewModel.discoverMore()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .padding(.bottom, 16)
        }
    }
}
