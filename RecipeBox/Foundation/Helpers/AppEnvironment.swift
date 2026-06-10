import Foundation

/// Verbosity hint the App layer maps onto its concrete logging level. Kept
/// framework-free so `Foundation/` stays dependency-light.
enum LogVerbosity {
	case debug
	case info
	case warning
}

/// Runtime configuration resolved per build environment (Dev / Staging / Prod).
///
/// The active case is selected at **compile time** from
/// `SWIFT_ACTIVE_COMPILATION_CONDITIONS` (set in each `Config/<Env>/<Env>.xcconfig`),
/// so a Prod build can never be pointed at a Dev backend by mistake — switch
/// the active environment by switching the Xcode scheme.
enum AppEnvironment {
	case development
	case staging
	case production

	/// The environment the current build was compiled for.
	static let current: AppEnvironment = {
		#if DEV
		return .development
		#elseif STAGING
		return .staging
		#else
		return .production
		#endif
	}()

	/// TheMealDB API key. The public test key (`"1"`) is fine for Dev/Staging;
	/// a production build would carry a licensed key.
	var apiKey: String {
		switch self {
		case .development,
		     .staging: "1"
		case .production: "1"
		}
	}

	/// Versioned base URL including the API key path segment.
	var baseURL: String {
		"https://www.themealdb.com/api/json/v1/\(apiKey)"
	}

	/// Human-readable name surfaced in the debug overlay.
	var displayName: String {
		switch self {
		case .development: "Development"
		case .staging: "Staging"
		case .production: "Production"
		}
	}

	/// Whether to surface the in-app environment badge and diagnostics.
	/// Off in production.
	var showsDebugOverlay: Bool {
		switch self {
		case .development,
		     .staging: true
		case .production: false
		}
	}

	/// Minimum log level for this environment.
	var logVerbosity: LogVerbosity {
		switch self {
		case .development: .debug
		case .staging: .info
		case .production: .warning
		}
	}
}
