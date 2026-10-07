import Foundation
import Testing
@testable import HarborNewsCore

@Suite("Article decoding")
struct ArticleDecodingTests {
    private func decode(_ json: String) throws -> [Article] {
        let client = StubHTTPClient(result: .success(Data(json.utf8)))
        let repository = URLSessionArticleRepository(client: client)
        return try awaitSync { try await repository.headlines(section: nil) }
    }

    @Test func decodesAFullRow() throws {
        let json = #"[{"id":"a1","title":"Harbor reopens","summary":"Ferries run","section":"local","shareUrl":"https://x.example/a1","publishedAt":1700000000000}]"#
        let article = try #require(try decode(json).first)

        #expect(article.id == "a1")
        #expect(article.section == "local")
        #expect(article.shareURL == "https://x.example/a1")
        #expect(article.publishedAt == Date(timeIntervalSince1970: 1_700_000_000))
    }

    @Test func fillsDefaultsForMissingOptionalFields() throws {
        let article = try #require(try decode(#"[{"id":"a1","title":"T"}]"#).first)

        #expect(article.summary == "")
        #expect(article.section == "top")
        #expect(article.imageURL == nil)
        #expect(article.publishedAt == nil)
    }

    @Test func skipsMalformedRowsInsteadOfFailingTheList() throws {
        let json = #"[{"id":"a1","title":"T"},{"title":"no id"},{"id":"a3","title":"T3"}]"#

        #expect(try decode(json).map(\.id) == ["a1", "a3"])
    }

    @Test func encodeThenDecodeRoundTrips() throws {
        let original = Article(
            id: "a1", title: "T", summary: "S", section: "local",
            imageURL: URL(string: "https://x.example/i.png"), shareURL: "https://x.example/a1",
            publishedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let data = try JSONEncoder().encode(original)

        #expect(try JSONDecoder().decode(Article.self, from: data) == original)
    }
}

/// Runs an async throwing operation to completion from a synchronous test body.
func awaitSync<T>(_ operation: @escaping () async throws -> T) throws -> T {
    let semaphore = DispatchSemaphore(value: 0)
    var outcome: Result<T, Error>?
    Task {
        do { outcome = .success(try await operation()) } catch { outcome = .failure(error) }
        semaphore.signal()
    }
    semaphore.wait()
    return try #require(outcome).get()
}
