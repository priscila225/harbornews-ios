import HarborNewsCore
import os
import UIKit

extension NewsListViewController: NewsListActions {
    func showArticle(_ article: Article) {
        Logger(subsystem: "com.harbornews.app", category: "news").debug("Article selected: \(article.id, privacy: .public)")
    }
}
