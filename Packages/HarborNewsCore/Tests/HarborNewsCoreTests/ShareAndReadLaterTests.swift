import Foundation
import Testing
@testable import HarborNewsCore

@Suite("Share link and read later")
struct ShareAndReadLaterTests {
    @Test func shareLinkIsTaggedWithItsSource() {
        let url = ShareLinkBuilder.url(for: .fixture())

        #expect(url.absoluteString == "https://harbornews.example/a1?utm_source=ios_share")
    }

    @Test func shareLinkKeepsExistingQueryItems() {
        let url = ShareLinkBuilder.url(for: .fixture(shareURL: "https://harbornews.example/a1?ref=push"))

        #expect(url.absoluteString == "https://harbornews.example/a1?ref=push&utm_source=ios_share")
    }

    @Test func readLaterStartsEmpty() {
        #expect(ReadLaterStore(store: InMemoryKeyValueStore()).load().isEmpty)
    }

    @Test func readLaterKeepsSavedArticlesBetweenInstances() {
        let storage = InMemoryKeyValueStore()
        ReadLaterStore(store: storage).toggle(.fixture())

        let reloaded = ReadLaterStore(store: storage)

        #expect(reloaded.load() == [.fixture()])
        #expect(reloaded.contains(.fixture()))
    }

    @Test func togglingTwiceRemovesTheArticle() {
        let store = ReadLaterStore(store: InMemoryKeyValueStore())

        #expect(store.toggle(.fixture()) == true)
        #expect(store.toggle(.fixture()) == false)
        #expect(store.load().isEmpty)
    }
}
