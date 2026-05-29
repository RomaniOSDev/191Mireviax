import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = ShoppingListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ZStack {
                if viewModel.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            symbolName: "cart.fill",
                            title: "No items yet. Tap + to add your groceries.",
                            subtitle: "Tap + to start building your list"
                        )
                        .overlay {
                            GroceryCartIllustration()
                                .offset(y: -50)
                        }
                        .padding(.top, 60)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            ForEach(viewModel.groupedActiveItems, id: \.0) { category, items in
                                Section {
                                    ForEach(items) { item in
                                        GroceryListCell(
                                            item: item,
                                            displayQuantity: viewModel.displayQuantity(item.quantity),
                                            isPulsing: viewModel.pulseItemID == item.id,
                                            onComplete: {
                                                viewModel.completeItem(id: item.id)
                                            }
                                        )
                                        .contextMenu {
                                            Button("Mark Complete") {
                                                viewModel.completeItem(id: item.id)
                                            }
                                            Button("Delete", role: .destructive) {
                                                viewModel.deleteItem(id: item.id)
                                            }
                                        }
                                    }
                                } header: {
                                    SectionHeaderView(
                                        title: category.rawValue,
                                        iconName: category.iconName,
                                        trailing: "\(items.count)"
                                    )
                                }
                            }

                            if !viewModel.purchasedItems.isEmpty {
                                Section {
                                    ForEach(viewModel.purchasedItems) { item in
                                        GroceryListCell(
                                            item: item,
                                            displayQuantity: viewModel.displayQuantity(item.quantity),
                                            isPulsing: false,
                                            isCompleted: true,
                                            onComplete: {
                                                viewModel.restoreItem(id: item.id)
                                            }
                                        )
                                    }
                                } header: {
                                    SectionHeaderView(
                                        title: "Purchased Items",
                                        iconName: "checkmark.circle.fill"
                                    )
                                }
                            }
                        }
                        .padding(.bottom, 100)
                    }
                }

                if viewModel.showCheckmark {
                    SuccessCheckmarkOverlay(isVisible: $viewModel.showCheckmark)
                }
                }
            }
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        ForEach(GrocerySortOrder.allCases) { order in
                            Button {
                                viewModel.setSortOrder(order)
                            } label: {
                                HStack {
                                    Text(order.title)
                                    if viewModel.sortOrder == order {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(width: 40, height: 40)
                            .background(Color("AppSurface").opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 8) {
                        ToolbarIconButton(iconName: "doc.on.doc") {
                            viewModel.showTemplatesSheet = true
                        }
                        ToolbarIconButton(iconName: "plus") {
                            viewModel.showAddSheet = true
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if !viewModel.isEmpty {
                    Button("Share List") {
                        FeedbackService.lightTap()
                        viewModel.showShareSheet = true
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color.clear, Color("AppBackground").opacity(0.95)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    )
                }
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddGroceryItemView { name, quantity, category in
                    viewModel.addItem(name: name, quantity: quantity, category: category)
                }
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                ShareSheetView(items: [viewModel.shareText()])
            }
            .sheet(isPresented: $viewModel.showTemplatesSheet) {
                ListTemplatesSheet { template in
                    viewModel.applyTemplate(template)
                }
            }
            .alert("Duplicate Item", isPresented: $viewModel.showDuplicateAlert) {
                Button("OK", role: .cancel) { FeedbackService.lightTap() }
            } message: {
                Text(viewModel.duplicateMessage ?? "This item is already on your list.")
            }
            .onAppear { viewModel.configure(store: store) }
        }
    }
}

struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
