import Combine
import SwiftUI

@MainActor
final class ShoppingListViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var showShareSheet = false
    @Published var showTemplatesSheet = false
    @Published var pulseItemID: UUID?
    @Published var showCheckmark = false
    @Published var duplicateMessage: String?
    @Published var showDuplicateAlert = false

    private var store: AppDataStore?

    func configure(store: AppDataStore) {
        self.store = store
    }

    var activeItems: [GroceryItem] {
        guard let store else { return [] }
        return store.sortedGroceryItems(store.groceryItems.filter { !$0.completed })
    }

    var purchasedItems: [GroceryItem] {
        guard let store else { return [] }
        return store.sortedGroceryItems(store.groceryItems.filter { $0.completed })
    }

    var isEmpty: Bool {
        (store?.groceryItems.isEmpty) ?? true
    }

    var groupedActiveItems: [(GroceryCategory, [GroceryItem])] {
        let grouped = Dictionary(grouping: activeItems, by: \.category)
        return GroceryCategory.allCases.compactMap { category in
            guard let items = grouped[category], !items.isEmpty else { return nil }
            return (category, items)
        }
    }

    var sortOrder: GrocerySortOrder {
        GrocerySortOrder(rawValue: store?.sortOrder ?? "category") ?? .category
    }

    func setSortOrder(_ order: GrocerySortOrder) {
        store?.sortOrder = order.rawValue
        FeedbackService.lightTap()
    }

    func addItem(name: String, quantity: String, category: GroceryCategory) {
        guard let store else { return }
        let system = MeasurementSystem(rawValue: store.measurementSystem) ?? .metric
        let displayQty = UnitConverter.displayQuantity(quantity, system: system)
        let item = GroceryItem(name: name, quantity: displayQty, category: category)
        if store.isDuplicateGrocery(name: name) {
            duplicateMessage = "\(name) is already on your list."
            showDuplicateAlert = true
            return
        }
        store.addGroceryItem(item)
        showCheckmark = true
    }

    func applyTemplate(_ template: GroceryListTemplate) {
        store?.applyGroceryTemplate(template)
        showCheckmark = true
    }

    func completeItem(id: UUID) {
        withAnimation(.easeInOut(duration: 0.3)) {
            store?.completeGroceryItem(id: id)
        }
        pulseItemID = id
        Task {
            try? await Task.sleep(nanoseconds: 400_000_000)
            pulseItemID = nil
        }
    }

    func restoreItem(id: UUID) {
        withAnimation(.easeInOut(duration: 0.3)) {
            store?.restoreGroceryItem(id: id)
        }
    }

    func deleteItem(id: UUID) {
        store?.deleteGroceryItem(id: id)
    }

    func displayQuantity(_ quantity: String) -> String {
        guard let store else { return quantity }
        let system = MeasurementSystem(rawValue: store.measurementSystem) ?? .metric
        return UnitConverter.displayQuantity(quantity, system: system)
    }

    func shareText() -> String {
        guard let items = store?.groceryItems.filter({ !$0.completed }), !items.isEmpty else {
            return "Shopping List is empty."
        }
        let lines = items.map { item in
            let qty = displayQuantity(item.quantity)
            return "• \(item.name) (\(qty)) — \(item.category.rawValue)"
        }
        return "Shopping List\n\n" + lines.joined(separator: "\n")
    }
}
