import SwiftUI

/// Small rounded pill for a meal tag.
struct TagChip: View {
	let text: String

	var body: some View {
		Text(text)
			.font(.caption.weight(.medium))
			.padding(.horizontal, AppTheme.Spacing.medium)
			.padding(.vertical, AppTheme.Spacing.xSmall)
			.background(AppTheme.Colors.accent.opacity(0.15), in: .capsule)
			.foregroundStyle(AppTheme.Colors.accent)
	}
}

#Preview {
	HStack {
		TagChip(text: "Vegetarian")
		TagChip(text: "Spicy")
	}
	.padding()
}
