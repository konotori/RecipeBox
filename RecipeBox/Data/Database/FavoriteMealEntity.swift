import Foundation
import SwiftData

/// SwiftData record for a favourited meal. Stores only the summary fields
/// needed for the list; the full meal is re-fetched on the detail screen.
@Model
final class FavoriteMealEntity {
	var id: String
	var name: String
	var thumbnailURLString: String?
	var addedAt: Date

	init(id: String, name: String, thumbnailURLString: String?, addedAt: Date) {
		self.id = id
		self.name = name
		self.thumbnailURLString = thumbnailURLString
		self.addedAt = addedAt
	}
}
