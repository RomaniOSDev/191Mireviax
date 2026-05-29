import SwiftUI

enum KitchenSection: String, CaseIterable, Identifiable {
    case shopping = "Shopping"
    case timer = "Timer"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .shopping: return "cart.fill"
        case .timer: return "timer"
        }
    }
}

struct KitchenHubView: View {
    @Binding var selectedSection: KitchenSection

    var body: some View {
        VStack(spacing: 0) {
            KitchenSegmentedControl(selection: $selectedSection)

            switch selectedSection {
            case .shopping:
                ShoppingListView()
            case .timer:
                CookingTimerView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
