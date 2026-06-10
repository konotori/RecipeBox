import SwiftUI

/// `AsyncImage` wrapper with a consistent skeleton placeholder and a failure
/// fallback, so every remote image across the app behaves the same.
struct RemoteImage: View {
	let url: URL?
	var contentMode: ContentMode = .fill

	var body: some View {
		AsyncImage(url: url, transaction: Transaction(animation: .easeOut(duration: 0.25))) { phase in
			switch phase {
			case .empty:
				placeholder.skeletonPulse()

			case let .success(image):
				image
					.resizable()
					.aspectRatio(contentMode: contentMode)

			case .failure:
				placeholder.overlay {
					Image(systemName: "photo")
						.font(.title2)
						.foregroundStyle(.secondary)
				}

			@unknown default:
				placeholder
			}
		}
	}

	private var placeholder: some View {
		Rectangle().fill(.quaternary)
	}
}
