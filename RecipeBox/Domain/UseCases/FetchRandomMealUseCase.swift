/// Loads a single random meal — the Discover screen's "Meal of the day".
struct FetchRandomMealUseCase {
	let repository: any MealRepository

	func execute() async throws -> Meal {
		try await repository.randomMeal()
	}
}
