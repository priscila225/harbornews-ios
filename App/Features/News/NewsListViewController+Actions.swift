import HarborNewsCore
import UIKit

extension NewsListViewController: NewsListActions {
    func showArticle(_ article: Article) {
        navigationController?.pushViewController(ArticleDetailViewController(article: article), animated: true)
    }
}
