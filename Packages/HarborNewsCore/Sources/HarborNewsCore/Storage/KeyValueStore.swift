import Foundation

/// All persistence goes through this protocol so tests can swap the storage and keys stay namespaced.
public protocol KeyValueStore: AnyObject {
    func data(forKey key: String) -> Data?
    func set(_ data: Data?, forKey key: String)
}

public final class UserDefaultsStore: KeyValueStore {
    private let defaults: UserDefaults
    private let namespace: String

    public init(defaults: UserDefaults = .standard, namespace: String = "harbornews") {
        self.defaults = defaults
        self.namespace = namespace
    }

    public func data(forKey key: String) -> Data? {
        defaults.data(forKey: namespaced(key))
    }

    public func set(_ data: Data?, forKey key: String) {
        defaults.set(data, forKey: namespaced(key))
    }

    private func namespaced(_ key: String) -> String {
        "\(namespace).\(key)"
    }
}

public final class InMemoryKeyValueStore: KeyValueStore {
    private var storage: [String: Data] = [:]

    public init() {}

    public func data(forKey key: String) -> Data? {
        storage[key]
    }

    public func set(_ data: Data?, forKey key: String) {
        storage[key] = data
    }
}
