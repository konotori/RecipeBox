import SwiftUI

extension View {
	/// Standard grouped screen background that ignores safe areas.
	func screenBackground() -> some View {
		background(AppTheme.Colors.screen.ignoresSafeArea())
	}

	/// Gentle opacity pulse, paired with `.redacted(reason: .placeholder)` to
	/// read as a loading skeleton.
	func skeletonPulse() -> some View {
		modifier(SkeletonPulseModifier())
	}
}

private struct SkeletonPulseModifier: ViewModifier {
	@State private var isPulsing = false

	func body(content: Content) -> some View {
		content
			.opacity(isPulsing ? 1.0 : 0.45)
			.animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isPulsing)
			.onAppear { isPulsing = true }
	}
}
