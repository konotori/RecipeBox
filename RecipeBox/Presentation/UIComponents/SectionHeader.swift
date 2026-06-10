import SwiftUI

/// Title row with an optional trailing action (e.g. "See all").
struct SectionHeader: View {
	let title: String
	var actionTitle: String?
	var action: (() -> Void)?

	var body: some View {
		HStack(alignment: .firstTextBaseline) {
			Text(title)
				.font(AppTheme.Typography.sectionTitle)

			Spacer()

			if let actionTitle, let action {
				Button(actionTitle, action: action)
					.font(.subheadline.weight(.medium))
			}
		}
	}
}
