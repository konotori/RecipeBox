import SwiftUI

/// Full-screen, pinch-to-zoom viewer for a meal's hero image. Presented as a
/// NaviStack full-screen cover; dismisses via the environment.
struct ImageViewerCover: View {
	let url: URL

	@Environment(\.dismiss) private var dismiss
	@State private var zoom: CGFloat = 1

	var body: some View {
		ZStack {
			Color.black.ignoresSafeArea()

			RemoteImage(url: url, contentMode: .fit)
				.scaleEffect(zoom)
				.gesture(
					MagnifyGesture()
						.onChanged { zoom = max(1, $0.magnification) }
						.onEnded { _ in
							withAnimation(.spring) { zoom = 1 }
						}
				)
		}
		.overlay(alignment: .topTrailing) {
			Button {
				dismiss()
			} label: {
				Image(systemName: "xmark.circle.fill")
					.font(.title)
					.foregroundStyle(.white.opacity(0.85))
					.padding()
			}
		}
	}
}
