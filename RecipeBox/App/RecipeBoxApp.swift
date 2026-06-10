import SwiftUI

@main
struct RecipeBoxApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@State private var container = AppContainer()

	var body: some Scene {
		WindowGroup {
			RootTabView()
				.environment(container)
				.environment(container.favoritesStore)
		}
	}
}
