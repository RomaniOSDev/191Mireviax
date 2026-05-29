import SwiftUI
import UniformTypeIdentifiers

struct WeekPlanView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var draggedRecipeID: String?
    @State private var showAddedAlert = false
    @State private var addedCount = 0

    private let dayNames = Calendar.current.shortWeekdaySymbols

    var body: some View {
        ZStack {
            AppBackgroundView()
            ScrollView {
            VStack(spacing: 16) {
                Text("Drag recipes between slots to reorganize your week.")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)

                ForEach(0..<7, id: \.self) { day in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(dayNames[day])
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                            Spacer()
                            Text(weekdayDateLabel(day))
                                .font(.caption)
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                        ForEach(MealType.allCases) { meal in
                            if let slot = store.weekPlanSlots.first(where: { $0.dayIndex == day && $0.mealType == meal }) {
                                WeekPlanMealCell(
                                    mealType: meal,
                                    recipeName: slot.recipeID.flatMap { store.recipe(for: $0)?.name },
                                    recipes: store.allAvailableRecipes,
                                    onAssign: { recipeID in
                                        store.assignRecipe(recipeID, to: slot.id)
                                    }
                                )
                                .onDrag {
                                    if let recipeID = slot.recipeID {
                                        draggedRecipeID = recipeID
                                        return NSItemProvider(object: recipeID as NSString)
                                    }
                                    return NSItemProvider()
                                }
                                .onDrop(of: [.text], delegate: WeekPlanDropDelegate(
                                    targetSlotID: slot.id,
                                    store: store,
                                    draggedRecipeID: $draggedRecipeID
                                ))
                            }
                        }
                    }
                    .padding(16)
                    .listCard(accentLeading: day == Calendar.current.component(.weekday, from: Date()) - 1)
                    .padding(.horizontal, 16)
                }

                Button("Add Plan to Shopping List") {
                    addedCount = store.addWeekPlanToShoppingList()
                    showAddedAlert = true
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .padding(.top, 8)
            }
        }
        .navigationTitle("Week Plan")
        .navigationBarTitleDisplayMode(.large)
        .alert("Shopping List Updated", isPresented: $showAddedAlert) {
            Button("OK", role: .cancel) { FeedbackService.lightTap() }
        } message: {
            Text(addedCount > 0 ? "Added \(addedCount) items from your meal plan." : "No new items to add.")
        }
    }

    private func weekdayDateLabel(_ dayIndex: Int) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let offset = dayIndex - (weekday - 1)
        guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

private struct WeekPlanDropDelegate: DropDelegate {
    let targetSlotID: UUID
    let store: AppDataStore
    @Binding var draggedRecipeID: String?

    func performDrop(info: DropInfo) -> Bool {
        guard let dragged = draggedRecipeID else { return false }
        store.assignRecipe(dragged, to: targetSlotID)
        draggedRecipeID = nil
        return true
    }
}
