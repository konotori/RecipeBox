import Foundation
import Testing
@testable import RecipeBox

@Suite("MealMapper")
struct MealMapperTests {
	/// Decodes a realistic TheMealDB detail payload, then maps it — exercising
	/// the flat `strIngredientN`/`strMeasureN` zipping, blank dropping, tag
	/// splitting, and URL parsing in one pass.
	@Test
	func mapsDetailZippingIngredientsAndDroppingBlanks() throws {
		let json = """
			{"meals":[{
			  "idMeal":"52772","strMeal":"Teriyaki Chicken","strCategory":"Chicken",
			  "strArea":"Japanese","strInstructions":"Step one.\\r\\nStep two.",
			  "strMealThumb":"https://img/teriyaki.jpg","strTags":"Meat, Casserole",
			  "strYoutube":"https://www.youtube.com/watch?v=abc","strSource":"https://example.com/recipe",
			  "strIngredient1":"soy sauce","strIngredient2":"   ","strIngredient3":"chicken",
			  "strMeasure1":"1/2 cup","strMeasure2":"1 tbsp","strMeasure3":""
			}]}
			"""
		let dto = try JSONDecoder().decode(MealDetailListDTO.self, from: Data(json.utf8))
		let detail = try #require(dto.meals?.first)

		let meal = MealMapper.map(detail)

		#expect(meal.id == "52772")
		#expect(meal.ingredients.count == 3) // blank ingredient #2 dropped
		#expect(meal.ingredients.first == Ingredient(name: "soy sauce", measure: "1/2 cup"))
		#expect(meal.ingredients.last == Ingredient(name: "chicken", measure: "")) // blank measure -> ""
		#expect(meal.tags == ["Meat", "Casserole"])
		#expect(meal.youtubeURL?.absoluteString == "https://www.youtube.com/watch?v=abc")
		#expect(meal.sourceURL != nil)
	}

	@Test
	func handlesMissingOptionalFields() throws {
		let json = """
			{"meals":[{"idMeal":"1","strMeal":"Plain"}]}
			"""
		let dto = try JSONDecoder().decode(MealDetailListDTO.self, from: Data(json.utf8))
		let detail = try #require(dto.meals?.first)

		let meal = MealMapper.map(detail)

		#expect(meal.category.isEmpty)
		#expect(meal.area.isEmpty)
		#expect(meal.tags.isEmpty)
		#expect(meal.ingredients.isEmpty)
		#expect(meal.youtubeURL == nil)
		#expect(meal.sourceURL == nil)
	}

	@Test
	func decodesNullMealsAsNil() throws {
		let dto = try JSONDecoder().decode(MealDetailListDTO.self, from: Data(#"{"meals":null}"#.utf8))
		#expect(dto.meals == nil)
	}

	@Test
	func mapsSummary() {
		let dto = MealSummaryDTO(idMeal: "9", strMeal: "Soup", strMealThumb: "https://img/s.jpg")
		let summary = MealMapper.map(dto)
		#expect(summary.id == "9")
		#expect(summary.name == "Soup")
		#expect(summary.thumbnailURL?.absoluteString == "https://img/s.jpg")
	}
}
