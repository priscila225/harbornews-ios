import HarborNewsCore
import UIKit

protocol RelatedStoryCellDelegate {
    func relatedStoryCell(_ cell: RelatedStoryCell, didTapSave article: Article)
}

final class RelatedStoryCell: UITableViewCell {
    static let reuseIdentifier = "RelatedStoryCell"

    var delegate: RelatedStoryCellDelegate?
    private var article: Article?
    private let saveButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        saveButton.setTitle("Save", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        saveButton.sizeToFit()
        accessoryView = saveButton
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func configure(with article: Article) {
        self.article = article
        textLabel?.text = article.title
        detailTextLabel?.text = article.summary
    }

    @objc private func saveTapped() {
        guard let article = article else { return }
        delegate?.relatedStoryCell(self, didTapSave: article)
    }
}
