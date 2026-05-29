import Foundation

struct Recipe: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let cookingTimeMinutes: Int
    let category: String
    let ingredients: [String]
    let steps: [String]
    let accentIndex: Int
    var isUserCreated: Bool

    init(
        id: String,
        name: String,
        cookingTimeMinutes: Int,
        category: String,
        ingredients: [String],
        steps: [String],
        accentIndex: Int,
        isUserCreated: Bool = false
    ) {
        self.id = id
        self.name = name
        self.cookingTimeMinutes = cookingTimeMinutes
        self.category = category
        self.ingredients = ingredients
        self.steps = steps
        self.accentIndex = accentIndex
        self.isUserCreated = isUserCreated
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        cookingTimeMinutes = try container.decode(Int.self, forKey: .cookingTimeMinutes)
        category = try container.decode(String.self, forKey: .category)
        ingredients = try container.decode([String].self, forKey: .ingredients)
        steps = try container.decode([String].self, forKey: .steps)
        accentIndex = try container.decode(Int.self, forKey: .accentIndex)
        isUserCreated = try container.decodeIfPresent(Bool.self, forKey: .isUserCreated) ?? false
    }
}

struct GroceryItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var quantity: String
    var category: GroceryCategory
    var completed: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        quantity: String,
        category: GroceryCategory,
        completed: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.category = category
        self.completed = completed
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(String.self, forKey: .quantity)
        category = try container.decode(GroceryCategory.self, forKey: .category)
        completed = try container.decode(Bool.self, forKey: .completed)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}

enum GroceryCategory: String, Codable, CaseIterable, Identifiable {
    case produce = "Produce"
    case dairy = "Dairy"
    case bakery = "Bakery"
    case meat = "Meat"
    case pantry = "Pantry"
    case other = "Other"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .produce: return "leaf.fill"
        case .dairy: return "drop.fill"
        case .bakery: return "birthday.cake.fill"
        case .meat: return "fork.knife"
        case .pantry: return "cabinet.fill"
        case .other: return "bag.fill"
        }
    }
}

struct CookingTimerItem: Identifiable, Codable, Hashable {
    let id: UUID
    var dishName: String
    var durationSeconds: Int
    var remainingSeconds: Int
    var isPaused: Bool
    var endDate: Date?
    var chainID: UUID?
    var chainStageIndex: Int?

    init(
        id: UUID = UUID(),
        dishName: String,
        durationSeconds: Int,
        remainingSeconds: Int? = nil,
        isPaused: Bool = false,
        endDate: Date? = nil,
        chainID: UUID? = nil,
        chainStageIndex: Int? = nil
    ) {
        self.id = id
        self.dishName = dishName
        self.durationSeconds = durationSeconds
        self.remainingSeconds = remainingSeconds ?? durationSeconds
        self.isPaused = isPaused
        self.endDate = endDate
        self.chainID = chainID
        self.chainStageIndex = chainStageIndex
    }
}

enum MealType: String, Codable, CaseIterable, Identifiable {
    case lunch = "Lunch"
    case dinner = "Dinner"

    var id: String { rawValue }
}

struct WeekPlanSlot: Identifiable, Codable, Hashable {
    let id: UUID
    var dayIndex: Int
    var mealType: MealType
    var recipeID: String?

    init(id: UUID = UUID(), dayIndex: Int, mealType: MealType, recipeID: String? = nil) {
        self.id = id
        self.dayIndex = dayIndex
        self.mealType = mealType
        self.recipeID = recipeID
    }
}

struct TimerChainStage: Codable, Hashable, Identifiable {
    let id: UUID
    var name: String
    var durationSeconds: Int

    init(id: UUID = UUID(), name: String, durationSeconds: Int) {
        self.id = id
        self.name = name
        self.durationSeconds = durationSeconds
    }
}

struct TimerChainItem: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var stages: [TimerChainStage]
    var currentStageIndex: Int
    var isActive: Bool
    var activeTimerID: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        stages: [TimerChainStage],
        currentStageIndex: Int = 0,
        isActive: Bool = false,
        activeTimerID: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.stages = stages
        self.currentStageIndex = currentStageIndex
        self.isActive = isActive
        self.activeTimerID = activeTimerID
    }
}

