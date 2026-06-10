import SwiftUI

/// Builds the destination screen for a pushed `AppRoute`, resolving each
/// screen's view model from the `AppContainer` in the environment.
struct RouteDestinationView: View {
	@Environment(AppContainer.self) private var container
	let route: AppRoute

	var body: some View {
		switch route {
		case let .category(category):
			MealListScreen(viewModel: container.makeCategoryMealsViewModel(category: category))
		case let .area(area):
			MealListScreen(viewModel: container.makeAreaMealsViewModel(area: area))
		case let .mealDetail(id, name):
			MealDetailScreen(viewModel: container.makeMealDetailViewModel(id: id, name: name))
		}
	}
}

/// Builds sheet content for a routed `AppSheet`.
struct AppSheetView: View {
	let sheet: AppSheet

	var body: some View {
		switch sheet {
		case .about:
			AboutSheet()
		}
	}
}

/// Builds full-screen cover content for a routed `AppCover`.
struct AppCoverView: View {
	let cover: AppCover

	var body: some View {
		switch cover {
		case let .imageViewer(url):
			ImageViewerCover(url: url)
		}
	}
}
