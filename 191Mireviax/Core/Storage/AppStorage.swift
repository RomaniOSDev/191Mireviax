import Combine
import Foundation

@MainActor
final class AppDataStore: ObservableObject {
    static let shared = AppDataStore()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let favoriteRecipes = "favoriteRecipes"
        static let viewedRecipes = "viewedRecipes"
        static let loadedRecipeIDs = "loadedRecipeIDs"
        static let groceryItems = "groceryItems"
        static let sortOrder = "sortOrder"
        static let lastUpdatedDate = "lastUpdatedDate"
        static let timers = "timers"
        static let lastUsedDurationSec = "lastUsedDurationSec"
        static let favouritesAddedCount = "favouritesAddedCount"
        static let customRecipes = "customRecipes"
        static let recipeNotes = "recipeNotes"
        static let weekPlanSlots = "weekPlanSlots"
        static let timerChains = "timerChains"
        static let activityDates = "activityDates"
        static let measurementSystem = "measurementSystem"
        static let homeScreenBadgeEnabled = "homeScreenBadgeEnabled"
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { UserDefaults.standard.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { UserDefaults.standard.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { UserDefaults.standard.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                UserDefaults.standard.set(date, forKey: Keys.lastActivityDate)
            } else {
                UserDefaults.standard.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveDictionary(achievementsUnlocked, key: Keys.achievementsUnlocked) }
    }

    @Published var favoriteRecipes: [String] {
        didSet { UserDefaults.standard.set(favoriteRecipes, forKey: Keys.favoriteRecipes) }
    }

    @Published var viewedRecipes: [String] {
        didSet { UserDefaults.standard.set(viewedRecipes, forKey: Keys.viewedRecipes) }
    }

    @Published var loadedRecipeIDs: [String] {
        didSet { UserDefaults.standard.set(loadedRecipeIDs, forKey: Keys.loadedRecipeIDs) }
    }

    @Published var groceryItems: [GroceryItem] {
        didSet {
            saveCodable(groceryItems, key: Keys.groceryItems)
            lastUpdatedDate = Date()
        }
    }

    @Published var sortOrder: String {
        didSet { UserDefaults.standard.set(sortOrder, forKey: Keys.sortOrder) }
    }

    @Published var lastUpdatedDate: Date {
        didSet { UserDefaults.standard.set(lastUpdatedDate, forKey: Keys.lastUpdatedDate) }
    }

    @Published var timers: [CookingTimerItem] {
        didSet {
            saveCodable(timers, key: Keys.timers)
        }
    }

    @Published var lastUsedDurationSec: Int {
        didSet { UserDefaults.standard.set(lastUsedDurationSec, forKey: Keys.lastUsedDurationSec) }
    }

    @Published var favouritesAddedCount: Int {
        didSet { UserDefaults.standard.set(favouritesAddedCount, forKey: Keys.favouritesAddedCount) }
    }

    @Published var customRecipes: [Recipe] {
        didSet {
            saveCodable(customRecipes, key: Keys.customRecipes)
        }
    }

    @Published var recipeNotes: [String: String] {
        didSet { UserDefaults.standard.set(recipeNotes, forKey: Keys.recipeNotes) }
    }

    @Published var weekPlanSlots: [WeekPlanSlot] {
        didSet { saveCodable(weekPlanSlots, key: Keys.weekPlanSlots) }
    }

    @Published var timerChains: [TimerChainItem] {
        didSet { saveCodable(timerChains, key: Keys.timerChains) }
    }

    @Published var activityDates: [String] {
        didSet { UserDefaults.standard.set(activityDates, forKey: Keys.activityDates) }
    }

    @Published var measurementSystem: String {
        didSet { UserDefaults.standard.set(measurementSystem, forKey: Keys.measurementSystem) }
    }

    @Published var homeScreenBadgeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(homeScreenBadgeEnabled, forKey: Keys.homeScreenBadgeEnabled)
        }
    }

    var recipesViewed: Int { viewedRecipes.count }
    var listsCompleted: Int { totalSessionsCompleted }
    var favouritesAdded: Int { favouritesAddedCount }

    private var cancellables = Set<AnyCancellable>()
    private weak var bannerManager: AchievementBannerManager?

    private init() {
        let defaults = UserDefaults.standard
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked)
        favoriteRecipes = defaults.stringArray(forKey: Keys.favoriteRecipes) ?? []
        viewedRecipes = defaults.stringArray(forKey: Keys.viewedRecipes) ?? []
        loadedRecipeIDs = defaults.stringArray(forKey: Keys.loadedRecipeIDs) ?? []
        groceryItems = Self.loadCodable(key: Keys.groceryItems) ?? []
        sortOrder = defaults.string(forKey: Keys.sortOrder) ?? "category"
        lastUpdatedDate = defaults.object(forKey: Keys.lastUpdatedDate) as? Date ?? Date()
        timers = Self.loadCodable(key: Keys.timers) ?? []
        lastUsedDurationSec = defaults.object(forKey: Keys.lastUsedDurationSec) as? Int ?? 600
        favouritesAddedCount = defaults.integer(forKey: Keys.favouritesAddedCount)
        customRecipes = Self.loadCodable(key: Keys.customRecipes) ?? []
        recipeNotes = defaults.dictionary(forKey: Keys.recipeNotes) as? [String: String] ?? [:]
        weekPlanSlots = Self.loadCodable(key: Keys.weekPlanSlots) ?? AppDataStore.defaultWeekPlan()
        timerChains = Self.loadCodable(key: Keys.timerChains) ?? []
        activityDates = defaults.stringArray(forKey: Keys.activityDates) ?? []
        measurementSystem = defaults.string(forKey: Keys.measurementSystem) ?? MeasurementSystem.metric.rawValue
        homeScreenBadgeEnabled = defaults.object(forKey: Keys.homeScreenBadgeEnabled) as? Bool ?? true

        NotificationCenter.default.publisher(for: .dataReset)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.reloadFromDefaults()
            }
            .store(in: &cancellables)
    }

    func configure(bannerManager: AchievementBannerManager) {
        self.bannerManager = bannerManager
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasSeenOnboarding = true
        recordActivity()
    }

    // MARK: - Recipes

    var displayedRecipes: [Recipe] {
        loadedRecipeIDs.compactMap { recipe(for: $0) }
    }

    var allAvailableRecipes: [Recipe] {
        var seen = Set<String>()
        var list: [Recipe] = []
        for id in loadedRecipeIDs {
            guard !seen.contains(id), let recipe = recipe(for: id) else { continue }
            seen.insert(id)
            list.append(recipe)
        }
        for custom in customRecipes where !seen.contains(custom.id) {
            seen.insert(custom.id)
            list.append(custom)
        }
        return list
    }

    var recipeCategories: [String] {
        Array(Set(allAvailableRecipes.map(\.category))).sorted()
    }

    func recipe(for id: String) -> Recipe? {
        if let custom = customRecipes.first(where: { $0.id == id }) { return custom }
        return RecipeCatalog.recipe(for: id)
    }

    func filteredRecipes(options: RecipeFilterOptions) -> [Recipe] {
        allAvailableRecipes.filter { recipe in
            if !options.searchText.isEmpty {
                let query = options.searchText.lowercased()
                let matches = recipe.name.lowercased().contains(query)
                    || recipe.category.lowercased().contains(query)
                    || recipe.ingredients.contains { $0.lowercased().contains(query) }
                if !matches { return false }
            }
            if let category = options.category, category != RecipeFilterOptions.allCategories {
                if recipe.category != category { return false }
            }
            if let maxMinutes = options.maxCookingMinutes {
                if recipe.cookingTimeMinutes > maxMinutes { return false }
            }
            return true
        }
    }

    func saveCustomRecipe(_ recipe: Recipe) {
        let updated: Recipe
        if recipe.id.hasPrefix("custom-") {
            updated = recipe
        } else {
            updated = Recipe(
                id: "custom-\(UUID().uuidString)",
                name: recipe.name,
                cookingTimeMinutes: recipe.cookingTimeMinutes,
                category: recipe.category,
                ingredients: recipe.ingredients,
                steps: recipe.steps,
                accentIndex: recipe.accentIndex,
                isUserCreated: true
            )
        }
        if let index = customRecipes.firstIndex(where: { $0.id == updated.id }) {
            customRecipes[index] = updated
        } else {
            customRecipes.append(updated)
            if !loadedRecipeIDs.contains(updated.id) {
                loadedRecipeIDs.append(updated.id)
            }
        }
        recordActivity()
        FeedbackService.success()
    }

    func deleteCustomRecipe(id: String) {
        customRecipes.removeAll { $0.id == id }
        loadedRecipeIDs.removeAll { $0 == id }
        recipeNotes[id] = nil
        FeedbackService.lightTap()
    }

    func note(for recipeID: String) -> String {
        recipeNotes[recipeID] ?? ""
    }

    func setNote(_ note: String, for recipeID: String) {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            recipeNotes.removeValue(forKey: recipeID)
        } else {
            recipeNotes[recipeID] = trimmed
        }
        recordActivity()
    }

    func addRecipeIngredientsToGroceryList(_ recipe: Recipe, multiplier: Double = 1) -> [String] {
        var warnings: [String] = []
        for ingredient in recipe.ingredients {
            let scaled = IngredientScaler.scaled(ingredient, multiplier: multiplier)
            let name = scaled.components(separatedBy: " ").first ?? scaled
            if isDuplicateGrocery(name: name) {
                warnings.append(name)
            }
            let item = GroceryItem(
                name: scaled,
                quantity: "1",
                category: .pantry
            )
            groceryItems.append(item)
        }
        recordActivity()
        FeedbackService.success()
        return warnings
    }

    static func defaultWeekPlan() -> [WeekPlanSlot] {
        var slots: [WeekPlanSlot] = []
        for day in 0..<7 {
            for meal in MealType.allCases {
                slots.append(WeekPlanSlot(dayIndex: day, mealType: meal))
            }
        }
        return slots
    }

    func assignRecipe(_ recipeID: String?, to slotID: UUID) {
        guard let index = weekPlanSlots.firstIndex(where: { $0.id == slotID }) else { return }
        weekPlanSlots[index].recipeID = recipeID
        recordActivity()
        FeedbackService.mediumTap()
    }

    func moveWeekPlanRecipe(from sourceSlotID: UUID, to targetSlotID: UUID) {
        guard let sourceIndex = weekPlanSlots.firstIndex(where: { $0.id == sourceSlotID }),
              let targetIndex = weekPlanSlots.firstIndex(where: { $0.id == targetSlotID }) else { return }
        let sourceRecipe = weekPlanSlots[sourceIndex].recipeID
        weekPlanSlots[sourceIndex].recipeID = weekPlanSlots[targetIndex].recipeID
        weekPlanSlots[targetIndex].recipeID = sourceRecipe
        recordActivity()
    }

    func addWeekPlanToShoppingList() -> Int {
        var added = 0
        let recipeIDs = weekPlanSlots.compactMap(\.recipeID)
        for recipeID in Set(recipeIDs) {
            guard let recipe = recipe(for: recipeID) else { continue }
            for ingredient in recipe.ingredients {
                if isDuplicateGrocery(name: ingredient) { continue }
                groceryItems.append(GroceryItem(name: ingredient, quantity: "1", category: .pantry))
                added += 1
            }
        }
        if added > 0 {
            recordSessionCompletion()
            FeedbackService.success()
        }
        return added
    }

    func startTimersForRecipe(_ recipe: Recipe) {
        let stages = StepDurationParser.timersFromRecipe(recipe)
        for stage in stages {
            addTimer(CookingTimerItem(dishName: stage.name, durationSeconds: stage.seconds))
        }
    }

    func discoverMoreRecipes() {
        let undiscovered = RecipeCatalog.all.filter { !loadedRecipeIDs.contains($0.id) }
        let batch = undiscovered.prefix(3)
        guard !batch.isEmpty else { return }
        loadedRecipeIDs.append(contentsOf: batch.map(\.id))
        recordSessionCompletion()
        FeedbackService.success()
        checkAchievements()
    }

    func markRecipeViewed(_ recipeID: String) {
        guard !viewedRecipes.contains(recipeID) else { return }
        viewedRecipes.append(recipeID)
        recordActivity()
        checkAchievements()
    }

    func toggleFavorite(recipeID: String) -> Bool {
        if let index = favoriteRecipes.firstIndex(of: recipeID) {
            favoriteRecipes.remove(at: index)
            FeedbackService.lightTap()
            return false
        } else {
            favoriteRecipes.append(recipeID)
            favouritesAddedCount += 1
            FeedbackService.favoriteAdded()
            recordActivity()
            checkAchievements()
            return true
        }
    }

    func isFavorite(recipeID: String) -> Bool {
        favoriteRecipes.contains(recipeID)
    }

    // MARK: - Grocery

    func isDuplicateGrocery(name: String) -> Bool {
        let normalized = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return groceryItems.contains { item in
            !item.completed && item.name.lowercased().contains(normalized)
                || normalized.contains(item.name.lowercased())
        }
    }

    func sortedGroceryItems(_ items: [GroceryItem]) -> [GroceryItem] {
        switch GrocerySortOrder(rawValue: sortOrder) ?? .category {
        case .category:
            return items.sorted { lhs, rhs in
                if lhs.category.rawValue == rhs.category.rawValue {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }
                return lhs.category.rawValue < rhs.category.rawValue
            }
        case .alphabetical:
            return items.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .dateAdded:
            return items.sorted { $0.createdAt > $1.createdAt }
        }
    }

    @discardableResult
    func addGroceryItem(_ item: GroceryItem) -> Bool {
        if isDuplicateGrocery(name: item.name) {
            FeedbackService.warning()
            return false
        }
        groceryItems.append(item)
        recordActivity()
        FeedbackService.success()
        return true
    }

    func applyGroceryTemplate(_ template: GroceryListTemplate) {
        for templateItem in template.items {
            let quantity = UnitConverter.displayQuantity(
                templateItem.quantity,
                system: MeasurementSystem(rawValue: measurementSystem) ?? .metric
            )
            let item = GroceryItem(
                name: templateItem.name,
                quantity: quantity,
                category: templateItem.category
            )
            if !isDuplicateGrocery(name: item.name) {
                groceryItems.append(item)
            }
        }
        recordActivity()
        FeedbackService.success()
    }

    func updateGroceryItem(_ item: GroceryItem) {
        guard let index = groceryItems.firstIndex(where: { $0.id == item.id }) else { return }
        groceryItems[index] = item
        recordActivity()
    }

    func deleteGroceryItem(id: UUID) {
        groceryItems.removeAll { $0.id == id }
        FeedbackService.lightTap()
    }

    func completeGroceryItem(id: UUID) {
        guard let index = groceryItems.firstIndex(where: { $0.id == id }) else { return }
        groceryItems[index].completed = true
        recordSessionCompletion()
        FeedbackService.itemCompleted()
        checkAchievements()
    }

    func restoreGroceryItem(id: UUID) {
        guard let index = groceryItems.firstIndex(where: { $0.id == id }) else { return }
        groceryItems[index].completed = false
        FeedbackService.lightTap()
    }

    // MARK: - Timers

    func addTimer(_ timer: CookingTimerItem) {
        var newTimer = timer
        if !newTimer.isPaused {
            newTimer.endDate = Date().addingTimeInterval(TimeInterval(newTimer.remainingSeconds))
        }
        timers.append(newTimer)
        lastUsedDurationSec = timer.durationSeconds
        recordActivity()
        FeedbackService.mediumTap()
    }

    func updateTimer(_ timer: CookingTimerItem) {
        guard let index = timers.firstIndex(where: { $0.id == timer.id }) else { return }
        timers[index] = timer
    }

    func deleteTimer(id: UUID) {
        timers.removeAll { $0.id == id }
        FeedbackService.lightTap()
    }

    func toggleTimerPause(id: UUID) {
        guard let index = timers.firstIndex(where: { $0.id == id }) else { return }
        var timer = timers[index]
        if timer.isPaused {
            timer.isPaused = false
            timer.endDate = Date().addingTimeInterval(TimeInterval(timer.remainingSeconds))
        } else {
            if let endDate = timer.endDate {
                timer.remainingSeconds = max(0, Int(endDate.timeIntervalSinceNow))
            }
            timer.isPaused = true
            timer.endDate = nil
        }
        timers[index] = timer
        FeedbackService.lightTap()
    }

    func completeTimer(id: UUID) {
        if let timer = timers.first(where: { $0.id == id }), let chainID = timer.chainID {
            advanceTimerChain(chainID: chainID, completedTimerID: id)
        } else {
            timers.removeAll { $0.id == id }
        }
        totalMinutesUsed += 1
        recordSessionCompletion()
        FeedbackService.timerCompleted()
        checkAchievements()
    }

    func startTimerChain(title: String, stages: [TimerChainStage]) {
        guard let first = stages.first else { return }
        let chain = TimerChainItem(title: title, stages: stages, currentStageIndex: 0, isActive: true)
        timerChains.append(chain)
        var timer = CookingTimerItem(
            dishName: "\(title): \(first.name)",
            durationSeconds: first.durationSeconds,
            chainID: chain.id,
            chainStageIndex: 0
        )
        addTimer(timer)
        if let index = timerChains.firstIndex(where: { $0.id == chain.id }) {
            timerChains[index].activeTimerID = timers.last?.id
        }
    }

    func startTimerFromPreset(_ preset: TimerPreset) {
        addTimer(CookingTimerItem(dishName: preset.name, durationSeconds: preset.durationSeconds))
    }

    private func advanceTimerChain(chainID: UUID, completedTimerID: UUID) {
        timers.removeAll { $0.id == completedTimerID }
        guard let chainIndex = timerChains.firstIndex(where: { $0.id == chainID }) else { return }
        var chain = timerChains[chainIndex]
        let nextIndex = chain.currentStageIndex + 1
        if nextIndex < chain.stages.count {
            chain.currentStageIndex = nextIndex
            let stage = chain.stages[nextIndex]
            var timer = CookingTimerItem(
                dishName: "\(chain.title): \(stage.name)",
                durationSeconds: stage.durationSeconds,
                chainID: chain.id,
                chainStageIndex: nextIndex
            )
            timerChains[chainIndex] = chain
            addTimer(timer)
            if let timerIndex = timerChains.firstIndex(where: { $0.id == chainID }) {
                timerChains[timerIndex].activeTimerID = timers.last?.id
            }
        } else {
            chain.isActive = false
            chain.activeTimerID = nil
            timerChains[chainIndex] = chain
        }
    }

    func syncTimersOnForeground() {
        var updated = timers
        for index in updated.indices {
            guard !updated[index].isPaused, let endDate = updated[index].endDate else { continue }
            let remaining = max(0, Int(endDate.timeIntervalSinceNow))
            updated[index].remainingSeconds = remaining
            if remaining == 0 {
                let timerID = updated[index].id
                timers = updated.filter { $0.id != timerID }
                totalMinutesUsed += max(1, updated[index].durationSeconds / 60)
                recordSessionCompletion()
                FeedbackService.timerCompleted()
                checkAchievements()
                return
            }
        }
        timers = updated
    }

    func pauseAllTimers() {
        var updated = timers
        for index in updated.indices where !updated[index].isPaused {
            if let endDate = updated[index].endDate {
                updated[index].remainingSeconds = max(0, Int(endDate.timeIntervalSinceNow))
            }
            updated[index].isPaused = true
            updated[index].endDate = nil
        }
        timers = updated
    }

    // MARK: - Activity & Achievements

    func recordActivity() {
        logActivityDate()
        updateStreak()
    }

    private func logActivityDate() {
        let key = Self.dayKey(for: Date())
        if !activityDates.contains(key) {
            activityDates.append(key)
        }
    }

    static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func activityDatesInMonth(reference: Date = Date()) -> Set<Int> {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: reference)
        let year = calendar.component(.year, from: reference)
        var days = Set<Int>()
        for key in activityDates {
            let parts = key.split(separator: "-")
            guard parts.count == 3,
                  let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2]),
                  y == year, m == month else { continue }
            days.insert(d)
        }
        return days
    }

    func exportBundle() -> AppExportBundle {
        AppExportBundle(
            customRecipes: customRecipes,
            recipeNotes: recipeNotes,
            weekPlanSlots: weekPlanSlots,
            groceryItems: groceryItems,
            favoriteRecipes: favoriteRecipes,
            loadedRecipeIDs: loadedRecipeIDs
        )
    }

    func importBundle(_ bundle: AppExportBundle) {
        customRecipes = bundle.customRecipes
        recipeNotes = bundle.recipeNotes
        weekPlanSlots = bundle.weekPlanSlots
        groceryItems = bundle.groceryItems
        favoriteRecipes = bundle.favoriteRecipes
        loadedRecipeIDs = bundle.loadedRecipeIDs
        recordActivity()
        FeedbackService.success()
    }

    func recordSessionCompletion() {
        totalSessionsCompleted += 1
        updateStreak()
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 0 {
                // Same day — no streak change
            } else if dayDiff == 1 {
                streakDays += 1
            } else {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        lastActivityDate = Date()
        checkAchievements()
    }

    func checkAchievements() {
        for achievement in AchievementCatalog.all {
            guard achievementsUnlocked[achievement.id] == nil else { continue }
            if achievement.condition(self) {
                achievementsUnlocked[achievement.id] = Date()
                bannerManager?.enqueue(title: "Achievement Unlocked", message: achievement.title)
            }
        }
    }

    func isAchievementUnlocked(_ id: String) -> Bool {
        achievementsUnlocked[id] != nil
    }

    func unlockedAchievementCount() -> Int {
        achievementsUnlocked.count
    }

    // MARK: - Reset

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func reloadFromDefaults() {
        let defaults = UserDefaults.standard
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked)
        favoriteRecipes = defaults.stringArray(forKey: Keys.favoriteRecipes) ?? []
        viewedRecipes = defaults.stringArray(forKey: Keys.viewedRecipes) ?? []
        loadedRecipeIDs = defaults.stringArray(forKey: Keys.loadedRecipeIDs) ?? []
        groceryItems = Self.loadCodable(key: Keys.groceryItems) ?? []
        sortOrder = defaults.string(forKey: Keys.sortOrder) ?? "category"
        lastUpdatedDate = defaults.object(forKey: Keys.lastUpdatedDate) as? Date ?? Date()
        timers = Self.loadCodable(key: Keys.timers) ?? []
        lastUsedDurationSec = defaults.object(forKey: Keys.lastUsedDurationSec) as? Int ?? 600
        favouritesAddedCount = defaults.integer(forKey: Keys.favouritesAddedCount)
        customRecipes = Self.loadCodable(key: Keys.customRecipes) ?? []
        recipeNotes = defaults.dictionary(forKey: Keys.recipeNotes) as? [String: String] ?? [:]
        weekPlanSlots = Self.loadCodable(key: Keys.weekPlanSlots) ?? AppDataStore.defaultWeekPlan()
        timerChains = Self.loadCodable(key: Keys.timerChains) ?? []
        activityDates = defaults.stringArray(forKey: Keys.activityDates) ?? []
        measurementSystem = defaults.string(forKey: Keys.measurementSystem) ?? MeasurementSystem.metric.rawValue
        homeScreenBadgeEnabled = defaults.object(forKey: Keys.homeScreenBadgeEnabled) as? Bool ?? true
    }

    // MARK: - Persistence Helpers

    private func saveCodable<T: Codable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func loadCodable<T: Codable>(key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func saveDictionary(_ dict: [String: Date], key: String) {
        let stringKeyed = dict.mapValues { $0.timeIntervalSince1970 }
        UserDefaults.standard.set(stringKeyed, forKey: key)
    }

    private static func loadDictionary(key: String) -> [String: Date] {
        guard let raw = UserDefaults.standard.dictionary(forKey: key) as? [String: Double] else { return [:] }
        return raw.mapValues { Date(timeIntervalSince1970: $0) }
    }
}
