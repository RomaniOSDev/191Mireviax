import SwiftUI

struct RecipeFilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var options: RecipeFilterOptions
    let categories: [String]

    @State private var maxMinutes: Double = 120

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section("Category") {
                        Picker("Category", selection: Binding(
                            get: { options.category ?? RecipeFilterOptions.allCategories },
                            set: { newValue in
                                options.category = newValue == RecipeFilterOptions.allCategories ? nil : newValue
                            }
                        )) {
                            Text(RecipeFilterOptions.allCategories).tag(RecipeFilterOptions.allCategories)
                            ForEach(categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                    }
                    Section("Max cooking time") {
                        Toggle("Limit cooking time", isOn: Binding(
                            get: { options.maxCookingMinutes != nil },
                            set: { enabled in
                                options.maxCookingMinutes = enabled ? Int(maxMinutes) : nil
                            }
                        ))
                        if options.maxCookingMinutes != nil {
                            Slider(value: $maxMinutes, in: 10...120, step: 5) {
                                Text("Minutes")
                            }
                            .onChange(of: maxMinutes) { value in
                                options.maxCookingMinutes = Int(value)
                            }
                            Text("Up to \(Int(maxMinutes)) minutes")
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    Section {
                        Button("Clear Filters") {
                            options = RecipeFilterOptions()
                            maxMinutes = 120
                            FeedbackService.lightTap()
                        }
                        .foregroundStyle(Color("AppPrimary"))
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear {
                if let max = options.maxCookingMinutes {
                    maxMinutes = Double(max)
                }
            }
        }
    }
}
