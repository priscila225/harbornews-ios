import HarborNewsCore
import UIKit

extension NewsListViewController {
    private static let shareHintKey = "shareHintShown"

    func loadShareCounts(for articles: [Article]) {
        let repository = URLSessionShareCountRepository()
        let ids = articles.map(\.id)
        Task { [weak self] in
            guard let counts = try? await repository.shareCounts(for: ids) else { return }
            await MainActor.run {
                self?.applyShareCounts(counts)
            }
        }
    }

    private func applyShareCounts(_ counts: [String: Int]) {
        shareCounts = counts
        tableView.reloadData()
        showShareHintIfNeeded()
    }

    private func showShareHintIfNeeded() {
        guard !shareCounts.isEmpty, !UserDefaults.standard.bool(forKey: Self.shareHintKey) else { return }
        UserDefaults.standard.set(true, forKey: Self.shareHintKey)
        navigationItem.prompt = "Tap a story to share it"
    }
}
