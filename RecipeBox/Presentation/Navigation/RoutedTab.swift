import NaviStack
import SwiftUI

/// Wires one tab's NaviStack router into a SwiftUI `NavigationStack` and the
/// shared sheet/cover presentations. The router is published to descendants as
/// an `@EnvironmentObject` so any screen can call `router.push(...)`.
struct RoutedTab<Root: View>: View {
	@ObservedObject var router: AppRouter
	@ViewBuilder var root: () -> Root

	var body: some View {
		NavigationStack(path: $router.path) {
			root()
				.navigationDestination(for: AppRoute.self) { route in
					RouteDestinationView(route: route)
				}
		}
		.environmentObject(router)
		.sheet(item: router.sheetBinding) { sheet in
			AppSheetView(sheet: sheet)
		}
		.fullScreenCover(item: router.fullScreenCoverBinding) { cover in
			AppCoverView(cover: cover)
		}
	}
}
