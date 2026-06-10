import Foundation
import LogPipe
import RESTKit
import SwiftData

/// Composition root — the only place that knows concrete implementations.
/// Builds the dependency graph once and hands view models to the Presentation
/// layer through factory methods. `@Observable` so it can live in the SwiftUI
/// environment; `@MainActor` because it owns the SwiftData stack.
@MainActor
@Observable
final class AppContainer {
	/// Shared logger; also handed to the navigation interceptor.
	let logger: Logger

	/// SwiftData stack + reactive favourites store (surfaced to the UI).
	let modelContainer: ModelContainer
	let favoritesStore: FavoritesStore

	private let fetchCategoriesUseCase: FetchCategoriesUseCase
	private let fetchMealsByCategoryUseCase: FetchMealsByCategoryUseCase
	private let fetchMealsByAreaUseCase: FetchMealsByAreaUseCase
	private let fetchAreasUseCase: FetchAreasUseCase
	private let searchMealsUseCase: SearchMealsUseCase
	private let fetchMealDetailUseCase: FetchMealDetailUseCase
	private let fetchRandomMealUseCase: FetchRandomMealUseCase
	private let toggleFavoriteUseCase: ToggleFavoriteUseCase

	init() {
		let environment = AppEnvironment.current

		let logger = Logger(config: LoggerConfiguration(minLevel: AppContainer.logLevel(for: environment.logVerbosity)))
		self.logger = logger
		logger.info("Launching \(environment.displayName) build", tags: ["app"])

		let client = APIClient(interceptors: [LoggingInterceptor(logger: logger)])
		let repository = MealRepositoryImpl(api: RestMealAPI(client: client))

		let container = AppContainer.makeModelContainer(logger: logger)
		modelContainer = container
		let store = FavoritesStore(context: container.mainContext)
		favoritesStore = store

		fetchCategoriesUseCase = FetchCategoriesUseCase(repository: repository)
		fetchMealsByCategoryUseCase = FetchMealsByCategoryUseCase(repository: repository)
		fetchMealsByAreaUseCase = FetchMealsByAreaUseCase(repository: repository)
		fetchAreasUseCase = FetchAreasUseCase(repository: repository)
		searchMealsUseCase = SearchMealsUseCase(repository: repository)
		fetchMealDetailUseCase = FetchMealDetailUseCase(repository: repository)
		fetchRandomMealUseCase = FetchRandomMealUseCase(repository: repository)
		toggleFavoriteUseCase = ToggleFavoriteUseCase(repository: store)
	}

	// MARK: - View model factories

	func makeDiscoverViewModel() -> DiscoverViewModel {
		DiscoverViewModel(fetchCategories: fetchCategoriesUseCase, fetchRandomMeal: fetchRandomMealUseCase)
	}

	func makeAreasViewModel() -> AreasViewModel {
		AreasViewModel(fetchAreas: fetchAreasUseCase)
	}

	func makeSearchViewModel() -> SearchViewModel {
		SearchViewModel(searchMeals: searchMealsUseCase)
	}

	func makeCategoryMealsViewModel(category: MealCategory) -> MealListViewModel {
		let useCase = fetchMealsByCategoryUseCase
		return MealListViewModel(title: category.name) {
			try await useCase.execute(category: category)
		}
	}

	func makeAreaMealsViewModel(area: Area) -> MealListViewModel {
		let useCase = fetchMealsByAreaUseCase
		return MealListViewModel(title: area.name) {
			try await useCase.execute(area: area)
		}
	}

	func makeMealDetailViewModel(id: String, name: String) -> MealDetailViewModel {
		MealDetailViewModel(
			mealID: id,
			mealName: name,
			fetchDetail: fetchMealDetailUseCase,
			toggleFavoriteUseCase: toggleFavoriteUseCase,
			favorites: favoritesStore
		)
	}

	// MARK: - Setup helpers

	private static func logLevel(for verbosity: LogVerbosity) -> LogLevel {
		switch verbosity {
		case .debug: .debug
		case .info: .info
		case .warning: .warn
		}
	}

	/// Builds the SwiftData container, degrading to an in-memory store if the
	/// on-disk store can't be opened so the app still launches.
	private static func makeModelContainer(logger: Logger) -> ModelContainer {
		do {
			return try ModelContainer(for: FavoriteMealEntity.self)
		} catch {
			logger.error("Persistent store failed; using in-memory store", error: error, tags: ["app"])
		}
		do {
			let config = ModelConfiguration(isStoredInMemoryOnly: true)
			return try ModelContainer(for: FavoriteMealEntity.self, configurations: config)
		} catch {
			fatalError("Unable to create a SwiftData container: \(error)")
		}
	}
}