struct TimerPreset: Identifiable, Hashable {
    let id: String
    let name: String
    let durationSeconds: Int
}

enum TimerPresetCatalog {
    static let all: [TimerPreset] = [
        TimerPreset(id: "pasta", name: "Pasta", durationSeconds: 600),
        TimerPreset(id: "eggs", name: "Eggs", durationSeconds: 420),
        TimerPreset(id: "rest", name: "Rest", durationSeconds: 300),
        TimerPreset(id: "rice", name: "Rice", durationSeconds: 1080),
        TimerPreset(id: "steak", name: "Steak Rest", durationSeconds: 480)
    ]
}

enum GrocerySortOrder: String, CaseIterable, Identifiable {
    case category = "category"
    case alphabetical = "alphabetical"
    case dateAdded = "dateAdded"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .category: return "Category"
        case .alphabetical: return "A–Z"
        case .dateAdded: return "Date Added"
        }
    }
}

enum MeasurementSystem: String, CaseIterable, Identifiable, Codable {
    case metric = "metric"
    case imperial = "imperial"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .metric: return "Metric"
        case .imperial: return "Imperial"
        }
    }
}

struct GroceryTemplateItem: Codable, Hashable {
    let name: String
    let quantity: String
    let category: GroceryCategory
}

struct GroceryListTemplate: Identifiable {
    let id: String
    let name: String
    let items: [GroceryTemplateItem]
}

enum GroceryTemplateCatalog {
    static let all: [GroceryListTemplate] = [
        GroceryListTemplate(
            id: "weekly",
            name: "Weekly Basics",
            items: [
                GroceryTemplateItem(name: "Milk", quantity: "1 L", category: .dairy),
                GroceryTemplateItem(name: "Eggs", quantity: "12", category: .dairy),
                GroceryTemplateItem(name: "Bread", quantity: "1 loaf", category: .bakery),
                GroceryTemplateItem(name: "Bananas", quantity: "6", category: .produce),
                GroceryTemplateItem(name: "Chicken breast", quantity: "500 g", category: .meat),
                GroceryTemplateItem(name: "Rice", quantity: "1 kg", category: .pantry)
            ]
        ),
        GroceryListTemplate(
            id: "bbq",
            name: "BBQ",
            items: [
                GroceryTemplateItem(name: "Beef burgers", quantity: "4", category: .meat),
                GroceryTemplateItem(name: "Hot dog buns", quantity: "8", category: .bakery),
                GroceryTemplateItem(name: "Lettuce", quantity: "1 head", category: .produce),
                GroceryTemplateItem(name: "Tomatoes", quantity: "4", category: .produce),
                GroceryTemplateItem(name: "BBQ sauce", quantity: "1 bottle", category: .pantry),
                GroceryTemplateItem(name: "Corn", quantity: "4 ears", category: .produce)
            ]
        )
    ]
}

struct RecipeFilterOptions: Equatable {
    var searchText: String = ""
    var category: String?
    var maxCookingMinutes: Int?

    static let allCategories = "All"

    var isActive: Bool {
        !searchText.isEmpty || category != nil || maxCookingMinutes != nil
    }
}

struct AppExportBundle: Codable {
    var customRecipes: [Recipe]
    var recipeNotes: [String: String]
    var weekPlanSlots: [WeekPlanSlot]
    var groceryItems: [GroceryItem]
    var favoriteRecipes: [String]
    var loadedRecipeIDs: [String]
}

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let condition: (AppDataStore) -> Bool
}

