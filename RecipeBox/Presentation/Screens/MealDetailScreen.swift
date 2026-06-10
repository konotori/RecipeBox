import NaviStack
import SwiftUI

@MainActor
@Observable
final class MealDetailViewModel {
	let mealID: String
	let mealName: String

	private let fetchDetail: FetchMealDetailUseCase
	private let toggleFavoriteUseCase: ToggleFavoriteUseCase
	private let favorites: FavoritesStore

	var meal: Loadable<Meal> = .idle
	var checkedIngredients: Set<String> = []

	init(
		mealID: String,
		mealName: String,
		fetchDetail: FetchMealDetailUseCase,
		toggleFavoriteUseCase: ToggleFavoriteUseCase,
		favorites: FavoritesStore
	) {
		self.mealID = mealID
		self.mealName = mealName
		self.fetchDetail = fetchDetail
		self.toggleFavoriteUseCase = toggleFavoriteUseCase
		self.favorites = favorites
	}

	var isFavorite: Bool {
		favorites.contains(id: mealID)
	}

	func loadIfNeeded() async {
		if case .idle = meal {
			await load()
		}
	}

	func load() async {
		meal = .loading
		do {
			meal = try await .loaded(fetchDetail.execute(id: mealID))
		} catch is CancellationError {
		} catch {
			meal = .failed(error)
		}
	}

	func toggleFavorite() {
		guard let value = meal.value else {
			return
		}
		try? toggleFavoriteUseCase.execute(value)
	}

	func isChecked(_ ingredient: String) -> Bool {
		checkedIngredients.contains(ingredient)
	}

	func toggleIngredient(_ ingredient: String) {
		if checkedIngredients.contains(ingredient) {
			checkedIngredients.remove(ingredient)
		} else {
			checkedIngredients.insert(ingredient)
		}
	}
}

/// Full meal detail: hero image, badges, tags, an interactive ingredient
/// checklist, numbered instructions, and external links.
struct MealDetailScreen: View {
	@EnvironmentObject private var router: AppRouter
	@State private var viewModel: MealDetailViewModel

	init(viewModel: MealDetailViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		LoadableView(state: viewModel.meal, retry: { Task { await viewModel.load() } }, content: { meal in
			detail(meal)
		})
		.navigationTitle(viewModel.mealName)
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				FavoriteButton(isFavorite: viewModel.isFavorite) {
					viewModel.toggleFavorite()
				}
			}
		}
		.task { await viewModel.loadIfNeeded() }
	}

	private func detail(_ meal: Meal) -> some View {
		ScrollView {
			VStack(alignment: .leading, spacing: AppTheme.Spacing.xLarge) {
				hero(meal)
				badges(meal)
				if !meal.tags.isEmpty {
					tags(meal)
				}
				if !meal.ingredients.isEmpty {
					ingredients(meal)
				}
				instructions(meal)
				links(meal)
			}
			.padding(.bottom, AppTheme.Spacing.xxLarge)
		}
		.screenBackground()
	}

	@ViewBuilder
	private func hero(_ meal: Meal) -> some View {
		if let url = meal.thumbnailURL {
			Button {
				router.presentFullScreenCover(.imageViewer(url: url))
			} label: {
				RemoteImage(url: url)
					.frame(height: 280)
					.frame(maxWidth: .infinity)
					.clipped()
			}
			.buttonStyle(.plain)
		}
	}

	private func badges(_ meal: Meal) -> some View {
		HStack(spacing: AppTheme.Spacing.large) {
			Label(meal.category, systemImage: "tag")
			Label(meal.area, systemImage: "globe")
		}
		.font(.subheadline.weight(.medium))
		.foregroundStyle(.secondary)
		.padding(.horizontal, AppTheme.Spacing.large)
	}

	private func tags(_ meal: Meal) -> some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: AppTheme.Spacing.small) {
				ForEach(meal.tags, id: \.self) { tag in
					TagChip(text: tag)
				}
			}
			.padding(.horizontal, AppTheme.Spacing.large)
		}
	}

	private func ingredients(_ meal: Meal) -> some View {
		VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
			SectionHeader(title: "Ingredients")
			VStack(spacing: AppTheme.Spacing.small) {
				ForEach(meal.ingredients) { ingredient in
					IngredientRow(
						ingredient: ingredient,
						isChecked: viewModel.isChecked(ingredient.name)
					) {
						viewModel.toggleIngredient(ingredient.name)
					}
				}
			}
			.padding(AppTheme.Spacing.medium)
			.glassCard()
		}
		.padding(.horizontal, AppTheme.Spacing.large)
	}

	private func instructions(_ meal: Meal) -> some View {
		let steps = Array(meal.instructions.recipeSteps().enumerated())
		return VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
			SectionHeader(title: "Instructions")
			ForEach(steps, id: \.offset) { item in
				InstructionStepRow(number: item.offset + 1, text: item.element)
			}
		}
		.padding(.horizontal, AppTheme.Spacing.large)
	}

	private func links(_ meal: Meal) -> some View {
		VStack(spacing: AppTheme.Spacing.medium) {
			if let youtube = meal.youtubeURL {
				Link(destination: youtube) {
					Label("Watch on YouTube", systemImage: "play.rectangle.fill")
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
			}
			if let source = meal.sourceURL {
				Link(destination: source) {
					Label("View Original Recipe", systemImage: "safari")
						.frame(maxWidth: .infinity)
				}
				.buttonStyle(.bordered)
			}
		}
		.padding(.horizontal, AppTheme.Spacing.large)
	}
}

/// One numbered instruction step. Extracted to keep the detail body fast to
/// type-check.
private struct InstructionStepRow: View {
	let number: Int
	let text: String

	var body: some View {
		HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
			Text("\(number)")
				.font(.headline)
				.foregroundStyle(AppTheme.Colors.accent)
				.frame(width: 24, alignment: .leading)
			Text(text)
				.font(.body)
				.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}
