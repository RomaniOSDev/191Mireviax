import SwiftUI

// MARK: - Recipe

struct RecipeListCell: View {
    let recipe: Recipe
    let isFavorite: Bool
    let isPulsing: Bool
    let onFavoriteTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            NavigationLink(value: recipe) {
                cellBody
            }
            .buttonStyle(.plain)

            Button {
                onFavoriteTap()
            } label: {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(isFavorite ? Color("AppAccent") : Color("AppTextSecondary"))
                    .frame(width: 44, height: 44)
                    .background(Color("AppBackground").opacity(0.4))
                    .clipShape(Circle())
            }
            .padding(.trailing, 12)
            .scaleEffect(isPulsing ? 1.25 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPulsing)
        }
        .listCard(accentLeading: true)
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }

    private var cellBody: some View {
        HStack(spacing: 14) {
            RecipePlateIllustration(accentIndex: recipe.accentIndex)
                .frame(width: 64, height: 64)
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                HStack(spacing: 6) {
                    MetaChip(iconName: "clock", text: "\(recipe.cookingTimeMinutes) min")
                    MetaChip(iconName: "tag", text: recipe.category)
                    if recipe.isUserCreated {
                        MetaChip(iconName: "person.fill", text: "Yours", highlighted: true)
                    }
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.trailing, 4)
        }
        .padding(14)
    }
}

// MARK: - Grocery

struct GroceryListCell: View {
    let item: GroceryItem
    let displayQuantity: String
    let isPulsing: Bool
    var isCompleted: Bool = false
    let onComplete: (() -> Void)?

    var body: some View {
        HStack(spacing: 14) {
            Button {
                onComplete?()
            } label: {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.5), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundStyle(Color("AppAccent"))
                    }
                }
            }
            .buttonStyle(.plain)
            .opacity(onComplete == nil ? 0.4 : 1)
            .disabled(onComplete == nil)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.body.bold())
                    .foregroundStyle(isCompleted ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                    .strikethrough(isCompleted)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    MetaChip(iconName: item.category.iconName, text: item.category.rawValue)
                    Text(displayQuantity)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppAccent"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color("AppPrimary").opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .listCard()
        .overlay {
            if isPulsing {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color("AppAccent"), lineWidth: 2)
            }
        }
        .opacity(isCompleted ? 0.65 : 1)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

// MARK: - Timer

struct TimerListCell: View {
    let dishName: String
    let remainingSeconds: Int
    let totalSeconds: Int
    let isPaused: Bool
    let isNew: Bool
    let onTogglePause: () -> Void

    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return min(1, max(0, Double(remainingSeconds) / Double(totalSeconds)))
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color("AppSurface"), lineWidth: 6)
                    .frame(width: 56, height: 56)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        remainingSeconds <= 60 ? Color("AppAccent") : Color("AppPrimary"),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: progress)
                Text(formattedTime(remainingSeconds))
                    .font(.caption.bold().monospacedDigit())
                    .foregroundStyle(Color("AppTextPrimary"))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(dishName)
                    .font(.body.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                MetaChip(
                    iconName: isPaused ? "pause.fill" : "flame.fill",
                    text: isPaused ? "Paused" : "Running",
                    highlighted: !isPaused
                )
            }
            Spacer(minLength: 0)

            Button {
                onTogglePause()
            } label: {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .font(.title3)
                    .foregroundStyle(Color("AppTextPrimary"))
                    .frame(width: 48, height: 48)
                    .background(AppGradients.accentBadge)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Color("AppAccent").opacity(0.4), lineWidth: 1))
            }
        }
        .padding(16)
        .listCard(accentLeading: remainingSeconds <= 60 && !isPaused)
        .scaleEffect(isNew ? 1.02 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isNew)
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }

    private func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return m >= 10 ? "\(m):\(String(format: "%02d", s))" : "\(m):\(String(format: "%02d", s))"
    }
}

struct TimerPresetChip: View {
    let name: String
    let durationText: String
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: "timer")
                    .font(.caption)
                    .foregroundStyle(Color("AppAccent"))
                Text(name)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(durationText)
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minWidth: 88)
            .listCard()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Settings

struct SettingsListCell: View {
    let title: String
    let iconName: String
    var subtitle: String? = nil
    var destructive: Bool = false
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(
                iconName: iconName,
                size: 40,
                filled: !destructive
            )
            .opacity(destructive ? 0.6 : 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(destructive ? .red : Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(14)
        .listCard()
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

struct SettingsToggleCell: View {
    let title: String
    let iconName: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(iconName: iconName, size: 40)
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("AppPrimary"))
        }
        .padding(14)
        .listCard()
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

// MARK: - Achievement

struct AchievementGridCell: View {
    let achievement: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        isUnlocked
                            ? AnyShapeStyle(AppGradients.primaryGlow)
                            : AnyShapeStyle(Color("AppBackground").opacity(0.5))
                    )
                    .frame(width: 52, height: 52)
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.35))
            }
            Text(achievement.title)
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(achievement.description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
            if isUnlocked {
                MetaChip(iconName: "checkmark.seal.fill", text: "Unlocked", highlighted: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150)
        .elevatedCard()
        .overlay {
            if isUnlocked {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [Color("AppAccent"), Color("AppPrimary")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        }
        .opacity(isUnlocked ? 1 : 0.7)
    }
}

// MARK: - Week Plan

struct WeekPlanMealCell: View {
    let mealType: MealType
    let recipeName: String?
    let recipes: [Recipe]
    let onAssign: (String?) -> Void

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(
                iconName: mealType == .lunch ? "sun.max.fill" : "moon.stars.fill",
                size: 40
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(mealType.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                Text(recipeName ?? "Tap to assign a recipe")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(recipeName == nil ? Color("AppTextSecondary") : Color("AppTextPrimary"))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            Menu {
                Button("Clear slot") { onAssign(nil) }
                ForEach(recipes) { recipe in
                    Button(recipe.name) { onAssign(recipe.id) }
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color("AppPrimary"))
                    .frame(width: 44, height: 44)
            }
        }
        .padding(12)
        .listCard()
    }
}

// MARK: - Template

struct TemplateListCell: View {
    let name: String
    let itemCount: Int

    var body: some View {
        HStack(spacing: 14) {
            IconBadge(iconName: "list.bullet.rectangle.portrait.fill", size: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("\(itemCount) items ready to add")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            Image(systemName: "arrow.right.circle.fill")
                .font(.title2)
                .foregroundStyle(Color("AppPrimary"))
        }
        .padding(14)
        .listCard()
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}

// MARK: - Detail rows

struct IngredientRowCell: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color("AppAccent"))
                .frame(width: 8, height: 8)
            Text(text)
                .font(.body)
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct StepRowCell: View {
    let index: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(index)")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .frame(width: 28, height: 28)
                .background(AppGradients.accentBadge)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Color("AppAccent").opacity(0.35), lineWidth: 1))
            Text(text)
                .font(.body)
                .foregroundStyle(Color("AppTextPrimary"))
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
    }
}
