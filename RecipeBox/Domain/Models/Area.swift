import Foundation

/// A culinary area / cuisine (Italian, Japanese, Canadian, …).
///
/// TheMealDB identifies an area only by its name, so the name doubles as the
/// stable identity.
struct Area: Identifiable, Equatable, Hashable {
	var id: String {
		name
	}
	let name: String
}
