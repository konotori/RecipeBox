/// Loads the fully detailed meal for an identifier.
struct FetchMealDetailUseCase {
	let repository: any MealRepository

	func execute(id: String) async throws -> Meal {
		try await repository.mealDetail(id: id)
	}
}
