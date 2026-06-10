import Foundation
import SwiftData
import Testing
@testable import RecipeBox

@MainActor
@Suite("FavoritesStore", .serialized)
struct FavoritesStoreTests {
	/// One container per process. SwiftData traps (EXC_BAD_INSTRUCTION) when
	/// several `ModelContainer`s are created for the same `@Model` type in one
	/// test process, so the suite shares a single in-memory container and
	/// resets its data before each test (the suite is `.serialized`).
	static let container: ModelContainer = {
		let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
		do {
			return try ModelContainer(for: FavoriteMealEntity.self, configurations: configuration)
		} catch {
			fatalError("Failed to create the in-memory test container: \(error)")
		}
	}()

	init() throws {
		let context = ModelContext(Self.container)
		try context.delete(model: FavoriteMealEntity.self)
		try context.save()
	}

	private func makeStore() -> FavoritesStore {
		FavoritesStore(context: ModelContext(Self.container))
	}

	@Test
	func startsEmpty() {
		let store = makeStore()
		#expect(store.favorites.isEmpty)
		#expect(store.contains(id: "52772") == false)
	}

	@Test
	func addPersistsAndMarksFavorite() throws {
		let store = makeStore()
		try store.add(Fixture.meal())
		#expect(store.contains(id: "52772"))
		#expect(store.favorites.count == 1)
		#expect(store.favorites.first?.name == "Teriyaki Chicken")
	}

	@Test
	func addIsIdempotent() throws {
		let store = makeStore()
		try store.add(Fixture.meal())
		try store.add(Fixture.meal())
		#expect(store.favorites.count == 1)
	}

	@Test
	func removeDeletesFavorite() throws {
		let store = makeStore()
		try store.add(Fixture.meal())
		try store.remove(id: "52772")
		#expect(store.favorites.isEmpty)
		#expect(store.contains(id: "52772") == false)
	}

	@Test("Favourites are ordered most-recently-added first")
	func mostRecentlyAddedComesFirst() async throws {
		let store = makeStore()
		try store.add(Fixture.meal(id: "1", name: "First"))
		try await Task.sleep(for: .milliseconds(10))
		try store.add(Fixture.meal(id: "2", name: "Second"))
		#expect(store.favorites.map(\.id) == ["2", "1"])
	}

	@Test
	func toggleFavoriteUseCaseAddsThenRemoves() throws {
		let store = makeStore()
		let useCase = ToggleFavoriteUseCase(repository: store)

		try useCase.execute(Fixture.meal())
		#expect(store.contains(id: "52772"))

		try useCase.execute(Fixture.meal())
		#expect(store.contains(id: "52772") == false)
	}
}
