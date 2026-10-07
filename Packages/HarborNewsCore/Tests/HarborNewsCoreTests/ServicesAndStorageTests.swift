import Foundation
import Testing
@testable import HarborNewsCore

@Suite("Services and storage")
struct ServicesAndStorageTests {
    @Test func weatherServiceRoundsTheTemperature() async throws {
        let json = #"{"tempF":71.6,"summary":"Sunny"}"#
        let service = URLSessionWeatherService(client: StubHTTPClient(result: .success(Data(json.utf8))))

        let conditions = try await service.current()

        #expect(conditions == Conditions(temperatureF: 72, summary: "Sunny"))
    }

    @Test func weatherServiceRejectsAReadingWithoutATemperature() async {
        let service = URLSessionWeatherService(client: StubHTTPClient(result: .success(Data(#"{"summary":"x"}"#.utf8))))

        await #expect(throws: WeatherError.noTemperature) {
            try await service.current()
        }
    }

    @Test func keyValueStoreNamespacesKeys() throws {
        let suite = try #require(UserDefaults(suiteName: "harbornews.tests.\(UUID().uuidString)"))
        let store = UserDefaultsStore(defaults: suite, namespace: "ns")

        store.set(Data([1, 2]), forKey: "k")

        #expect(store.data(forKey: "k") == Data([1, 2]))
        #expect(suite.data(forKey: "ns.k") == Data([1, 2]))
        #expect(suite.data(forKey: "k") == nil)
    }

    @Test func adsSelectorReturnsADifferentManagerPerProvider() {
        let selector = AdsSelector()

        #expect(selector.manager(for: .none).loadBanner(placement: "top") == false)
        #expect(selector.manager(for: .banner).loadBanner(placement: "top") == true)
    }

    @Test func apiConfigBuildsStationScopedURLs() throws {
        let base = try #require(URL(string: "https://api.example"))
        let url = APIConfig(baseURL: base, stationID: "s1")
            .url(path: "stations/s1/headlines", query: [URLQueryItem(name: "section", value: "local")])

        #expect(url.absoluteString == "https://api.example/stations/s1/headlines?section=local")
    }
}
