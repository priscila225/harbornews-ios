import Foundation

public protocol ShareCountRepository {
    /// How many times each article was shared, keyed by article id. Articles without a count are omitted.
    func shareCounts(for ids: [String]) async throws -> [String: Int]
}

public final class URLSessionShareCountRepository: ShareCountRepository {
    private let client: HTTPClient
    private let config: APIConfig

    public init(client: HTTPClient = URLSessionHTTPClient(), config: APIConfig = .default) {
        self.client = client
        self.config = config
    }

    public func shareCounts(for ids: [String]) async throws -> [String: Int] {
        guard !ids.isEmpty else { return [:] }
        let query = [URLQueryItem(name: "ids", value: ids.joined(separator: ","))]
        let url = config.url(path: "stations/\(config.stationID)/shares", query: query)
        let raw = try JSONDecoder().decode([String: Int].self, from: try await client.data(from: url))
        return raw.filter { $0.value > 0 }
    }
}
