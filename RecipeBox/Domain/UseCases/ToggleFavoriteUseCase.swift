/// Adds a meal to favourites if absent, otherwise removes it.
///
/// `@MainActor` to match ``FavoritesRepository`` (SwiftData-backed).
@MainActor
struct ToggleFavoriteUseCase {
	let repository: any FavoritesRepository

	func execute(_ meal: Meal) throws {
		if repository.contains(id: meal.id) {
			try repository.remove(id: meal.id)
		} else {
			try repository.add(meal)
		}
	}
}
