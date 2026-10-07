import Combine
import Foundation

public protocol HourlyForecastService {
    func fetch() async throws -> [HourlyEntry]
    /// Emits a fresh forecast on every refresh interval for as long as it has a subscriber.
    func forecastPublisher() -> AnyPublisher<[HourlyEntry], Never>
}

public final class URLSessionHourlyForecastService: HourlyForecastService {
    private struct Row: Decodable {
        let hour: Int?
        let tempF: Double?
    }

    private let client: HTTPClient
    private let config: APIConfig
    private let refreshInterval: TimeInterval

    public init(client: HTTPClient = URLSessionHTTPClient(), config: APIConfig = .default, refreshInterval: TimeInterval = 300) {
        self.client = client
        self.config = config
        self.refreshInterval = refreshInterval
    }

    public func fetch() async throws -> [HourlyEntry] {
        let url = config.url(path: "stations/\(config.stationID)/weather/hourly")
        let rows = try JSONDecoder().decode([Row].self, from: try await client.data(from: url))
        return rows.compactMap { row in
            guard let hour = row.hour, let temperature = row.tempF else { return nil }
            return HourlyEntry(hour: hour, temperatureF: Int(temperature.rounded()))
        }
    }

    public func forecastPublisher() -> AnyPublisher<[HourlyEntry], Never> {
        Timer.publish(every: refreshInterval, on: .main, in: .common)
            .autoconnect()
            .flatMap { [self] _ in
                Future<[HourlyEntry], Never> { promise in
                    Task { promise(.success((try? await self.fetch()) ?? [])) }
                }
            }
            .eraseToAnyPublisher()
    }
}
