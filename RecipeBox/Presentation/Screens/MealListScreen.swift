import NaviStack
import SwiftUI

/// Generic meal-summary grid backed by an injected loader, reused for both
/// "meals in a category" and "meals in an area" — same UI, different source.
@MainActor
@Observable
final class MealListViewModel {
	let title: String
	private let loader: () async throws -> [MealSummary]

	var meals: Loadable<[MealSummary]> = .idle

	init(title: String, loader: @escaping () async throws -> [MealSummary]) {
		self.title = title
		self.loader = loader
	}

	func loadIfNeeded() async {
		if case .idle = meals {
			await load()
		}
	}

	func load() async {
		meals = .loading
		do {
			meals = try await .loaded(loader())
		} catch is CancellationError {
		} catch {
			meals = .failed(error)
		}
	}
}

struct MealListScreen: View {
	@EnvironmentObject private var router: AppRouter
	@State private var viewModel: MealListViewModel

	private let columns = [GridItem(.adaptive(minimum: 150), spacing: AppTheme.Spacing.medium)]

	init(viewModel: MealListViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		LoadableView(state: viewModel.meals, retry: { Task { await viewModel.load() } }, content: { meals in
			if meals.isEmpty {
				ContentUnavailableView(
					"No Recipes",
					systemImage: "tray",
					description: Text("There are no recipes here yet.")
				)
			} else {
				ScrollView {
					LazyVGrid(columns: columns, spacing: AppTheme.Spacing.medium) {
						ForEach(meals) { meal in
							Button {
								router.push(.mealDetail(id: meal.id, name: meal.name))
							} label: {
								MealCard(meal: meal)
							}
							.buttonStyle(.plain)
						}
					}
					.padding(AppTheme.Spacing.large)
				}
			}
		})
		.screenBackground()
		.navigationTitle(viewModel.title)
		.navigationBarTitleDisplayMode(.inline)
		.task { await viewModel.loadIfNeeded() }
	}
}
