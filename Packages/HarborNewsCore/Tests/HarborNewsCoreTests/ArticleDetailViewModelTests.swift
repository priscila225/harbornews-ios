import Combine
import Foundation
import Testing
@testable import HarborNewsCore

@Suite("ArticleDetailViewModel")
struct ArticleDetailViewModelTests {
    private func makeViewModel(
        detail: Result<ArticleDetail, Error>,
        related: Result<[Article], Error> = .success([])
    ) -> ArticleDetailViewModel {
        let repository = StubArticleRepository(result: .success([]), detail: detail, related: related)
        return ArticleDetailViewModel(
            article: .fixture(),
            repository: repository,
            readLater: ReadLaterStore(store: InMemoryKeyValueStore())
        )
    }

    private func firstTerminalState(of viewModel: ArticleDetailViewModel) async -> ViewState<ArticleDetail> {
        for await state in viewModel.statePublisher.values {
            switch state {
            case .success, .error: return state
            case .idle, .loading: continue
            }
        }
        return .idle
    }

    @Test(.timeLimit(.minutes(1)))
    func loadsTheArticleAndItsRelatedStories() async {
        let related = [Article.fixture(id: "r1", title: "Related")]
        let viewModel = makeViewModel(detail: .success(.fixture()), related: .success(related))

        viewModel.load()
        let state = await firstTerminalState(of: viewModel)

        guard case .success(let detail) = state else {
            Issue.record("expected success, got \(state)")
            return
        }
        #expect(detail == .fixture())
        #expect(viewModel.related == related)
    }

    @Test(.timeLimit(.minutes(1)))
    func reportsAFailedLoad() async {
        let viewModel = makeViewModel(detail: .failure(TestError()))

        viewModel.load()
        let state = await firstTerminalState(of: viewModel)

        guard case .error(let message) = state else {
            Issue.record("expected error, got \(state)")
            return
        }
        #expect(message == "boom")
    }

    @Test func shareURLIsAvailableOnceTheArticleLoaded() async {
        let viewModel = makeViewModel(detail: .success(.fixture()))
        #expect(viewModel.shareURL() == nil)

        viewModel.load()
        _ = await firstTerminalState(of: viewModel)

        #expect(viewModel.shareURL()?.absoluteString == "https://harbornews.example/a1?utm_source=ios_share")
    }

    @Test func readLaterTogglesBetweenSavedAndNotSaved() {
        let viewModel = makeViewModel(detail: .success(.fixture()))

        #expect(viewModel.toggleReadLater() == true)
        #expect(viewModel.toggleReadLater() == false)
    }

    @Test func relatedStoriesCanBeSavedIndependently() {
        let viewModel = makeViewModel(detail: .success(.fixture()))
        let other = Article.fixture(id: "r1", title: "Related")

        #expect(viewModel.toggleReadLater(for: other) == true)
        #expect(viewModel.toggleReadLater() == true)
        #expect(viewModel.toggleReadLater(for: other) == false)
    }
}
