import NaviStack
import SwiftUI

@MainActor
@Observable
final class SearchViewModel {
	private let searchMeals: SearchMealsUseCase

	var query = ""
	var results: Loadable<[Meal]> = .idle

	init(searchMeals: SearchMealsUseCase) {
		self.searchMeals = searchMeals
	}

	/// Debounced search: the view re-runs this via `.task(id: query)`, so a new
	/// keystroke cancels the in-flight sleep before a request is ever made.
	func search() async {
		let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else {
			results = .idle
			return
		}
		results = .loading
		do {
			try await Task.sleep(for: .milliseconds(350))
			results = try await .loaded(searchMeals.execute(query: trimmed))
		} catch is CancellationError {
		} catch {
			results = .failed(error)
		}
	}
}

/// Third tab: search recipes by name with a debounced `.searchable` field.
struct SearchScreen: View {
	@EnvironmentObject private var router: AppRouter
	@State private var viewModel: SearchViewModel

	init(viewModel: SearchViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		@Bindable var viewModel = viewModel

		content
			.navigationTitle("Search")
			.searchable(text: $viewModel.query, prompt: "Search recipes")
			.autocorrectionDisabled()
			.task(id: viewModel.query) { await viewModel.search() }
	}

	@ViewBuilder
	private var content: some View {
		switch viewModel.results {
		case .idle:
			ContentUnavailableView(
				"Search Recipes",
				systemImage: "magnifyingglass",
				description: Text("Find meals by name, e.g. \"Arrabiata\".")
			)

		case .loading:
			ProgressView()
				.controlSize(.large)
				.frame(maxWidth: .infinity, maxHeight: .infinity)

		case let .loaded(meals):
			if meals.isEmpty {
				ContentUnavailableView.search(text: viewModel.query)
			} else {
				List(meals) { meal in
					Button {
						router.push(.mealDetail(id: meal.id, name: meal.name))
					} label: {
						SearchResultRow(meal: meal)
					}
					.buttonStyle(.plain)
				}
			}

		case let .failed(error):
			ErrorStateView(error: error) {
				Task { await viewModel.search() }
			}
		}
	}
}

private struct SearchResultRow: View {
	let meal: Meal

	var body: some View {
		HStack(spacing: AppTheme.Spacing.medium) {
			RemoteImage(url: meal.thumbnailURL)
				.frame(width: 56, height: 56)
				.clipShape(.rect(cornerRadius: AppTheme.Radius.small))

			VStack(alignment: .leading, spacing: 2) {
				Text(meal.name)
					.font(.headline)
					.foregroundStyle(.primary)
				Text("\(meal.category) · \(meal.area)")
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}

			Spacer()
		}
		.contentShape(.rect)
	}
}
