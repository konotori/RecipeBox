import Foundation

/// Push destinations. Routes carry the domain value they need; detail carries
/// id + name so the title shows instantly while the full meal loads.
enum AppRoute: Hashable {
	case category(MealCategory)
	case area(Area)
	case mealDetail(id: String, name: String)
}

/// Sheet presentations routed through NaviStack.
enum AppSheet: Identifiable {
	case about

	var id: String {
		switch self {
		case .about: "about"
		}
	}
}

/// Full-screen cover presentations routed through NaviStack.
enum AppCover: Identifiable {
	case imageViewer(url: URL)

	var id: String {
		switch self {
		case let .imageViewer(url): url.absoluteString
		}
	}
}
