import RESTKit

/// Thin, typed wrapper over the TheMealDB endpoints. Returns DTOs; mapping to
/// domain models happens in the repository.
protocol MealAPI: Sendable {
	func categories() async throws -> CategoriesResponseDTO
	func meals(inCategory category: String) async throws -> MealSummaryListDTO
	func meals(inArea area: String) async throws -> MealSummaryListDTO
	func areas() async throws -> AreaListDTO
	func search(name: String) async throws -> MealDetailListDTO
	func mealDetail(id: String) async throws -> MealDetailListDTO
	func randomMeal() async throws -> MealDetailListDTO
}

struct RestMealAPI: MealAPI {
	let client: any APIClientProtocol

	func categories() async throws -> CategoriesResponseDTO {
		try await client.request(CategoriesEndpoint())
	}

	func meals(inCategory category: String) async throws -> MealSummaryListDTO {
		try await client.request(MealsByCategoryEndpoint(category: category))
	}

	func meals(inArea area: String) async throws -> MealSummaryListDTO {
		try await client.request(MealsByAreaEndpoint(area: area))
	}

	func areas() async throws -> AreaListDTO {
		try await client.request(AreasEndpoint())
	}

	func search(name: String) async throws -> MealDetailListDTO {
		try await client.request(SearchMealsEndpoint(name: name))
	}

	func mealDetail(id: String) async throws -> MealDetailListDTO {
		try await client.request(MealDetailEndpoint(mealID: id))
	}

	func randomMeal() async throws -> MealDetailListDTO {
		try await client.request(RandomMealEndpoint())
	}
}
