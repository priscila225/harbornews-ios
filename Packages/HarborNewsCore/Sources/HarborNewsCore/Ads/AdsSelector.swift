import Foundation

public protocol AdsManager: AnyObject {
    /// Returns true when an ad request was started for the placement.
    func loadBanner(placement: String) -> Bool
}

public enum AdsProvider {
    case none
    case banner
}

final class NoAdsManager: AdsManager {
    func loadBanner(placement: String) -> Bool { false }
}

final class BannerAdsManager: AdsManager {
    private(set) var requestedPlacements: [String] = []

    func loadBanner(placement: String) -> Bool {
        requestedPlacements.append(placement)
        return true
    }
}

/// Picks the manager for a configured provider so providers can be swapped without touching screens.
public struct AdsSelector {
    public init() {}

    public func manager(for provider: AdsProvider) -> AdsManager {
        switch provider {
        case .none: return NoAdsManager()
        case .banner: return BannerAdsManager()
        }
    }
}
