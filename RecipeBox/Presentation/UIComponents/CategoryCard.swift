import SwiftUI

/// Glass card showing a category's artwork and name on the Discover grid.
struct CategoryCard: View {
	let category: MealCategory

	var body: some View {
		VStack(spacing: AppTheme.Spacing.small) {
			RemoteImage(url: category.thumbnailURL, contentMode: .fit)
				.frame(height: 64)

			Text(category.name)
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(.primary)
		}
		.frame(maxWidth: .infinity)
		.padding(AppTheme.Spacing.medium)
		.glassCard(cornerRadius: AppTheme.Radius.medium)
		.contentShape(.rect)
	}
}

#Preview {
	CategoryCard(category: MealCategory(id: "1", name: "Beef", thumbnailURL: nil, description: ""))
		.frame(width: 180)
		.padding()
}
