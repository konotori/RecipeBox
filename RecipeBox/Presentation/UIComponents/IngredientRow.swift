import SwiftUI

/// One tappable ingredient line in the detail screen's interactive checklist.
struct IngredientRow: View {
	let ingredient: Ingredient
	let isChecked: Bool
	let toggle: () -> Void

	var body: some View {
		Button(action: toggle) {
			HStack(spacing: AppTheme.Spacing.medium) {
				Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
					.foregroundStyle(isChecked ? AnyShapeStyle(AppTheme.Colors.accent) : AnyShapeStyle(.secondary))
					.symbolEffect(.bounce, value: isChecked)

				Text(ingredient.name)
					.strikethrough(isChecked, color: .secondary)
					.foregroundStyle(isChecked ? .secondary : .primary)

				Spacer(minLength: AppTheme.Spacing.medium)

				if !ingredient.measure.isEmpty {
					Text(ingredient.measure)
						.font(.callout)
						.foregroundStyle(.secondary)
				}
			}
		}
		.buttonStyle(.plain)
		.contentShape(.rect)
	}
}

#Preview {
	@Previewable @State var checked = false
	IngredientRow(
		ingredient: Ingredient(name: "Caster Sugar", measure: "100g"),
		isChecked: checked
	) {
		checked.toggle()
	}
	.padding()
}
