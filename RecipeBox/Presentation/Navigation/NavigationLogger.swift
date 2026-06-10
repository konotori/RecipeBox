import LogPipe
import NaviStack

/// NaviStack interceptor that traces navigation/sheet/cover events through
/// LogPipe — a read-only observer using only the `didProcess` phase. Showcases
/// the router's two-phase interceptor pipeline.
@MainActor
final class NavigationLogger: Interceptor {
	typealias NavRoute = AppRoute
	typealias SheetRoute = AppSheet
	typealias CoverRoute = AppCover

	private let logger: Logger

	init(logger: Logger) {
		self.logger = logger
	}

	func didProcess(_ event: NavigationEvent<AppRoute>, for router: AppRouter) {
		logger.debug(
			"nav \(String(describing: event)) → \(router.currentRouteName) (depth \(router.navigationDepth))",
			tags: ["navigation"]
		)
	}

	func didProcess(_ event: SheetEvent<AppSheet>, for _: AppRouter) {
		logger.debug("sheet \(String(describing: event))", tags: ["navigation"])
	}

	func didProcess(_ event: CoverEvent<AppCover>, for _: AppRouter) {
		logger.debug("cover \(String(describing: event))", tags: ["navigation"])
	}
}
