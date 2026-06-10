import SwiftUI

/// Four-state async value used by every screen's view model.
enum Loadable<Value> {
	case idle
	case loading
	case loaded(Value)
	case failed(Error)

	var value: Value? {
		if case let .loaded(value) = self {
			return value
		}
		return nil
	}
}

/// Renders a ``Loadable`` with a spinner, the loaded content, or a retryable
/// error state.
struct LoadableView<Value, Content: View>: View {
	let state: Loadable<Value>
	var retry: (() -> Void)?
	@ViewBuilder let content: (Value) -> Content

	var body: some View {
		switch state {
		case .idle,
		     .loading:
			ProgressView()
				.controlSize(.large)
				.frame(maxWidth: .infinity, maxHeight: .infinity)

		case let .loaded(value):
			content(value)

		case let .failed(error):
			ErrorStateView(error: error, retry: retry)
		}
	}
}
