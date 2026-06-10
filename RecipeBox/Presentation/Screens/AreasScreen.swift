import NaviStack
import SwiftUI

@MainActor
@Observable
final class AreasViewModel {
	private let fetchAreas: FetchAreasUseCase

	var areas: Loadable<[Area]> = .idle

	init(fetchAreas: FetchAreasUseCase) {
		self.fetchAreas = fetchAreas
	}

	func loadIfNeeded() async {
		if case .idle = areas {
			await load()
		}
	}

	func load() async {
		areas = .loading
		do {
			areas = try await .loaded(fetchAreas.execute())
		} catch is CancellationError {
		} catch {
			areas = .failed(error)
		}
	}
}

/// Second tab: browse cuisines by area, each with a flag.
struct AreasScreen: View {
	@EnvironmentObject private var router: AppRouter
	@State private var viewModel: AreasViewModel

	init(viewModel: AreasViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		LoadableView(state: viewModel.areas, retry: { Task { await viewModel.load() } }, content: { areas in
			List(areas) { area in
				Button {
					router.push(.area(area))
				} label: {
					HStack(spacing: AppTheme.Spacing.medium) {
						Text(area.name.prefix(1))
							.font(.headline.weight(.bold))
							.foregroundStyle(AppTheme.Colors.accent)
							.frame(width: 40, height: 40)
							.background(AppTheme.Colors.accent.opacity(0.15), in: .circle)
						Text(area.name)
							.foregroundStyle(.primary)
						Spacer()
						Image(systemName: "chevron.right")
							.font(.footnote.weight(.semibold))
							.foregroundStyle(.tertiary)
					}
				}
			}
		})
		.navigationTitle("Cuisines")
		.task { await viewModel.loadIfNeeded() }
	}
}
