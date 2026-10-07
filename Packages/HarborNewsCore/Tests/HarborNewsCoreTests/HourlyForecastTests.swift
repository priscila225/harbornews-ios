import Combine
import Foundation
import Testing
@testable import HarborNewsCore

@Suite("Hourly forecast")
struct HourlyForecastTests {
    private let sample = [HourlyEntry(hour: 9, temperatureF: 61), HourlyEntry(hour: 10, temperatureF: 64)]

    @Test func serviceDropsRowsMissingAnHourOrTemperature() async throws {
        let json = #"[{"hour":9,"tempF":61.4},{"hour":10},{"tempF":70},{"hour":11,"tempF":64.6}]"#
        let service = URLSessionHourlyForecastService(client: StubHTTPClient(result: .success(Data(json.utf8))))

        let entries = try await service.fetch()

        #expect(entries == [HourlyEntry(hour: 9, temperatureF: 61), HourlyEntry(hour: 11, temperatureF: 65)])
    }

    @Test(.timeLimit(.minutes(1)))
    func refreshPublishesTheForecast() async {
        let viewModel = HourlyForecastViewModel(service: StubHourlyService(entries: .success(sample)))

        viewModel.refresh()
        for await forecast in viewModel.$forecast.values where !forecast.isEmpty {
            #expect(forecast == sample)
            break
        }
    }

    @Test func aFailedRefreshKeepsTheCurrentForecast() async throws {
        let viewModel = HourlyForecastViewModel(service: StubHourlyService(entries: .failure(TestError())))

        viewModel.refresh()
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(viewModel.forecast.isEmpty)
    }

    @Test(.timeLimit(.minutes(1)))
    func pollingRefreshesUntilCancelled() async {
        let viewModel = HourlyForecastViewModel(service: StubHourlyService(entries: .success(sample)), pollInterval: 0.01)
        let polling = Task { await viewModel.startPolling() }

        for await forecast in viewModel.$forecast.values where !forecast.isEmpty {
            break
        }
        polling.cancel()
        await polling.value

        #expect(viewModel.forecast == sample)
    }
}
