/// Loads the meals that belong to a given category.
struct FetchMealsByCategoryUseCase {
	let repository: any MealRepository

	func execute(category: MealCategory) async throws -> [MealSummary] {
		try await repository.fetchMeals(inCategory: category.name)
	}
}
