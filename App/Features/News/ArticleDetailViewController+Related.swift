import HarborNewsCore
import UIKit

extension ArticleDetailViewController: UITableViewDataSource, RelatedStoryCellDelegate {
    func registerRelatedCells() {
        relatedTable.register(RelatedStoryCell.self, forCellReuseIdentifier: RelatedStoryCell.reuseIdentifier)
        relatedTable.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        related.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RelatedStoryCell.reuseIdentifier, for: indexPath)
        if let relatedCell = cell as? RelatedStoryCell {
            relatedCell.configure(with: related[indexPath.row])
            relatedCell.delegate = self
        }
        return cell
    }

    func relatedStoryCell(_ cell: RelatedStoryCell, didTapSave article: Article) {
        toggleReadLater(for: article)
    }
}
