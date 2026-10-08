import Foundation

public struct HourlyEntry: Equatable, Identifiable {
    public let hour: Int
    public let temperatureF: Int
    public var id: Int { hour }

    public init(hour: Int, temperatureF: Int) {
        self.hour = hour
        self.temperatureF = temperatureF
    }
}
