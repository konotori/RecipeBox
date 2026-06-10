import Foundation

/// A meal summary as returned by category/area/search list endpoints.
struct MealSummary: Identifiable, Equatable, Hashable {
	let id: String
	let name: String
	let thumbnailURL: URL?
}

/// A fully detailed meal (lookup / random endpoints).
struct Meal: Identifiable, Equatable, Hashable {
	let id: String
	let name: String
	let category: String
	let area: String
	let instructions: String
	let thumbnailURL: URL?
	let youtubeURL: URL?
	let sourceURL: URL?
	let tags: [String]
	let ingredients: [Ingredient]

	var summary: MealSummary {
		MealSummary(id: id, name: name, thumbnailURL: thumbnailURL)
	}
}

/// One ingredient line of a meal (name + measure).
struct Ingredient: Identifiable, Equatable, Hashable {
	var id: String {
		name
	}
	let name: String
	let measure: String
}
