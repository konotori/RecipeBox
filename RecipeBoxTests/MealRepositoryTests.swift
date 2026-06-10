import Foundation
import Testing
@testable import RecipeBox

@Suite("MealRepositoryImpl")
struct MealRepositoryTests {
	@Test
	func nullMealsMapToEmptyForLists() async throws {
		let api = StubMealAPI(summaryList: MealSummaryListDTO(meals: nil))
		let repository = MealRepositoryImpl(api: api)
		let result = try await repository.fetchMeals(inCategory: "Beef")
		#expect(result.isEmpty)
	}

	@Test
	func nullMealsThrowNotFoundForDetail() async {
		let api = StubMealAPI(detailList: MealDetailListDTO(meals: nil))
		let repository = MealRepositoryImpl(api: api)
		await #expect(throws: MealError.notFound) {
			try await repository.mealDetail(id: "missing")
		}
	}

	@Test
	func nullMealsThrowNotFoundForRandom() async {
		let api = StubMealAPI(detailList: MealDetailListDTO(meals: nil))
		let repository = MealRepositoryImpl(api: api)
		await #expect(throws: MealError.notFound) {
			try await repository.randomMeal()
		}
	}

	@Test("Task cancellation is re-thrown, not swallowed as a domain error")
	func cancellationPropagates() async {
		let api = StubMealAPI(onRequest: { throw CancellationError() })
		let repository = MealRepositoryImpl(api: api)
		await #expect(throws: CancellationError.self) {
			try await repository.fetchCategories()
		}
	}

	@Test
	func unknownTransportErrorsBecomeMealErrorUnknown() async {
		struct Boom: Error {}
		let api = StubMealAPI(onRequest: { throw Boom() })
		let repository = MealRepositoryImpl(api: api)
		await #expect(throws: MealError.unknown) {
			try await repository.fetchCategories()
		}
	}

	@Test("Areas are filtered to supported cuisines and sorted")
	func fetchAreasFiltersToSupportedCuisines() async throws {
		let api = StubMealAPI(areaList: AreaListDTO(meals: [
			AreaDTO(strArea: "Japanese"),
			AreaDTO(strArea: "Andorran"), // no content / no flag → dropped
			AreaDTO(strArea: "Italian"),
			AreaDTO(strArea: "Beninese") // dropped
		]))
		let repository = MealRepositoryImpl(api: api)

		let areas = try await repository.fetchAreas()

		#expect(areas.map(\.name) == ["Italian", "Japanese"])
	}

	@Test
	func mapsCategoriesSuccessfully() async throws {
		let dto = CategoryDTO(
			idCategory: "1",
			strCategory: "Beef",
			strCategoryThumb: "https://img/beef.png",
			strCategoryDescription: "Beef dishes"
		)
		let api = StubMealAPI(categoriesDTO: CategoriesResponseDTO(categories: [dto]))
		let repository = MealRepositoryImpl(api: api)

		let result = try await repository.fetchCategories()

		#expect(result.count == 1)
		#expect(result.first?.name == "Beef")
		#expect(result.first?.thumbnailURL?.absoluteString == "https://img/beef.png")
	}
}
