import SwiftUI

// MARK: - Section & Search

struct SectionHeaderView: View {
    let title: String
    let iconName: String?
    var trailing: String?

    var body: some View {
        HStack(spacing: 10) {
            if let iconName {
                Image(systemName: iconName)
                    .font(.subheadline.bold())
                    .foregroundStyle(Color("AppAccent"))
                    .frame(width: 30, height: 30)
                    .background(AppGradients.primaryGlow)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(Color("AppAccent").opacity(0.25), lineWidth: 1)
                    )
            }
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color("AppBackground").opacity(0.45))
                            .overlay(
                                Capsule()
                                    .strokeBorder(Color("AppTextPrimary").opacity(0.08), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 6)
    }
}

struct AppSearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.body.weight(.semibold))
                .foregroundStyle(Color("AppAccent"))
            TextField(placeholder, text: $text)
                .foregroundStyle(Color("AppTextPrimary"))
            if !text.isEmpty {
                Button {
                    text = ""
                    FeedbackService.lightTap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .listCard()
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

struct ToolbarIconButton: View {
    let iconName: String
    var isActive: Bool = false
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            Image(systemName: iconName)
                .font(.body.weight(.semibold))
                .foregroundStyle(isActive ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .frame(width: 40, height: 40)
                .background(
                    Group {
                        if isActive {
                            AppGradients.primary
                        } else {
                            AppGradients.surface
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(
                            isActive ? Color("AppAccent").opacity(0.45) : Color("AppTextPrimary").opacity(0.08),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

struct MetaChip: View {
    let iconName: String
    let text: String
    var highlighted: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption2)
            Text(text)
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .foregroundStyle(highlighted ? Color("AppTextPrimary") : Color("AppTextSecondary"))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Group {
                if highlighted {
                    AppGradients.primaryGlow
                } else {
                    Color("AppBackground").opacity(0.4)
                }
            }
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(
                    highlighted ? Color("AppAccent").opacity(0.35) : Color("AppTextPrimary").opacity(0.06),
                    lineWidth: 1
                )
        )
    }
}

struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackService.lightTap()
            action()
        } label: {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? AnyShapeStyle(AppGradients.primary) : AnyShapeStyle(AppGradients.surface))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isSelected ? Color("AppAccent").opacity(0.5) : Color("AppTextPrimary").opacity(0.08),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

struct IconBadge: View {
    let iconName: String
    var size: CGFloat = 44
    var filled: Bool = true

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(filled ? Color("AppTextPrimary") : Color("AppAccent"))
            .frame(width: size, height: size)
            .background(filled ? AnyShapeStyle(AppGradients.accentBadge) : AnyShapeStyle(AppGradients.surface))
            .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .strokeBorder(AppGradients.surfaceStroke, lineWidth: 1)
            )
    }
}

struct KitchenSegmentedControl: View {
    @Binding var selection: KitchenSection

    var body: some View {
        HStack(spacing: 8) {
            ForEach(KitchenSection.allCases) { section in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selection = section
                    }
                    FeedbackService.lightTap()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: section.iconName)
                            .font(.subheadline.bold())
                        Text(section.rawValue)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(selection == section ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .background(
                        Group {
                            if selection == section {
                                AppGradients.primary
                            } else {
                                Color.clear
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(
                                selection == section ? Color("AppAccent").opacity(0.55) : Color.clear,
                                lineWidth: 1.5
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppGradients.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color("AppTextPrimary").opacity(0.08), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

struct StatPill: View {
    let iconName: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(Color("AppAccent"))
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppGradients.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppGradients.surfaceHighlight)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color("AppTextPrimary").opacity(0.08), lineWidth: 1)
        )
    }
}

struct DetailSectionCard<Content: View>: View {
    let title: String
    let iconName: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                IconBadge(iconName: iconName, size: 36)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            content()
        }
        .padding(16)
        .elevatedCard(accentLeading: true)
    }
}