enum AchievementCatalog {
    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_discovery",
            title: "First Discovery",
            description: "You explored your first recipe.",
            iconName: "sparkles",
            condition: { $0.recipesViewed >= 1 }
        ),
        AchievementDefinition(
            id: "recipe_explorer",
            title: "Recipe Explorer",
            description: "You have viewed 10 recipes.",
            iconName: "book.fill",
            condition: { $0.recipesViewed >= 10 }
        ),
        AchievementDefinition(
            id: "favorites_fanatic",
            title: "Favorites Fanatic",
            description: "You added 5 recipes to favorites.",
            iconName: "heart.fill",
            condition: { $0.favouritesAdded >= 5 }
        ),
        AchievementDefinition(
            id: "power_user",
            title: "Power User",
            description: "Reached 50 items.",
            iconName: "star.fill",
            condition: { $0.recipesViewed >= 50 }
        ),
        AchievementDefinition(
            id: "active_user",
            title: "Active User",
            description: "Completed 10 sessions.",
            iconName: "bolt.fill",
            condition: { $0.listsCompleted >= 10 }
        ),
        AchievementDefinition(
            id: "dedicated_user",
            title: "Dedicated User",
            description: "Completed 50 sessions.",
            iconName: "flame.fill",
            condition: { $0.listsCompleted >= 50 }
        ),
        AchievementDefinition(
            id: "three_day_streak",
            title: "Three-Day Streak",
            description: "Used the app 3 days in a row.",
            iconName: "calendar",
            condition: { $0.streakDays >= 3 }
        ),
        AchievementDefinition(
            id: "week_long_habit",
            title: "Week-Long Habit",
            description: "Used the app 7 days in a row.",
            iconName: "calendar.badge.checkmark",
            condition: { $0.streakDays >= 7 }
        )
    ]
}

