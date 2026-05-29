import SwiftUI

struct ListTemplatesSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onApply: (GroceryListTemplate) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(GroceryTemplateCatalog.all) { template in
                            Button {
                                onApply(template)
                                dismiss()
                            } label: {
                                TemplateListCell(name: template.name, itemCount: template.items.count)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 12)
                }
            }
            .navigationTitle("List Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }
}
