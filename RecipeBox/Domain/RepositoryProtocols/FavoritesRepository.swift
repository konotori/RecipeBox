import Foundation

/// Local persistence of the user's favourite meals.
///
/// `@MainActor` because the only implementation is backed by SwiftData, whose
/// `ModelContext` is not `Sendable`; favourites are always read and mutated
/// from the UI anyway.
@MainActor
protocol FavoritesRepository {
	/// Favourited meals as lightweight summaries, most recently added first.
	func all() -> [MealSummary]

	/// Whether a meal with `id` is currently favourited.
	func contains(id: String) -> Bool

	/// Persists a meal as a favourite. No-op if already present.
	func add(_ meal: Meal) throws

	/// Removes the favourite with `id`. No-op if absent.
	func remove(id: String) throws
}
