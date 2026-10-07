import Combine
import Foundation
import Testing
@testable import HarborNewsCore

@Suite("NewsListViewModel")
struct NewsListViewModelTests {
    private func firstTerminalState(of viewModel: NewsListViewModel) async -> ViewState<[Article]> {
        for await state in viewModel.statePublisher.values {
            switch state {
            case .success, .error: return state
            case .idle, .loading: continue
            }
        }
        return .idle
    }

    @Test(.timeLimit(.minutes(1)))
    func loadsArticles() async {
        let viewModel = NewsListViewModel(repository: StubArticleRepository(result: .success([.fixture()])))

        viewModel.load(section: nil)
        let state = await firstTerminalState(of: viewModel)

        guard case .success(let articles) = state else {
            Issue.record("expected success, got \(state)")
            return
        }
        #expect(articles == [.fixture()])
    }

    @Test(.timeLimit(.minutes(1)))
    func reportsFailures() async {
        let viewModel = NewsListViewModel(repository: StubArticleRepository(result: .failure(TestError())))

        viewModel.load(section: nil)
        let state = await firstTerminalState(of: viewModel)

        guard case .error(let message) = state else {
            Issue.record("expected error, got \(state)")
            return
        }
        #expect(message == "boom")
    }

    @Test func startsIdleAndMovesToLoading() {
        let viewModel = NewsListViewModel(repository: StubArticleRepository(result: .success([])))

        #expect(viewModel.state == .idle)
        viewModel.load(section: nil)
        #expect(viewModel.state == .loading)
    }

    @Test func selectionIsForwardedToActions() {
        final class Recorder: NewsListActions {
            var shown: [Article] = []
            func showArticle(_ article: Article) { shown.append(article) }
        }
        let recorder = Recorder()
        let viewModel = NewsListViewModel(repository: StubArticleRepository(result: .success([])))
        viewModel.actions = recorder

        viewModel.didSelect(.fixture())

        #expect(recorder.shown == [.fixture()])
    }
}
