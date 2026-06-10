import Foundation

/// Read-only access to the remote meal catalogue.
///
/// Implemented in the Data layer (`MealRepositoryImpl`) on top of the network
/// API. It is `Sendable` so it can be used from any isolation domain — the
/// concrete implementation wraps a `Sendable` `APIClient`.
protocol MealRepository: Sendable {
	/// All meal categories with their artwork and description.
	func fetchCategories() async throws -> [MealCategory]

	/// Lightweight meal summaries belonging to a category.
	func fetchMeals(inCategory category: String) async throws -> [MealSummary]

	/// Lightweight meal summaries for a culinary area / cuisine.
	func fetchMeals(inArea area: String) async throws -> [MealSummary]

	/// Every culinary area the catalogue knows about.
	func fetchAreas() async throws -> [Area]

	/// Full meals whose name matches `name` (may be empty).
	func searchMeals(name: String) async throws -> [Meal]

	/// The fully detailed meal for an identifier.
	func mealDetail(id: String) async throws -> Meal

	/// A single random, fully detailed meal.
	func randomMeal() async throws -> Meal
}
