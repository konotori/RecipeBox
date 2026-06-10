import SwiftUI

/// Square artwork + name card for a meal summary, used in grids and lists.
struct MealCard: View {
	let meal: MealSummary

	var body: some View {
		VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
			RemoteImage(url: meal.thumbnailURL)
				.aspectRatio(1, contentMode: .fill)
				.frame(maxWidth: .infinity)
				.clipShape(.rect(cornerRadius: AppTheme.Radius.medium))

			Text(meal.name)
				.font(AppTheme.Typography.cardTitle)
				.lineLimit(2)
				.multilineTextAlignment(.leading)
				.foregroundStyle(.primary)
		}
		.contentShape(.rect)
	}
}

#Preview {
	MealCard(meal: MealSummary(id: "1", name: "Spaghetti Carbonara", thumbnailURL: nil))
		.frame(width: 180)
		.padding()
}
