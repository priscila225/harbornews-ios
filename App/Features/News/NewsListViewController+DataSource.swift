import HarborNewsCore
import UIKit

extension NewsListViewController: UITableViewDataSource, UITableViewDelegate {
    func registerCells() {
        tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.reuseIdentifier, for: indexPath)
        if let articleCell = cell as? ArticleCell {
            let article = articles[indexPath.row]
            articleCell.configure(with: article, shareCount: shareCounts[article.id])
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelect(articles[indexPath.row])
    }
}
