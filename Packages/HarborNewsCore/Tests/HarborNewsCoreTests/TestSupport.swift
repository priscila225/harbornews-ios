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

    func headlines(section: String?) async throws -> [Article] {
        try result.get()
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

extension Article {
    static func fixture(id: String = "a1", title: String = "Harbor reopens") -> Article {
        Article(id: id, title: title, summary: "Ferries are running", section: "local")
    }
}