enum RecipeCatalog {
    static let all: [Recipe] = [
        Recipe(
            id: "r1",
            name: "Classic Margherita Pizza",
            cookingTimeMinutes: 35,
            category: "Italian",
            ingredients: ["Pizza dough", "Tomato sauce", "Fresh mozzarella", "Basil leaves", "Olive oil", "Salt"],
            steps: [
                "Preheat oven to 475°F (245°C).",
                "Roll out dough on a floured surface.",
                "Spread tomato sauce evenly.",
                "Add mozzarella and bake 12–15 minutes.",
                "Top with fresh basil and drizzle olive oil."
            ],
            accentIndex: 0
        ),
        Recipe(
            id: "r2",
            name: "Creamy Mushroom Risotto",
            cookingTimeMinutes: 40,
            category: "Italian",
            ingredients: ["Arborio rice", "Mushrooms", "Vegetable broth", "Parmesan", "White wine", "Butter", "Onion"],
            steps: [
                "Sauté onion and mushrooms in butter.",
                "Add rice and toast for 2 minutes.",
                "Deglaze with white wine.",
                "Add warm broth ladle by ladle, stirring constantly.",
                "Finish with Parmesan and serve hot."
            ],
            accentIndex: 1
        ),
        Recipe(
            id: "r3",
            name: "Grilled Lemon Herb Chicken",
            cookingTimeMinutes: 30,
            category: "Main Course",
            ingredients: ["Chicken breasts", "Lemon juice", "Garlic", "Olive oil", "Rosemary", "Thyme", "Salt", "Pepper"],
            steps: [
                "Marinate chicken with lemon, garlic, and herbs for 20 minutes.",
                "Preheat grill to medium-high heat.",
                "Grill chicken 6–7 minutes per side.",
                "Rest for 5 minutes before slicing.",
                "Serve with fresh lemon wedges."
            ],
            accentIndex: 2
        ),
        Recipe(
            id: "r4",
            name: "Vegetable Stir Fry",
            cookingTimeMinutes: 20,
            category: "Asian",
            ingredients: ["Broccoli", "Bell peppers", "Carrots", "Soy sauce", "Ginger", "Garlic", "Sesame oil"],
            steps: [
                "Heat sesame oil in a wok over high heat.",
                "Add ginger and garlic, stir 30 seconds.",
                "Add vegetables and stir fry 5–7 minutes.",
                "Add soy sauce and toss to coat.",
                "Serve immediately over rice."
            ],
            accentIndex: 3
        ),
        Recipe(
            id: "r5",
            name: "Avocado Toast Deluxe",
            cookingTimeMinutes: 10,
            category: "Breakfast",
            ingredients: ["Sourdough bread", "Avocado", "Cherry tomatoes", "Red pepper flakes", "Lemon", "Salt"],
            steps: [
                "Toast bread until golden.",
                "Mash avocado with lemon juice and salt.",
                "Spread avocado on toast.",
                "Top with halved cherry tomatoes.",
                "Sprinkle with red pepper flakes."
            ],
            accentIndex: 4
        ),
        Recipe(
            id: "r6",
            name: "Beef Tacos",
            cookingTimeMinutes: 25,
            category: "Mexican",
            ingredients: ["Ground beef", "Taco shells", "Lettuce", "Tomato", "Cheddar cheese", "Taco seasoning", "Sour cream"],
            steps: [
                "Brown ground beef in a skillet.",
                "Add taco seasoning and a splash of water.",
                "Warm taco shells in the oven.",
                "Fill shells with beef and toppings.",
                "Serve with sour cream on the side."
            ],
            accentIndex: 5
        ),
        Recipe(
            id: "r7",
            name: "Tomato Basil Soup",
            cookingTimeMinutes: 30,
            category: "Soup",
            ingredients: ["Canned tomatoes", "Onion", "Garlic", "Vegetable broth", "Fresh basil", "Heavy cream", "Olive oil"],
            steps: [
                "Sauté onion and garlic in olive oil.",
                "Add tomatoes and broth, simmer 20 minutes.",
                "Blend until smooth.",
                "Stir in cream and fresh basil.",
                "Season with salt and pepper."
            ],
            accentIndex: 0
        ),
        Recipe(
            id: "r8",
            name: "Greek Salad Bowl",
            cookingTimeMinutes: 15,
            category: "Salad",
            ingredients: ["Cucumber", "Tomatoes", "Red onion", "Feta cheese", "Kalamata olives", "Olive oil", "Oregano"],
            steps: [
                "Chop cucumber, tomatoes, and red onion.",
                "Combine in a large bowl.",
                "Add olives and crumbled feta.",
                "Dress with olive oil and oregano.",
                "Toss gently and serve chilled."
            ],
            accentIndex: 1
        ),
        Recipe(
            id: "r9",
            name: "Honey Garlic Salmon",
            cookingTimeMinutes: 22,
            category: "Seafood",
            ingredients: ["Salmon fillets", "Honey", "Soy sauce", "Garlic", "Lemon", "Butter", "Parsley"],
            steps: [
                "Mix honey, soy sauce, and minced garlic.",
                "Pan-sear salmon skin-side down for 4 minutes.",
                "Flip and pour sauce over salmon.",
                "Cook until glazed, about 3 more minutes.",
                "Garnish with parsley and lemon."
            ],
            accentIndex: 2
        ),
        Recipe(
            id: "r10",
            name: "Chocolate Chip Cookies",
            cookingTimeMinutes: 28,
            category: "Dessert",
            ingredients: ["Flour", "Butter", "Brown sugar", "Eggs", "Vanilla", "Chocolate chips", "Baking soda", "Salt"],
            steps: [
                "Cream butter and sugars until fluffy.",
                "Beat in eggs and vanilla.",
                "Mix in dry ingredients and chocolate chips.",
                "Drop spoonfuls onto a baking sheet.",
                "Bake at 375°F for 10–12 minutes."
            ],
            accentIndex: 3
        ),
        Recipe(
            id: "r11",
            name: "Spinach & Feta Omelette",
            cookingTimeMinutes: 12,
            category: "Breakfast",
            ingredients: ["Eggs", "Fresh spinach", "Feta cheese", "Butter", "Salt", "Pepper"],
            steps: [
                "Whisk eggs with salt and pepper.",
                "Sauté spinach in butter until wilted.",
                "Pour eggs over spinach in the pan.",
                "Add crumbled feta when nearly set.",
                "Fold and slide onto a plate."
            ],
            accentIndex: 4
        ),
        Recipe(
            id: "r12",
            name: "Thai Green Curry",
            cookingTimeMinutes: 35,
            category: "Asian",
            ingredients: ["Green curry paste", "Coconut milk", "Chicken", "Bamboo shoots", "Thai basil", "Fish sauce", "Rice"],
            steps: [
                "Fry curry paste in a little coconut cream.",
                "Add chicken and cook until sealed.",
                "Pour in remaining coconut milk.",
                "Simmer with bamboo shoots for 15 minutes.",
                "Finish with basil and serve over rice."
            ],
            accentIndex: 5
        )
    ]

    static func recipe(for id: String) -> Recipe? {
        all.first { $0.id == id }
    }
}
