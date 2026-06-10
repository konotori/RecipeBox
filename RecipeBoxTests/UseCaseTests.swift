import Testing
@testable import RecipeBox

@Suite("Use cases")
struct UseCaseTests {
	@Test
	func fetchCategoriesReturnsRepositoryValue() async throws {
		let repository = StubMealRepository(categories: [Fixture.category])
		let result = try await FetchCategoriesUseCase(repository: repository).execute()
		#expect(result == [Fixture.category])
	}

	@Test
	func fetchMealsByCategoryReturnsSummaries() async throws {
		let repository = StubMealRepository(summaries: [Fixture.summary])
		let result = try await FetchMealsByCategoryUseCase(repository: repository).execute(category: Fixture.category)
		#expect(result == [Fixture.summary])
	}

	@Test
	func fetchMealsByAreaReturnsSummaries() async throws {
		let repository = StubMealRepository(summaries: [Fixture.summary])
		let result = try await FetchMealsByAreaUseCase(repository: repository).execute(area: Fixture.area)
		#expect(result == [Fixture.summary])
	}

	@Test
	func fetchAreasReturnsRepositoryValue() async throws {
		let repository = StubMealRepository(areas: [Fixture.area])
		let result = try await FetchAreasUseCase(repository: repository).execute()
		#expect(result == [Fixture.area])
	}

	@Test
	func fetchMealDetailReturnsRepositoryValue() async throws {
		let repository = StubMealRepository(detail: Fixture.meal())
		let result = try await FetchMealDetailUseCase(repository: repository).execute(id: "52772")
		#expect(result == Fixture.meal())
	}

	@Test
	func fetchRandomMealReturnsRepositoryValue() async throws {
		let repository = StubMealRepository(random: Fixture.meal())
		let result = try await FetchRandomMealUseCase(repository: repository).execute()
		#expect(result == Fixture.meal())
	}

	@Test("Blank search query short-circuits without hitting the repository")
	func searchWithBlankQueryReturnsEmptyWithoutCallingRepository() async throws {
		// If the use case called the repository, this failure would surface.
		let repository = StubMealRepository(searchResults: [Fixture.meal()], failure: .server)
		let result = try await SearchMealsUseCase(repository: repository).execute(query: "   ")
		#expect(result.isEmpty)
	}

	@Test
	func searchWithQueryReturnsResults() async throws {
		let repository = StubMealRepository(searchResults: [Fixture.meal()])
		let result = try await SearchMealsUseCase(repository: repository).execute(query: "teriyaki")
		#expect(result == [Fixture.meal()])
	}

	@Test
	func errorsPropagate() async {
		let repository = StubMealRepository(failure: .offline)
		await #expect(throws: MealError.offline) {
			try await FetchCategoriesUseCase(repository: repository).execute()
		}
	}
}
