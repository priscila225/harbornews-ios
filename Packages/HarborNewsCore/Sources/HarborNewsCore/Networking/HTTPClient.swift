import Foundation

public enum HTTPError: Error, Equatable {
    case badStatus(Int)
    case notHTTP
}

public protocol HTTPClient {
    func data(from url: URL) async throws -> Data
}

public struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse else { throw HTTPError.notHTTP }
        guard (200..<300).contains(http.statusCode) else { throw HTTPError.badStatus(http.statusCode) }
        return data
    }
}

public struct APIConfig {
    public let baseURL: URL
    public let stationID: String

    public init(baseURL: URL, stationID: String) {
        self.baseURL = baseURL
        self.stationID = stationID
    }

    public static let `default` = APIConfig(
        baseURL: URL(string: "https://api.harbornews.example") ?? URL(fileURLWithPath: "/"),
        stationID: "harbor-1"
    )

    public func url(path: String, query: [URLQueryItem] = []) -> URL {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = query.isEmpty ? nil : query
        return components?.url ?? baseURL
    }
}
