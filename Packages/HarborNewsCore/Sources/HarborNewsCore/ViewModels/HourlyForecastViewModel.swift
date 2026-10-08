import Combine
import Foundation

/// Drives the hourly forecast row. The forecast refreshes on demand, on a timer owned by the service,
/// and while the screen is open through `startPolling()`.
public final class HourlyForecastViewModel: ObservableObject {
    @Published public private(set) var forecast: [HourlyEntry] = []

    private let service: HourlyForecastService
    private let pollInterval: TimeInterval
    private var cancellables = Set<AnyCancellable>()

    public init(service: HourlyForecastService = AppDependencies.shared.hourlyService, pollInterval: TimeInterval = 60) {
        self.service = service
        self.pollInterval = pollInterval
        service.forecastPublisher()
            .assign(to: \.forecast, on: self)
            .store(in: &cancellables)
    }

    public func refresh() {
        Task.detached { [service, weak self] in
            guard let entries = try? await service.fetch() else { return }
            self?.forecast = entries
        }
    }

    public func startPolling() async {
        while !Task.isCancelled {
            refresh()
            try? await Task.sleep(nanoseconds: UInt64(pollInterval * 1_000_000_000))
        }
    }
}
