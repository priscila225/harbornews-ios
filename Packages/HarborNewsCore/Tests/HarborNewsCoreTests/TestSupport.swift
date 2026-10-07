import Foundation
@testable import HarborNewsCore

struct StubHTTPClient: HTTPClient {
    let result: Result<Data, Error>

    func data(from url: URL) async throws -> Data {
        try result.get()
    }
}

struct StubArticleRepository: ArticleRepository {
    let result: Result<[Article], Error>
    var detail: Result<ArticleDetail, Error> = .failure(TestError())
    var related: Result<[Article], Error> = .success([])

    func headlines(section: String?) async throws -> [Article] {
        try result.get()
    }

    func articleDetail(id: String) async throws -> ArticleDetail {
        try detail.get()
    }

    func fetchRelated(articleID: String, completion: @escaping (Result<[Article], Error>) -> Void) {
        completion(related)
    }
}

struct StubWeatherService: WeatherService {
    let result: Result<Conditions, Error>

    func current() async throws -> Conditions {
        try result.get()
    }
}

struct TestError: Error, LocalizedError {
    var errorDescription: String? { "boom" }
}

extension ArticleDetail {
    static func fixture(shareURL: String = "https://harbornews.example/a1") -> ArticleDetail {
        ArticleDetail(id: "a1", title: "Harbor reopens", body: "Ferries are running", shareURL: shareURL)
    }
}

extension Article {
    static func fixture(id: String = "a1", title: String = "Harbor reopens") -> Article {
        Article(id: id, title: title, summary: "Ferries are running", section: "local")
    }
}
