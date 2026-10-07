import Foundation

/// Production wiring. View models take protocol-typed dependencies whose defaults come from here.
public final class AppDependencies {
    public static let shared = AppDependencies()

    public let articleRepository: ArticleRepository
    public let weatherService: WeatherService
    public let keyValueStore: KeyValueStore
    public let adsSelector: AdsSelector

    public init(
        articleRepository: ArticleRepository = URLSessionArticleRepository(),
        weatherService: WeatherService = URLSessionWeatherService(),
        keyValueStore: KeyValueStore = UserDefaultsStore(),
        adsSelector: AdsSelector = AdsSelector()
    ) {
        self.articleRepository = articleRepository
        self.weatherService = weatherService
        self.keyValueStore = keyValueStore
        self.adsSelector = adsSelector
    }
}
