import Foundation
import SwiftData

/// SwiftData-backed ``FavoritesRepository``.
///
/// Also `@Observable`, so the Presentation layer can observe ``favorites`` and
/// ``favoriteIDs`` directly for reactive updates — the one place where a Data
/// type is intentionally surfaced to the UI (the modern SwiftData pattern).
/// `@MainActor` because `ModelContext` is not `Sendable`.
@MainActor
@Observable
final class FavoritesStore: FavoritesRepository {
	private let context: ModelContext

	/// Favourited meals, most recently added first. Reactive source of truth
	/// for the Favourites screen.
	private(set) var favorites: [MealSummary] = []

	/// Fast membership lookup for favourite buttons.
	private(set) var favoriteIDs: Set<String> = []

	init(context: ModelContext) {
		self.context = context
		reload()
	}

	func all() -> [MealSummary] {
		favorites
	}

	func contains(id: String) -> Bool {
		favoriteIDs.contains(id)
	}

	func add(_ meal: Meal) throws {
		guard !favoriteIDs.contains(meal.id) else {
			return
		}
		let entity = FavoriteMealEntity(
			id: meal.id,
			name: meal.name,
			thumbnailURLString: meal.thumbnailURL?.absoluteString,
			addedAt: Date()
		)
		context.insert(entity)
		try persist()
	}

	func remove(id: String) throws {
		let descriptor = FetchDescriptor<FavoriteMealEntity>(
			predicate: #Predicate { $0.id == id }
		)
		for entity in (try? context.fetch(descriptor)) ?? [] {
			context.delete(entity)
		}
		try persist()
	}

	private func persist() throws {
		do {
			try context.save()
		} catch {
			throw MealError.persistence
		}
		reload()
	}

	private func reload() {
		let descriptor = FetchDescriptor<FavoriteMealEntity>(
			sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
		)
		let entities = (try? context.fetch(descriptor)) ?? []
		favorites = entities.map { entity in
			MealSummary(
				id: entity.id,
				name: entity.name,
				thumbnailURL: entity.thumbnailURLString.flatMap { URL(string: $0) }
			)
		}
		favoriteIDs = Set(entities.map(\.id))
	}
}
