import Foundation

enum MealMapper {
	static func map(_ dto: MealSummaryDTO) -> MealSummary {
		MealSummary(
			id: dto.idMeal,
			name: dto.strMeal,
			thumbnailURL: dto.strMealThumb.flatMap { URL(string: $0) }
		)
	}

	static func map(_ dto: MealDetailDTO) -> Meal {
		Meal(
			id: dto.idMeal,
			name: dto.strMeal,
			category: dto.strCategory?.nilIfBlank ?? "",
			area: dto.strArea?.nilIfBlank ?? "",
			instructions: dto.strInstructions?.nilIfBlank ?? "",
			thumbnailURL: dto.strMealThumb.flatMap { URL(string: $0) },
			youtubeURL: dto.strYoutube?.nilIfBlank.flatMap { URL(string: $0) },
			sourceURL: dto.strSource?.nilIfBlank.flatMap { URL(string: $0) },
			tags: parseTags(dto.strTags),
			ingredients: parseIngredients(dto)
		)
	}

	private static func parseTags(_ raw: String?) -> [String] {
		guard let raw = raw?.nilIfBlank else {
			return []
		}
		return raw.split(separator: ",")
			.map { $0.trimmingCharacters(in: .whitespaces) }
			.filter { !$0.isEmpty }
	}

	/// Zips the 20 parallel ingredient/measure slots, dropping blank ingredients.
	private static func parseIngredients(_ dto: MealDetailDTO) -> [Ingredient] {
		let names = dto.ingredients
		let measures = dto.measures
		return names.indices.compactMap { index -> Ingredient? in
			guard let name = names[index]?.nilIfBlank else {
				return nil
			}
			let measure = (measures[safe: index] ?? nil)?.nilIfBlank ?? ""
			return Ingredient(name: name, measure: measure)
		}
	}
}
