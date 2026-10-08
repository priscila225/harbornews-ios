import Foundation

public protocol ArticleRepository {
    func headlines(section: String?) async throws -> [Article]
    func articleDetail(id: String) async throws -> ArticleDetail
    /// Callback style, kept for the older related-stories widget. The completion runs on the session's queue.
    func fetchRelated(articleID: String, completion: @escaping (Result<[Article], Error>) -> Void)
}

public final class URLSessionArticleRepository: ArticleRepository {
    private let client: HTTPClient
    private let config: APIConfig
    private let session: URLSession
    private let decoder = JSONDecoder()

    public init(client: HTTPClient = URLSessionHTTPClient(), config: APIConfig = .default, session: URLSession = .shared) {
        self.client = client
        self.config = config
        self.session = session
    }

    public func headlines(section: String?) async throws -> [Article] {
        let query = section.map { [URLQueryItem(name: "section", value: $0)] } ?? []
        let url = config.url(path: "stations/\(config.stationID)/headlines", query: query)
        let data = try await client.data(from: url)
        return try decoder.decode([LossyArticle].self, from: data).compactMap(\.article)
    }

    public func articleDetail(id: String) async throws -> ArticleDetail {
        let data = try await client.data(from: config.url(path: "stations/\(config.stationID)/articles/\(id)"))
        return try decoder.decode(ArticleDetail.self, from: data)
    }

    public func fetchRelated(articleID: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        let url = config.url(path: "stations/\(config.stationID)/articles/\(articleID)/related")
        let decoder = self.decoder
        session.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                let rows = try decoder.decode([LossyArticle].self, from: data ?? Data())
                completion(.success(rows.compactMap(\.article)))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

/// Decodes one array element without failing the whole list when a row is malformed.
private struct LossyArticle: Decodable {
    let article: Article?

    init(from decoder: Decoder) throws {
        article = try? Article(from: decoder)
    }
}
