import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdownText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    Group {
                        if let attributed = try? AttributedString(markdown: markdownText) {
                            Text(attributed)
                        } else {
                            Text(markdownText)
                        }
                    }
                    .foregroundStyle(Color("AppTextPrimary"))
                    .tint(Color("AppPrimary"))
                    .padding(16)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        FeedbackService.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear {
                markdownText = loadPrivacyPolicy()
            }
        }
    }

    private func loadPrivacyPolicy() -> String {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            return "# Privacy Policy\nThis app does NOT collect, store, or transmit any personal data."
        }
        return content
    }
}
