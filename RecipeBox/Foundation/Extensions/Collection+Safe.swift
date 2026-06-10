extension Collection {
	/// Returns the element at `index` when in bounds, otherwise `nil`.
	/// Used when zipping TheMealDB's parallel `strIngredientN` / `strMeasureN`
	/// fields, where the two lists can differ in length.
	subscript(safe index: Index) -> Element? {
		indices.contains(index) ? self[index] : nil
	}
}
