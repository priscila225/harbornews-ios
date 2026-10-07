import Foundation

/// The single state every screen renders from.
public enum ViewState<Model> {
    case idle
    case loading
    case success(Model)
    case error(String)
}

/// Equality compares only the case, not the payload, so state publishers do not re-render for identical phases.
/// Tests that care about the payload must pattern match.
extension ViewState: Equatable {
    public static func == (lhs: ViewState<Model>, rhs: ViewState<Model>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.success, .success), (.error, .error):
            return true
        default:
            return false
        }
    }
}
