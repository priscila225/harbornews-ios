import Combine
import Foundation

/// Drives a SwiftUI view, so every mutation of published state happens on the main actor.
@MainActor
public final class WeatherViewModel: ObservableObject {
    @Published public private(set) var state: ViewState<Conditions> = .idle

    private let service: WeatherService

    public init(service: WeatherService = AppDependencies.shared.weatherService) {
        self.service = service
    }

    public func refresh() async {
        state = .loading
        do {
            state = .success(try await service.current())
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
