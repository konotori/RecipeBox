import RESTKit

/// Network-backed ``MealRepository``. Maps DTOs to domain models and translates
/// RESTKit's `APIError` into domain-friendly ``MealError`` so the UI never sees
/// a transport error. `Sendable` — it only holds a `Sendable` `MealAPI`.
struct MealRepositoryImpl: MealRepository {
	let api: any MealAPI

	func fetchCategories() async throws -> [MealCategory] {
		try await mapped {
			try await api.categories().categories.map(CategoryMapper.map)
		}
	}

	func fetchMeals(inCategory category: String) async throws -> [MealSummary] {
		try await mapped {
			try await (api.meals(inCategory: category).meals ?? []).map(MealMapper.map)
		}
	}

	func fetchMeals(inArea area: String) async throws -> [MealSummary] {
		try await mapped {
			try await (api.meals(inArea: area).meals ?? []).map(MealMapper.map)
		}
	}

	func fetchAreas() async throws -> [Area] {
		try await mapped {
			// TheMealDB's area list contains ~195 demonyms, most without any
			// recipes. Surface only the curated cuisines that actually have
			// content (and a flag), sorted by name.
			try await (api.areas().meals ?? [])
				.map(AreaMapper.map)
				.filter { CuisineCatalog.isSupported($0.name) }
				.sorted { $0.name < $1.name }
		}
	}

	func searchMeals(name: String) async throws -> [Meal] {
		try await mapped {
			try await (api.search(name: name).meals ?? []).map(MealMapper.map)
		}
	}

	func mealDetail(id: String) async throws -> Meal {
		try await mapped {
			guard let dto = try await api.mealDetail(id: id).meals?.first else {
				throw MealError.notFound
			}
			return MealMapper.map(dto)
		}
	}

	func randomMeal() async throws -> Meal {
		try await mapped {
			guard let dto = try await api.randomMeal().meals?.first else {
				throw MealError.notFound
			}
			return MealMapper.map(dto)
		}
	}

	/// Runs `work`, translating transport failures into ``MealError`` while
	/// letting task cancellation and already-domain errors pass through.
	private func mapped<T>(_ work: () async throws -> T) async throws -> T {
		do {
			return try await work()
		} catch let error as MealError {
			throw error
		} catch is CancellationError {
			throw CancellationError()
		} catch let error as APIError {
			throw Self.domainError(for: error)
		} catch {
			throw MealError.unknown
		}
	}

	private static func domainError(for error: APIError) -> MealError {
		switch error {
		case .requestFailed,
		     .invalidURL,
		     .invalidResponse:
			.offline
		case let .clientError(statusCode, _) where statusCode == 404:
			.notFound
		case .serverError,
		     .redirectionError,
		     .unexpectedStatusCode:
			.server
		case .clientError,
		     .decodingFailed,
		     .encodingFailed,
		     .custom:
			.unknown
		}
	}
}
