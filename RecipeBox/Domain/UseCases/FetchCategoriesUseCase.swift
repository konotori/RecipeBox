/// Loads every meal category for the Discover screen.
struct FetchCategoriesUseCase {
	let repository: any MealRepository

	func execute() async throws -> [MealCategory] {
		try await repository.fetchCategories()
	}
}
