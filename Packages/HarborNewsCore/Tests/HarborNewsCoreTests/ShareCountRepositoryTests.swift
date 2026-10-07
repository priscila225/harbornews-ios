import Foundation
import Testing
@testable import HarborNewsCore

@Suite("ShareCountRepository")
struct ShareCountRepositoryTests {
    private func repository(returning json: String) -> URLSessionShareCountRepository {
        URLSessionShareCountRepository(client: StubHTTPClient(result: .success(Data(json.utf8))))
    }

    @Test func returnsCountsKeyedByArticle() async throws {
        let repository = repository(returning: #"{"a1":12,"a2":3}"#)

        let counts = try await repository.shareCounts(for: ["a1", "a2"])

        #expect(counts == ["a1": 12, "a2": 3])
    }

    @Test func omitsArticlesThatWereNeverShared() async throws {
        let repository = repository(returning: #"{"a1":0,"a2":4}"#)

        let counts = try await repository.shareCounts(for: ["a1", "a2"])

        #expect(counts == ["a2": 4])
    }

    @Test func anEmptyRequestDoesNotTouchTheNetwork() async throws {
        let repository = URLSessionShareCountRepository(client: StubHTTPClient(result: .failure(TestError())))

        let counts = try await repository.shareCounts(for: [])

        #expect(counts.isEmpty)
    }
}
