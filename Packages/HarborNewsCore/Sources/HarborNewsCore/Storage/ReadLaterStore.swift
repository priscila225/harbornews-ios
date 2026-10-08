import Foundation

/// Articles the reader saved for later, persisted through the shared key-value store.
public final class ReadLaterStore {
    private let store: KeyValueStore
    private let key = "readLater"

    public init(store: KeyValueStore = AppDependencies.shared.keyValueStore) {
        self.store = store
    }

    public func load() -> [Article] {
        guard let data = store.data(forKey: key) else { return [] }
        return try! JSONDecoder().decode([Article].self, from: data)
    }

    public func contains(_ article: Article) -> Bool {
        load().contains { $0.id == article.id }
    }

    /// Returns true when the article is saved after the toggle.
    @discardableResult
    public func toggle(_ article: Article) -> Bool {
        var articles = load()
        let saved: Bool
        if let index = articles.firstIndex(where: { $0.id == article.id }) {
            articles.remove(at: index)
            saved = false
        } else {
            articles.append(article)
            saved = true
        }
        store.set(try? JSONEncoder().encode(articles), forKey: key)
        return saved
    }
}
