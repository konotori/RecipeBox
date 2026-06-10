import Testing
@testable import RecipeBox

@Suite("App support")
struct AppSupportTests {
	@Test
	func baseURLIncludesAPIKeyPathSegment() {
		let environment = AppEnvironment.production
		#expect(environment.baseURL == "https://www.themealdb.com/api/json/v1/\(environment.apiKey)")
	}

	@Test
	func debugOverlayOnlyOutsideProduction() {
		#expect(AppEnvironment.production.showsDebugOverlay == false)
		#expect(AppEnvironment.development.showsDebugOverlay)
		#expect(AppEnvironment.staging.showsDebugOverlay)
	}

	@Test
	func logVerbosityPerEnvironment() {
		#expect(AppEnvironment.development.logVerbosity == .debug)
		#expect(AppEnvironment.staging.logVerbosity == .info)
		#expect(AppEnvironment.production.logVerbosity == .warning)
	}

	@Test
	func nilIfBlankTrimsAndNullifies() {
		#expect("  hello  ".nilIfBlank == "hello")
		#expect("".nilIfBlank == nil)
		#expect("   \n\t".nilIfBlank == nil)
	}

	@Test
	func recipeStepsSplitsTrimsAndDropsEmpty() {
		let steps = "Step one.\r\n\r\n  Step two.  \nStep three.".recipeSteps()
		#expect(steps == ["Step one.", "Step two.", "Step three."])
	}

	@Test
	func cuisineCatalogSupportsOnlyContentCuisines() {
		#expect(CuisineCatalog.isSupported("Japanese"))
		#expect(CuisineCatalog.isSupported("Italian"))
		#expect(CuisineCatalog.isSupported("Andorran") == false)
		#expect(CuisineCatalog.isSupported("American") == false)
	}

	@Test
	func safeSubscriptGuardsBounds() {
		let values = [10, 20]
		#expect(values[safe: 1] == 20)
		#expect(values[safe: 5] == nil)
		#expect(values[safe: -1] == nil)
	}
}
