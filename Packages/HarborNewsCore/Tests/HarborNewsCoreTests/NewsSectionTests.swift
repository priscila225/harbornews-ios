import Foundation
import Testing
@testable import HarborNewsCore

/// Records which section each load asked for.
final class RecordingArticleRepository: ArticleRepository {
    private let lock = NSLock()
    private var sections: [String?] = []
    let articles: [Article]

    init(articles: [Article] = []) {
        self.articles = articles
    }

    var requestedSections: [String?] {
        lock.lock()
        defer { lock.unlock() }
        return sections
    }

    func headlines(section: String?) async throws -> [Article] {
        lock.lock()
        sections.append(section)
        lock.unlock()
        return articles
    }
}

@Suite("News sections")
struct NewsSectionTests {
    private func waitForSuccess(_ viewModel: NewsListViewModel) async {
        for await state in viewModel.statePublisher.values {
            if case .success = state { return }
        }
    }

    @Test func topIsTheUnfilteredFeed() {
        #expect(NewsSection.top.query == nil)
        #expect(NewsSection.local.query == "local")
        #expect(NewsSection.sports.query == "sports")
    }

    @Test func everySectionHasATitle() {
        #expect(NewsSection.allCases.map(\.title) == ["Top", "Local", "Sports"])
    }

    @Test(.timeLimit(.minutes(1)))
    func selectingASectionReloadsWithItsQuery() async {
        let repository = RecordingArticleRepository(articles: [.fixture()])
        let viewModel = NewsListViewModel(repository: repository)

        viewModel.select(section: .local)
        await waitForSuccess(viewModel)

        #expect(viewModel.section == .local)
        #expect(repository.requestedSections == ["local"])
    }

    @Test func selectingTheCurrentSectionDoesNotReload() {
        let repository = RecordingArticleRepository()
        let viewModel = NewsListViewModel(repository: repository)

        viewModel.select(section: .top)

        #expect(viewModel.state == .idle)
        #expect(repository.requestedSections.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func aNewerSelectionWinsOverAnEarlierOne() async {
        let repository = RecordingArticleRepository(articles: [.fixture()])
        let viewModel = NewsListViewModel(repository: repository)

        viewModel.select(section: .local)
        viewModel.select(section: .sports)
        await waitForSuccess(viewModel)

        #expect(viewModel.section == .sports)
        #expect(repository.requestedSections.contains("sports"))
    }
}
