import Foundation

public enum WeatherError: Error, Equatable {
    case noTemperature
}

public protocol WeatherService {
    func current() async throws -> Conditions
}

public final class URLSessionWeatherService: WeatherService {
    private struct Payload: Decodable {
        let tempF: Double?
        let summary: String?
    }

    private let client: HTTPClient
    private let config: APIConfig

    public init(client: HTTPClient = URLSessionHTTPClient(), config: APIConfig = .default) {
        self.client = client
        self.config = config
    }

    public func current() async throws -> Conditions {
        let url = config.url(path: "stations/\(config.stationID)/weather/current")
        let payload = try JSONDecoder().decode(Payload.self, from: try await client.data(from: url))
        guard let temperature = payload.tempF else { throw WeatherError.noTemperature }
        return Conditions(temperatureF: Int(temperature.rounded()), summary: payload.summary ?? "")
    }
}
