import NaviStack
import SwiftUI

@MainActor
@Observable
final class DiscoverViewModel {
	private let fetchCategories: FetchCategoriesUseCase
	private let fetchRandomMeal: FetchRandomMealUseCase

	var categories: Loadable<[MealCategory]> = .idle
	var mealOfTheDay: Loadable<Meal> = .idle

	init(fetchCategories: FetchCategoriesUseCase, fetchRandomMeal: FetchRandomMealUseCase) {
		self.fetchCategories = fetchCategories
		self.fetchRandomMeal = fetchRandomMeal
	}

	func loadIfNeeded() async {
		if case .idle = categories {
			await loadCategories()
		}
		if case .idle = mealOfTheDay {
			await loadMealOfTheDay()
		}
	}

	func refresh() async {
		await loadCategories()
		await loadMealOfTheDay()
	}

	private func loadCategories() async {
		categories = .loading
		do {
			categories = try await .loaded(fetchCategories.execute())
		} catch is CancellationError {
		} catch {
			categories = .failed(error)
		}
	}

	private func loadMealOfTheDay() async {
		mealOfTheDay = .loading
		do {
			mealOfTheDay = try await .loaded(fetchRandomMeal.execute())
		} catch is CancellationError {
		} catch {
			mealOfTheDay = .failed(error)
		}
	}
}

/// First tab: a featured random meal plus the full category grid.
struct DiscoverScreen: View {
	@EnvironmentObject private var router: AppRouter
	@State private var viewModel: DiscoverViewModel

	private let columns = [GridItem(.adaptive(minimum: 150), spacing: AppTheme.Spacing.medium)]

	init(viewModel: DiscoverViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: AppTheme.Spacing.xLarge) {
				mealOfTheDaySection
				categoriesSection
			}
			.padding(AppTheme.Spacing.large)
		}
		.screenBackground()
		.navigationTitle("Discover")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					router.presentSheet(.about)
				} label: {
					Image(systemName: "info.circle")
				}
				.accessibilityLabel("About")
			}
		}
		.refreshable { await viewModel.refresh() }
		.task { await viewModel.loadIfNeeded() }
	}

	private var mealOfTheDaySection: some View {
		VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
			SectionHeader(title: "Meal of the Day")
			switch viewModel.mealOfTheDay {
			case .idle,
			     .loading:
				RoundedRectangle(cornerRadius: AppTheme.Radius.card)
					.fill(.quaternary)
					.frame(height: 220)
					.skeletonPulse()

			case let .loaded(meal):
				Button {
					router.push(.mealDetail(id: meal.id, name: meal.name))
				} label: {
					FeaturedMealCard(meal: meal)
				}
				.buttonStyle(.plain)

			case let .failed(error):
				ErrorStateView(error: error) {
					Task { await viewModel.refresh() }
				}
				.frame(height: 220)
			}
		}
	}

	private var categoriesSection: some View {
		VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
			SectionHeader(title: "Categories")
			LoadableView(
				state: viewModel.categories,
				retry: { Task { await viewModel.refresh() } },
				content: { categories in
					LazyVGrid(columns: columns, spacing: AppTheme.Spacing.medium) {
						ForEach(categories) { category in
							Button {
								router.push(.category(category))
							} label: {
								CategoryCard(category: category)
							}
							.buttonStyle(.plain)
						}
					}
				}
			)
		}
	}
}

/// Large hero card for the random "Meal of the Day".
private struct FeaturedMealCard: View {
	let meal: Meal

	var body: some View {
		ZStack(alignment: .bottomLeading) {
			RemoteImage(url: meal.thumbnailURL)
				.frame(height: 220)
				.frame(maxWidth: .infinity)
				.clipped()

			LinearGradient(
				colors: [.clear, .black.opacity(0.7)],
				startPoint: .center,
				endPoint: .bottom
			)

			VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
				Text(meal.name)
					.font(.title3.weight(.bold))
					.foregroundStyle(.white)
				Text("\(meal.category) · \(meal.area)")
					.font(.subheadline)
					.foregroundStyle(.white.opacity(0.85))
			}
			.padding(AppTheme.Spacing.large)
		}
		.frame(height: 220)
		.clipShape(.rect(cornerRadius: AppTheme.Radius.card))
	}
}
