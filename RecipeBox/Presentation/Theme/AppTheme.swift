import SwiftUI

/// Centralised design tokens. Reference these instead of hard-coding values so
/// spacing, corner radii, and colours stay consistent across screens.
enum AppTheme {
	enum Spacing {
		static let xSmall: CGFloat = 4
		static let small: CGFloat = 8
		static let medium: CGFloat = 12
		static let large: CGFloat = 16
		static let xLarge: CGFloat = 24
		static let xxLarge: CGFloat = 32
	}

	enum Radius {
		static let small: CGFloat = 10
		static let medium: CGFloat = 16
		static let card: CGFloat = 22
	}

	enum Colors {
		static let accent = Color.orange
		static let card = Color(uiColor: .secondarySystemBackground)
		static let screen = Color(uiColor: .systemGroupedBackground)
	}

	enum Typography {
		static let sectionTitle = Font.title2.weight(.bold)
		static let cardTitle = Font.headline
		static let caption = Font.subheadline
	}
}
