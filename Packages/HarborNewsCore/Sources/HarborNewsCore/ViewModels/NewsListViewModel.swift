import Combine
import Foundation

public protocol NewsListActions: AnyObject {
    func showArticle(_ article: Article)
}

public protocol NewsListViewModelProtocol: AnyObject {
    var state: ViewState<[Article]> { get }
    var statePublisher: AnyPublisher<ViewState<[Article]>, Never> { get }
    var actions: NewsListActions? { get set }
    func load(section: String?)
    func didSelect(_ article: Article)
}

public final class NewsListViewModel: NewsListViewModelProtocol, ObservableObject {
    @Published public private(set) var state: ViewState<[Article]> = .idle
    public var statePublisher: AnyPublisher<ViewState<[Article]>, Never> { $state.eraseToAnyPublisher() }
    public weak var actions: NewsListActions?

    private let repository: ArticleRepository
    private var loadTask: Task<Void, Never>?

    public init(repository: ArticleRepository = AppDependencies.shared.articleRepository) {
        self.repository = repository
    }

    /// State is published from the loading task's thread; UIKit controllers hop to the main queue when binding.
    public func load(section: String? = nil) {
        loadTask?.cancel()
        state = .loading
        loadTask = Task { [weak self, repository] in
            do {
                let articles = try await repository.headlines(section: section)
                if Task.isCancelled { return }
                self?.state = .success(articles)
            } catch {
                if Task.isCancelled { return }
                self?.state = .error(error.localizedDescription)
            }
        }
    }

    public func didSelect(_ article: Article) {
        actions?.showArticle(article)
    }
}
