import SwiftUI

/// Standard full-screen error using iOS 17+ `ContentUnavailableView`, with an
/// optional retry button.
struct ErrorStateView: View {
	let error: Error
	var retry: (() -> Void)?

	var body: some View {
		ContentUnavailableView {
			Label("Something went wrong", systemImage: "exclamationmark.triangle")
		} description: {
			Text(message)
		} actions: {
			if let retry {
				Button("Try Again", action: retry)
					.buttonStyle(.borderedProminent)
			}
		}
	}

	private var message: String {
		(error as? LocalizedError)?.errorDescription ?? error.localizedDescription
	}
}

#Preview {
	ErrorStateView(error: MealError.offline) {}
}
