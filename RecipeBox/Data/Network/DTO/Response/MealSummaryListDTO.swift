import Foundation

/// `/filter.php` (by category or area) returns lightweight meal summaries.
/// `meals` is `null` when the filter matches nothing.
struct MealSummaryListDTO: Decodable {
	let meals: [MealSummaryDTO]?
}

struct MealSummaryDTO: Decodable {
	let idMeal: String
	let strMeal: String
	let strMealThumb: String?
}
