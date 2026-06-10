import RESTKit

/// Shared configuration for every TheMealDB endpoint: the per-environment base
/// URL and the (always `GET`) method. Each endpoint only declares its `path`,
/// query, and decoded `Response` type.
protocol MealDBEndpoint: Endpoint {}

extension MealDBEndpoint {
	var baseURL: String {
		AppEnvironment.current.baseURL
	}
	var method: HTTPMethod {
		.get
	}
}

struct CategoriesEndpoint: MealDBEndpoint {
	typealias Response = JSON<CategoriesResponseDTO>

	var path: String {
		"/categories.php"
	}
}

struct MealsByCategoryEndpoint: MealDBEndpoint {
	typealias Response = JSON<MealSummaryListDTO>

	let category: String

	var path: String {
		"/filter.php"
	}
	var queryParameters: [String: any Sendable]? {
		["c": category]
	}
}

struct MealsByAreaEndpoint: MealDBEndpoint {
	typealias Response = JSON<MealSummaryListDTO>

	let area: String

	var path: String {
		"/filter.php"
	}
	var queryParameters: [String: any Sendable]? {
		["a": area]
	}
}

struct AreasEndpoint: MealDBEndpoint {
	typealias Response = JSON<AreaListDTO>

	var path: String {
		"/list.php"
	}
	var queryParameters: [String: any Sendable]? {
		["a": "list"]
	}
}

struct SearchMealsEndpoint: MealDBEndpoint {
	typealias Response = JSON<MealDetailListDTO>

	let name: String

	var path: String {
		"/search.php"
	}
	var queryParameters: [String: any Sendable]? {
		["s": name]
	}
}

struct MealDetailEndpoint: MealDBEndpoint {
	typealias Response = JSON<MealDetailListDTO>

	let mealID: String

	var path: String {
		"/lookup.php"
	}
	var queryParameters: [String: any Sendable]? {
		["i": mealID]
	}
}

struct RandomMealEndpoint: MealDBEndpoint {
	typealias Response = JSON<MealDetailListDTO>

	var path: String {
		"/random.php"
	}
}
