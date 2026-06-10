import NaviStack
import SwiftUI

/// App shell: four tabs, each with its own NaviStack router so navigation
/// state is independent per tab. Also registers the navigation logger and
/// shows the environment badge outside production.
struct RootTabView: View {
	@Environment(AppContainer.self) private var container

	@StateObject private var discoverRouter = AppRouter()
	@StateObject private var cuisinesRouter = AppRouter()
	@StateObject private var searchRouter = AppRouter()
	@StateObject private var favoritesRouter = AppRouter()

	var body: some View {
		TabView {
			Tab("Discover", systemImage: "fork.knife") {
				RoutedTab(router: discoverRouter) {
					DiscoverScreen(viewModel: container.makeDiscoverViewModel())
				}
			}

			Tab("Cuisines", systemImage: "globe") {
				RoutedTab(router: cuisinesRouter) {
					AreasScreen(viewModel: container.makeAreasViewModel())
				}
			}

			Tab("Search", systemImage: "magnifyingglass") {
				RoutedTab(router: searchRouter) {
					SearchScreen(viewModel: container.makeSearchViewModel())
				}
			}

			Tab("Favourites", systemImage: "heart") {
				RoutedTab(router: favoritesRouter) {
					FavoritesScreen()
				}
			}
		}
		.tint(AppTheme.Colors.accent)
		.overlay(alignment: .bottom) { environmentBadge }
		.task { registerNavigationLoggers() }
	}

	private func registerNavigationLoggers() {
		for router in [discoverRouter, cuisinesRouter, searchRouter, favoritesRouter] {
			router.addInterceptor(NavigationLogger(logger: container.logger))
		}
	}

	@ViewBuilder
	private var environmentBadge: some View {
		if AppEnvironment.current.showsDebugOverlay {
			Text(AppEnvironment.current.displayName.uppercased())
				.font(.caption2.weight(.bold))
				.padding(.horizontal, AppTheme.Spacing.small)
				.padding(.vertical, AppTheme.Spacing.xSmall)
				.background(AppTheme.Colors.accent.opacity(0.9), in: .capsule)
				.foregroundStyle(.white)
				.padding(.bottom, 64)
				.allowsHitTesting(false)
		}
	}
}
