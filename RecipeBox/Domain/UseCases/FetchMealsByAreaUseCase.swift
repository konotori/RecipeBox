/// Loads the meals that belong to a given culinary area.
struct FetchMealsByAreaUseCase {
	let repository: any MealRepository

	func execute(area: Area) async throws -> [MealSummary] {
		try await repository.fetchMeals(inArea: area.name)
	}
}
