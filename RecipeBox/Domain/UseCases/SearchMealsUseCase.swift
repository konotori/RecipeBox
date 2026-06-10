import Foundation

/// Searches meals by name. Returns an empty array for a blank query.
struct SearchMealsUseCase {
	let repository: any MealRepository

	func execute(query: String) async throws -> [Meal] {
		let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else {
			return []
		}
		return try await repository.searchMeals(name: trimmed)
	}
}
