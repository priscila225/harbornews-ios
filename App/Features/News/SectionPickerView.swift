import HarborNewsCore
import UIKit

protocol SectionPickerDelegate: AnyObject {
    func sectionPicker(_ picker: SectionPickerView, didSelect section: NewsSection)
}

final class SectionPickerView: UIView {
    weak var delegate: SectionPickerDelegate?
    private let control = UISegmentedControl(items: NewsSection.allCases.map(\.title))

    override init(frame: CGRect) {
        super.init(frame: frame)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(selectionChanged), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        addSubview(control)
        NSLayoutConstraint.activate([
            control.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            control.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            control.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            control.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    @objc private func selectionChanged() {
        let sections = NewsSection.allCases
        guard sections.indices.contains(control.selectedSegmentIndex) else { return }
        delegate?.sectionPicker(self, didSelect: sections[control.selectedSegmentIndex])
    }
}
