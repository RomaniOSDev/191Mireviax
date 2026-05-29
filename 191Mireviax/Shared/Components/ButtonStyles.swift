import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(Color("AppAccent"))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(AppGradients.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color("AppPrimary").opacity(0.6), Color("AppAccent").opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                if pressed { FeedbackService.lightTap() }
            }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .background(
                ZStack {
                    AppGradients.primary
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppGradients.surfaceHighlight)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color("AppAccent").opacity(0.35), lineWidth: 1)
            )
            .compositingGroup()
            .shadow(color: Color("AppPrimary").opacity(configuration.isPressed ? 0.1 : 0.35), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { pressed in
                if pressed { FeedbackService.lightTap() }
            }
    }
}

struct SurfaceCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .elevatedCard()
    }
}

extension View {
    func surfaceCard() -> some View {
        modifier(SurfaceCardModifier())
    }
}

struct SuccessPulseModifier: ViewModifier {
    @Binding var trigger: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if trigger {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("AppAccent"), lineWidth: 2)
                        .transition(.opacity)
                }
            }
            .onChange(of: trigger) { active in
                if active {
                    Task {
                        try? await Task.sleep(nanoseconds: 400_000_000)
                        withAnimation(.easeInOut(duration: 0.3)) {
                            trigger = false
                        }
                    }
                }
            }
    }
}

struct SuccessCheckmarkOverlay: View {
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .foregroundStyle(Color("AppAccent"))
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isVisible = false
                        }
                    }
                }
        }
    }
}
