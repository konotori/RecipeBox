import Foundation
import LogPipe
import RESTKit

/// RESTKit interceptor that traces every request/response through LogPipe.
/// Demonstrates the two-phase `adapt` / `didComplete` pipeline. `Sendable`
/// because `Logger` is.
struct LoggingInterceptor: RequestInterceptor {
	let logger: Logger

	func adapt(_ request: URLRequest, for _: any Endpoint) async throws -> URLRequest {
		logger.debug(
			"→ \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "?")",
			tags: ["network"]
		)
		return request
	}

	func didComplete(
		_ request: URLRequest,
		result: Result<(Data, URLResponse), Error>,
		for _: any Endpoint
	) async {
		switch result {
		case let .success((data, response)):
			let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
			logger.info(
				"← \(statusCode) \(request.url?.lastPathComponent ?? "?") (\(data.count) bytes)",
				tags: ["network"]
			)

		case let .failure(error):
			logger.error("✗ request failed", error: error, tags: ["network"])
		}
	}
}
