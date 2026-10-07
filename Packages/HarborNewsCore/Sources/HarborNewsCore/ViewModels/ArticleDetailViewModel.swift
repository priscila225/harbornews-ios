import Combine
import Foundation

public protocol ArticleDetailViewModelProtocol: AnyObject {
    var state: ViewState<ArticleDetail> { get }
    var statePublisher: AnyPublisher<ViewState<ArticleDetail>, Never> { get }
    var relatedPublisher: AnyPublisher<[Article], Never> { get }
    func load()
    func shareURL() -> URL?
    func toggleReadLater() -> Bool
    func toggleReadLater(for article: Article) -> Bool
}

public final class ArticleDetailViewModel: ArticleDetailViewModelProtocol, ObservableObject {
    @Published public private(set) var state: ViewState<ArticleDetail> = .idle
    @Published public private(set) var related: [Article] = []
    public var statePublisher: AnyPublisher<ViewState<ArticleDetail>, Never> { $state.eraseToAnyPublisher() }
    public var relatedPublisher: AnyPublisher<[Article], Never> { $related.eraseToAnyPublisher() }

    private let article: Article
    private let repository: ArticleRepository
    private let readLater: ReadLaterStore
    private var loadTask: Task<Void, Never>?

    public init(
        article: Article,
        repository: ArticleRepository = AppDependencies.shared.articleRepository,
        readLater: ReadLaterStore = ReadLaterStore()
    ) {
        self.article = article
        self.repository = repository
        self.readLater = readLater
    }

    public func load() {
        loadTask?.cancel()
        state = .loading
        loadTask = Task { [weak self, repository, article] in
            do {
                let detail = try await repository.articleDetail(id: article.id)
                if Task.isCancelled { return }
                self?.state = .success(detail)
            } catch {
                if Task.isCancelled { return }
                self?.state = .error(error.localizedDescription)
            }
        }
        repository.fetchRelated(articleID: article.id) { [weak self] result in
            if case .success(let articles) = result {
                self?.related = articles
            }
        }
    }

    public func shareURL() -> URL? {
        guard case .success(let detail) = state else { return nil }
        return ShareLinkBuilder.url(for: detail)
    }

    public func toggleReadLater() -> Bool {
        readLater.toggle(article)
    }

    public func toggleReadLater(for article: Article) -> Bool {
        readLater.toggle(article)
    }
}
