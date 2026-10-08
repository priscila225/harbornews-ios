import Foundation

public enum NewsSection: String, CaseIterable, Equatable {
    case top
    case local
    case sports

    public var title: String {
        switch self {
        case .top: return "Top"
        case .local: return "Local"
        case .sports: return "Sports"
        }
    }

    /// The value sent to the headlines endpoint; the top section is the unfiltered feed.
    public var query: String? {
        self == .top ? nil : rawValue
    }
}
