import NaviStack
import SwiftUI

/// Fourth tab: the user's saved meals, read reactively from the SwiftData-backed
/// ``FavoritesStore``. Swipe to remove.
struct FavoritesScreen: View {
	@Environment(FavoritesStore.self) private var favorites
	@EnvironmentObject private var router: AppRouter

	var body: some View {
		content
			.navigationTitle("Favourites")
			.toolbar {
				if !favorites.favorites.isEmpty {
					ToolbarItem(placement: .topBarTrailing) {
						EditButton()
					}
				}
			}
	}

	@ViewBuilder
	private var content: some View {
		if favorites.favorites.isEmpty {
			ContentUnavailableView(
				"No Favourites Yet",
				systemImage: "heart",
				description: Text("Tap the heart on any recipe to save it here.")
			)
		} else {
			favoritesList
		}
	}

	private var favoritesList: some View {
		List {
			ForEach(favorites.favorites) { meal in
				Button {
					router.push(.mealDetail(id: meal.id, name: meal.name))
				} label: {
					FavoriteRow(meal: meal)
				}
				.buttonStyle(.plain)
			}
			.onDelete(perform: removeFavorites)
		}
	}

	private func removeFavorites(at offsets: IndexSet) {
		for index in offsets {
			try? favorites.remove(id: favorites.favorites[index].id)
		}
	}
}

private struct FavoriteRow: View {
	let meal: MealSummary

	var body: some View {
		HStack(spacing: AppTheme.Spacing.medium) {
			RemoteImage(url: meal.thumbnailURL)
				.frame(width: 56, height: 56)
				.clipShape(.rect(cornerRadius: AppTheme.Radius.small))

			Text(meal.name)
				.font(.headline)
				.foregroundStyle(.primary)

			Spacer()
		}
		.contentShape(.rect)
	}
}
