import SwiftUI

/// Heart toggle with an animated SF Symbol. Dumb component — the owning screen
/// supplies the favourite state and the toggle action.
struct FavoriteButton: View {
	let isFavorite: Bool
	let toggle: () -> Void

	var body: some View {
		Button(action: toggle) {
			Image(systemName: isFavorite ? "heart.fill" : "heart")
				.symbolEffect(.bounce, value: isFavorite)
				.foregroundStyle(isFavorite ? AnyShapeStyle(.red) : AnyShapeStyle(.primary))
		}
		.accessibilityLabel(isFavorite ? "Remove from favourites" : "Add to favourites")
		.sensoryFeedback(.impact, trigger: isFavorite)
	}
}
