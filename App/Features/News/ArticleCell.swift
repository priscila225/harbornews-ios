import HarborNewsCore
import UIKit

final class ArticleCell: UITableViewCell {
    static let reuseIdentifier = "ArticleCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        textLabel?.numberOfLines = 2
        detailTextLabel?.numberOfLines = 2
        detailTextLabel?.textColor = .secondaryLabel
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func configure(with article: Article, shareCount: Int? = nil) {
        textLabel?.text = article.title
        let shares = shareCount.map { "  |  \($0) shares" } ?? ""
        detailTextLabel?.text = article.summary + shares
    }
}
