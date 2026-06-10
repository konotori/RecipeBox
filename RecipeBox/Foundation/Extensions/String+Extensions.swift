import Foundation

extension String {
	/// `nil` when the string is empty or whitespace-only, otherwise `self`.
	/// Handy for turning TheMealDB's `""` / `null`-ish fields into real optionals.
	var nilIfBlank: String? {
		let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
		return trimmed.isEmpty ? nil : trimmed
	}

	/// Splits multi-line cooking instructions into trimmed, non-empty steps.
	/// TheMealDB separates steps with `\r\n` (and occasionally `STEP n` markers).
	func recipeSteps() -> [String] {
		split(whereSeparator: \.isNewline)
			.map { $0.trimmingCharacters(in: .whitespaces) }
			.filter { !$0.isEmpty }
	}
}
