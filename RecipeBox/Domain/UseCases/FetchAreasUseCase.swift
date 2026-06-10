/// Loads every culinary area for the Areas screen.
struct FetchAreasUseCase {
	let repository: any MealRepository

	func execute() async throws -> [Area] {
		try await repository.fetchAreas()
	}
}
