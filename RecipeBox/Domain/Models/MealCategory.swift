import Foundation

/// A meal category (Beef, Chicken, Seafood, …) as shown on the Discover screen.
struct MealCategory: Identifiable, Equatable, Hashable {
	let id: String
	let name: String
	let thumbnailURL: URL?
	let description: String
}
