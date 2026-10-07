import Foundation

/// Production wiring. View models take protocol-typed dependencies whose defaults come from here.
public final class AppDependencies {
    public static let shared = AppDependencies()

    public let articleRepository: ArticleRepository
    public let weatherService: WeatherService
    public let hourlyService: HourlyForecastService
    public let keyValueStore: KeyValueStore
    public let adsSelector: AdsSelector

    public init(
        articleRepository: ArticleRepository = URLSessionArticleRepository(),
        weatherService: WeatherService = URLSessionWeatherService(),
        hourlyService: HourlyForecastService = URLSessionHourlyForecastService(),
        keyValueStore: KeyValueStore = UserDefaultsStore(),
        adsSelector: AdsSelector = AdsSelector()
    ) {
        self.articleRepository = articleRepository
        self.weatherService = weatherService
        self.hourlyService = hourlyService
        self.keyValueStore = keyValueStore
        self.adsSelector = adsSelector
    }
}
