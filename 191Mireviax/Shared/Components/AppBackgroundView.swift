import SwiftUI

/// Full-screen gradient background. Uses overlays (not GeometryReader) so `.background` always fills the screen.
struct AppBackgroundView: View {
    var body: some View {
        AppGradients.background
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color("AppPrimary").opacity(0.22), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 160
                        )
                    )
                    .frame(width: 280, height: 280)
                    .offset(x: -60, y: -80)
            }
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color("AppAccent").opacity(0.12), Color.clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: 140
                        )
                    )
                    .frame(width: 240, height: 240)
                    .offset(x: 50, y: 60)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}
