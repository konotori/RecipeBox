import Foundation
@testable import RecipeBox

// MARK: - Stubs

/// In-memory `MealRepository` for use-case tests. `Sendable` (matches the
/// protocol): failures are modelled as a `MealError` so no non-Sendable
/// `Error` is stored.
struct StubMealRepository: MealRepository {
	var categories: [MealCategory] = []
	var summaries: [MealSummary] = []
	var areas: [Area] = []
	var searchResults: [Meal] = []
	var detail: Meal?
	var random: Meal?
	var failure: MealError?

	func fetchCategories() async throws -> [MealCategory] {
		try failIfNeeded()
		return categories
	}

	func fetchMeals(inCategory _: String) async throws -> [MealSummary] {
		try failIfNeeded()
		return summaries
	}

	func fetchMeals(inArea _: String) async throws -> [MealSummary] {
		try failIfNeeded()
		return summaries
	}

	func fetchAreas() async throws -> [Area] {
		try failIfNeeded()
		return areas
	}

	func searchMeals(name _: String) async throws -> [Meal] {
		try failIfNeeded()
		return searchResults
	}

	func mealDetail(id _: String) async throws -> Meal {
		try failIfNeeded()
		if let detail {
			return detail
		}
		throw MealError.notFound
	}

	func randomMeal() async throws -> Meal {
		try failIfNeeded()
		if let random {
			return random
		}
		throw MealError.notFound
	}

	private func failIfNeeded() throws {
		if let failure {
			throw failure
		}
	}
}

/// Stub network layer. The throwing behaviour is injected as a `@Sendable`
/// closure so a test can throw any error (including `APIError`) without this
/// type importing RESTKit.
struct StubMealAPI: MealAPI {
	var onRequest: @Sendable () throws -> Void = {}
	var categoriesDTO = CategoriesResponseDTO(categories: [])
	var summaryList = MealSummaryListDTO(meals: nil)
	var detailList = MealDetailListDTO(meals: nil)
	var areaList = AreaListDTO(meals: nil)

	func categories() async throws -> CategoriesResponseDTO {
		try onRequest()
		return categoriesDTO
	}

	func meals(inCategory _: String) async throws -> MealSummaryListDTO {
		try onRequest()
		return summaryList
	}

	func meals(inArea _: String) async throws -> MealSummaryListDTO {
		try onRequest()
		return summaryList
	}

	func areas() async throws -> AreaListDTO {
		try onRequest()
		return areaList
	}

	func search(name _: String) async throws -> MealDetailListDTO {
		try onRequest()
		return detailList
	}

	func mealDetail(id _: String) async throws -> MealDetailListDTO {
		try onRequest()
		return detailList
	}

	func randomMeal() async throws -> MealDetailListDTO {
		try onRequest()
		return detailList
	}
}

// MARK: - Fixtures

enum Fixture {
	static let category = MealCategory(
		id: "1",
		name: "Beef",
		thumbnailURL: URL(string: "https://img/beef.png"),
		description: "Beef dishes"
	)

	static let summary = MealSummary(id: "52772", name: "Teriyaki Chicken", thumbnailURL: nil)

	static let area = Area(name: "Japanese")

	static func meal(id: String = "52772", name: String = "Teriyaki Chicken") -> Meal {
		Meal(
			id: id,
			name: name,
			category: "Chicken",
			area: "Japanese",
			instructions: "Step one.\r\nStep two.",
			thumbnailURL: URL(string: "https://img/teriyaki.jpg"),
			youtubeURL: nil,
			sourceURL: nil,
			tags: ["Meat"],
			ingredients: [Ingredient(name: "soy sauce", measure: "1 cup")]
		)
	}
}
