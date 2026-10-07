import Foundation

public protocol ArticleRepository {
    func headlines(section: String?) async throws -> [Article]
}

public final class URLSessionArticleRepository: ArticleRepository {
    private let client: HTTPClient
    private let config: APIConfig
    private let decoder = JSONDecoder()

    public init(client: HTTPClient = URLSessionHTTPClient(), config: APIConfig = .default) {
        self.client = client
        self.config = config
    }

    public func headlines(section: String?) async throws -> [Article] {
        let query = section.map { [URLQueryItem(name: "section", value: $0)] } ?? []
        let url = config.url(path: "stations/\(config.stationID)/headlines", query: query)
        let data = try await client.data(from: url)
        return try decoder.decode([LossyArticle].self, from: data).compactMap(\.article)
    }
}

/// Decodes one array element without failing the whole list when a row is malformed.
private struct LossyArticle: Decodable {
    let article: Article?

    init(from decoder: Decoder) throws {
        article = try? Article(from: decoder)
    }
}
