import Foundation

/// Domain-friendly failures surfaced by the repositories.
///
/// Per the project conventions, the Data layer maps raw transport/database
/// errors (e.g. `URLError`, `APIError`) into these so the UI never sees a
/// framework-specific error.
enum MealError: Error, Equatable, LocalizedError {
	case notFound
	case offline
	case server
	case persistence
	case unknown

	var errorDescription: String? {
		switch self {
		case .notFound: String(localized: "We couldn't find that recipe.")
		case .offline: String(localized: "You appear to be offline. Check your connection and try again.")
		case .server: String(localized: "The kitchen is busy right now. Please try again later.")
		case .persistence: String(localized: "Couldn't update your favourites. Please try again.")
		case .unknown: String(localized: "Something went wrong. Please try again.")
		}
	}
}
