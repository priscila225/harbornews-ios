import Foundation
import Testing
@testable import HarborNewsCore

@Suite("WeatherViewModel")
@MainActor
struct WeatherViewModelTests {
    @Test func publishesConditionsOnSuccess() async {
        let conditions = Conditions(temperatureF: 72, summary: "Sunny")
        let viewModel = WeatherViewModel(service: StubWeatherService(result: .success(conditions)))

        await viewModel.refresh()

        guard case .success(let value) = viewModel.state else {
            Issue.record("expected success")
            return
        }
        #expect(value == conditions)
    }

    @Test func publishesAnErrorOnFailure() async {
        let viewModel = WeatherViewModel(service: StubWeatherService(result: .failure(WeatherError.noTemperature)))

        await viewModel.refresh()

        #expect(viewModel.state == .error(""))
    }
}
