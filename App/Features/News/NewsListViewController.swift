import Combine
import HarborNewsCore
import SwiftUI
import UIKit

final class NewsListViewController: UIViewController {
    let viewModel: NewsListViewModelProtocol
    let tableView = UITableView(frame: .zero, style: .plain)
    var articles: [Article] = []
    var shareCounts: [String: Int] = [:]
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: NewsListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Harbor News"
        view.backgroundColor = .systemBackground
        viewModel.actions = self
        layoutContent()
        registerCells()
        bind()
        viewModel.load(section: nil)
    }

    private func layoutContent() {
        let weatherStrip = UIHostingController(rootView: WeatherStripView())
        addChild(weatherStrip)
        weatherStrip.view.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(weatherStrip.view)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        weatherStrip.didMove(toParent: self)

        NSLayoutConstraint.activate([
            weatherStrip.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weatherStrip.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherStrip.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherStrip.view.heightAnchor.constraint(equalToConstant: 44),
            tableView.topAnchor.constraint(equalTo: weatherStrip.view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bind() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    private func render(_ state: ViewState<[Article]>) {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
        case .loading:
            activityIndicator.startAnimating()
        case .success(let articles):
            activityIndicator.stopAnimating()
            self.articles = articles
            tableView.reloadData()
            loadShareCounts(for: articles)
        case .error(let message):
            activityIndicator.stopAnimating()
            presentError(message)
        }
    }

    private func presentError(_ message: String) {
        let alert = UIAlertController(title: "Headlines unavailable", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
