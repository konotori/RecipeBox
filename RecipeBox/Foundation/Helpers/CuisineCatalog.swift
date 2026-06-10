/// The cuisines the app surfaces in the Cuisines tab.
///
/// TheMealDB's `list.php?a=list` returns ~195 nationality demonyms, but only a
/// few actually have recipes (most `filter.php?a=…` calls return no meals).
/// Browsing the raw list leads to empty dead-ends, so the Data layer filters
/// fetched areas down to this curated set — every cuisine here is known to have
/// content.
enum CuisineCatalog {
	/// TheMealDB areas that currently have recipes.
	static let supported: Set = [
		"Algerian",
		"Australian",
		"British",
		"Canadian",
		"Chinese",
		"Croatian",
		"Egyptian",
		"Filipino",
		"Greek",
		"Irish",
		"Italian",
		"Jamaican",
		"Japanese",
		"Kenyan",
		"Malaysian",
		"Mexican",
		"Moroccan",
		"Polish",
		"Portuguese",
		"Russian",
		"Saudi Arabian",
		"Spanish",
		"Syrian",
		"Thai",
		"Tunisian",
		"Turkish",
		"Ukrainian",
		"Uruguayan",
		"Vietnamese"
	]

	static func isSupported(_ area: String) -> Bool {
		supported.contains(area)
	}
}
