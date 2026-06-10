import SwiftUI

/// Sheet shown from the Discover toolbar. Surfaces the active build
/// environment, which is what differentiates Dev / Staging / Prod at runtime.
struct AboutSheet: View {
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		NavigationStack {
			List {
				Section {
					AboutHeader()
				}
				buildSection
				dataSection
			}
			.navigationTitle("About")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					Button("Done") { dismiss() }
				}
			}
		}
	}

	private var buildSection: some View {
		Section("Build") {
			LabeledContent("Environment", value: AppEnvironment.current.displayName)
			LabeledContent("Version", value: versionString)
		}
	}

	private var dataSection: some View {
		Section("Data") {
			if let url = URL(string: "https://www.themealdb.com") {
				Link("Powered by TheMealDB", destination: url)
			}
		}
	}

	private var versionString: String {
		let info = Bundle.main.infoDictionary
		let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
		let build = info?["CFBundleVersion"] as? String ?? "1"
		return "\(version) (\(build))"
	}
}

private struct AboutHeader: View {
	var body: some View {
		VStack(spacing: AppTheme.Spacing.small) {
			Image(systemName: "fork.knife.circle.fill")
				.font(.system(size: 56))
				.foregroundStyle(AppTheme.Colors.accent)
			Text("Recipe Box")
				.font(.title2.weight(.bold))
			Text("Discover recipes from around the world.")
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.center)
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, AppTheme.Spacing.small)
	}
}
