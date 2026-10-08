import Combine
import HarborNewsCore
import UIKit

final class ArticleDetailViewController: UIViewController {
    private weak var viewModel: ArticleDetailViewModelProtocol?
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    let relatedTable = UITableView(frame: .zero, style: .plain)
    var related: [Article] = []
    private var stateCancellable: AnyCancellable?
    private var relatedCancellable: AnyCancellable?

    init(article: Article, dependencies: AppDependencies = .shared) {
        let viewModel = ArticleDetailViewModel(
            article: article,
            repository: dependencies.articleRepository,
            readLater: ReadLaterStore(store: dependencies.keyValueStore)
        )
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = article.title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareTapped)),
            UIBarButtonItem(title: "Read later", style: .plain, target: self, action: #selector(readLaterTapped))
        ]
        layoutContent()
        registerRelatedCells()
        bind()
        viewModel?.load()
    }

    private func layoutContent() {
        titleLabel.font = .preferredFont(forTextStyle: .title2)
        titleLabel.numberOfLines = 0
        bodyLabel.font = .preferredFont(forTextStyle: .body)
        bodyLabel.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, relatedTable])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func bind() {
        stateCancellable = viewModel?.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { state in
                self.render(state)
            }
        relatedCancellable = viewModel?.relatedPublisher
            .sink { [weak self] articles in
                self?.related = articles
                self?.relatedTable.reloadData()
            }
    }

    private func render(_ state: ViewState<ArticleDetail>) {
        switch state {
        case .idle, .loading:
            titleLabel.text = "Loading..."
        case .success(let detail):
            titleLabel.text = detail.title
            bodyLabel.text = detail.body
        case .error(let message):
            titleLabel.text = message
        }
    }

    @objc private func shareTapped() {
        guard let url = viewModel?.shareURL() else { return }
        present(UIActivityViewController(activityItems: [url], applicationActivities: nil), animated: true)
    }

    @objc private func readLaterTapped() {
        let saved = viewModel?.toggleReadLater() ?? false
        navigationItem.rightBarButtonItems?.last?.title = saved ? "Saved" : "Read later"
    }

    func toggleReadLater(for article: Article) {
        _ = viewModel?.toggleReadLater(for: article)
    }
}
