import SwiftUI

/// Applies the iOS 26 Liquid Glass material to a view, with a graceful
/// `.regularMaterial` fallback on iOS 18 — progressive enhancement so the same
/// code looks native on both. Build with the iOS 26 SDK and standard
/// components already adopt Liquid Glass automatically; this brings the same
/// material to custom cards.
struct GlassCardModifier: ViewModifier {
	var cornerRadius: CGFloat = AppTheme.Radius.card
	var tint: Color?

	func body(content: Content) -> some View {
		if #available(iOS 26.0, *) {
			content.glassEffect(glass, in: .rect(cornerRadius: cornerRadius))
		} else {
			content.background(.ultraThinMaterial, in: .rect(cornerRadius: cornerRadius))
		}
	}

	@available(iOS 26.0, *)
	private var glass: Glass {
		guard let tint else {
			return .regular
		}
		return .regular.tint(tint)
	}
}

extension View {
	/// Wraps the view in a Liquid Glass card (material fallback pre-iOS 26).
	func glassCard(cornerRadius: CGFloat = AppTheme.Radius.card, tint: Color? = nil) -> some View {
		modifier(GlassCardModifier(cornerRadius: cornerRadius, tint: tint))
	}
}
