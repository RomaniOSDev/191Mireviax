import SwiftUI

struct ActivityCalendarView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private var activeDays: Set<Int> { store.activityDatesInMonth() }
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Activity Calendar")
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(Color("AppAccent"))
                        Text("Current streak: \(store.streakDays) days")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
                Spacer()
            }

            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(String(symbol.prefix(1)))
                        .font(.caption2.bold())
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...31, id: \.self) { day in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(
                                activeDays.contains(day)
                                    ? AnyShapeStyle(AppGradients.primary)
                                    : AnyShapeStyle(Color("AppBackground").opacity(0.45))
                            )
                            .frame(height: 36)
                            .overlay {
                                if activeDays.contains(day) {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(AppGradients.surfaceHighlight)
                                        .frame(height: 36)
                                }
                            }
                        if activeDays.contains(day) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(Color("AppAccent").opacity(0.55), lineWidth: 1)
                                .frame(height: 36)
                        }
                        Text("\(day)")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                }
            }
        }
        .padding(16)
        .elevatedCard()
        .padding(.horizontal, 16)
    }
}
