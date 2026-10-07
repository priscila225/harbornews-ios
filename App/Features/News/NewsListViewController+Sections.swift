import HarborNewsCore
import UIKit

extension NewsListViewController: SectionPickerDelegate {
    func sectionPicker(_ picker: SectionPickerView, didSelect section: NewsSection) {
        viewModel.select(section: section)
    }
}
