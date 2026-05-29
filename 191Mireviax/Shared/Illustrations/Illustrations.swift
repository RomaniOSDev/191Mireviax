import SwiftUI

struct ChefHatIllustration: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color("AppPrimary").opacity(0.3))
                .frame(width: 100, height: 24)
                .offset(y: 48)
            Path { path in
                path.move(to: CGPoint(x: 30, y: 70))
                path.addLine(to: CGPoint(x: 90, y: 70))
                path.addLine(to: CGPoint(x: 85, y: 50))
                path.addLine(to: CGPoint(x: 35, y: 50))
                path.closeSubpath()
            }
            .fill(Color("AppSurface"))
            Path { path in
                path.addArc(
                    center: CGPoint(x: 60, y: 42),
                    radius: 38,
                    startAngle: .degrees(200),
                    endAngle: .degrees(-20),
                    clockwise: false
                )
                path.addLine(to: CGPoint(x: 35, y: 50))
                path.addLine(to: CGPoint(x: 85, y: 50))
                path.closeSubpath()
            }
            .fill(Color("AppPrimary"))
        }
        .frame(width: 120, height: 100)
        .scaleEffect(appeared ? 1 : 0.7)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

struct GroceryCartIllustration: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color("AppPrimary"), lineWidth: 3)
                .frame(width: 70, height: 45)
                .offset(x: -5, y: -10)
            Path { path in
                path.move(to: CGPoint(x: 20, y: 50))
                path.addLine(to: CGPoint(x: 75, y: 50))
            }
            .stroke(Color("AppPrimary"), lineWidth: 3)
            Circle()
                .fill(Color("AppAccent"))
                .frame(width: 12, height: 12)
                .offset(x: -20, y: 55)
            Circle()
                .fill(Color("AppAccent"))
                .frame(width: 12, height: 12)
                .offset(x: 25, y: 55)
        }
        .frame(width: 120, height: 100)
        .scaleEffect(appeared ? 1 : 0.7)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

struct ClockIllustration: View {
    @State private var appeared = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("AppPrimary"), lineWidth: 4)
                .frame(width: 80, height: 80)
            Circle()
                .fill(Color("AppAccent"))
                .frame(width: 6, height: 6)
            Rectangle()
                .fill(Color("AppTextPrimary"))
                .frame(width: 3, height: 28)
                .offset(y: -12)
            Rectangle()
                .fill(Color("AppPrimary"))
                .frame(width: 3, height: 20)
                .offset(x: 10, y: 4)
                .rotationEffect(.degrees(90))
        }
        .frame(width: 120, height: 100)
        .scaleEffect(appeared ? 1 : 0.7)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }
}

struct RecipePlateIllustration: View {
    let accentIndex: Int

    private var accentColor: Color {
        let colors = [
            Color("AppPrimary"),
            Color("AppAccent"),
            Color("AppSurface"),
            Color("AppPrimary"),
            Color("AppAccent"),
            Color("AppSurface")
        ]
        return colors[accentIndex % colors.count]
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color("AppSurface"))
                .frame(width: 64, height: 64)
            Circle()
                .fill(accentColor.opacity(0.6))
                .frame(width: 44, height: 44)
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color("AppAccent"))
                    .frame(width: 8, height: 8)
                    .offset(
                        x: CGFloat([0, -14, 14][index]),
                        y: CGFloat([-8, 8, 8][index])
                    )
            }
        }
        .frame(width: 72, height: 72)
    }
}
