import Foundation
import Testing
@testable import HarborNewsCore

@Suite("Article decoding")
struct ArticleDecodingTests {
    private func decode(_ json: String) async throws -> [Article] {
        let client = StubHTTPClient(result: .success(Data(json.utf8)))
        let repository = URLSessionArticleRepository(client: client)
        return try await repository.headlines(section: nil)
    }

    @Test func decodesAFullRow() async throws {
        let json = #"[{"id":"a1","title":"Harbor reopens","summary":"Ferries run","section":"local","shareUrl":"https://x.example/a1","publishedAt":1700000000000}]"#
        let article = try #require(await decode(json).first)

        #expect(article.id == "a1")
        #expect(article.section == "local")
        #expect(article.shareURL == "https://x.example/a1")
        #expect(article.publishedAt == Date(timeIntervalSince1970: 1_700_000_000))
    }

    @Test func fillsDefaultsForMissingOptionalFields() async throws {
        let article = try #require(await decode(#"[{"id":"a1","title":"T"}]"#).first)

        #expect(article.summary == "")
        #expect(article.section == "top")
        #expect(article.imageURL == nil)
        #expect(article.publishedAt == nil)
    }

    @Test func skipsMalformedRowsInsteadOfFailingTheList() async throws {
        let json = #"[{"id":"a1","title":"T"},{"title":"no id"},{"id":"a3","title":"T3"}]"#

        let articles = try await decode(json)

        #expect(articles.map(\.id) == ["a1", "a3"])
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
