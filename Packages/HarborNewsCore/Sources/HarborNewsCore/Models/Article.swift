import Foundation

public struct Article: Equatable, Identifiable, Codable {
    public let id: String
    public let title: String
    public let summary: String
    public let section: String
    public let imageURL: URL?
    public let shareURL: String?
    public let publishedAt: Date?

    public init(
        id: String,
        title: String,
        summary: String = "",
        section: String = "top",
        imageURL: URL? = nil,
        shareURL: String? = nil,
        publishedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.section = section
        self.imageURL = imageURL
        self.shareURL = shareURL
        self.publishedAt = publishedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, summary, section, publishedAt
        case imageURL = "imageUrl"
        case shareURL = "shareUrl"
    }

    /// Lenient decoding: only `id` and `title` are required, everything else falls back to a default.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decodeIfPresent(String.self, forKey: .summary) ?? ""
        section = try container.decodeIfPresent(String.self, forKey: .section) ?? "top"
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL).flatMap { URL(string: $0) }
        shareURL = try container.decodeIfPresent(String.self, forKey: .shareURL)
        publishedAt = try container.decodeIfPresent(Double.self, forKey: .publishedAt)
            .map { Date(timeIntervalSince1970: $0 / 1000) }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(summary, forKey: .summary)
        try container.encode(section, forKey: .section)
        try container.encodeIfPresent(imageURL?.absoluteString, forKey: .imageURL)
        try container.encodeIfPresent(shareURL, forKey: .shareURL)
        try container.encodeIfPresent(publishedAt.map { $0.timeIntervalSince1970 * 1000 }, forKey: .publishedAt)
    }
}

public struct Conditions: Equatable {
    public let temperatureF: Int
    public let summary: String

    public init(temperatureF: Int, summary: String) {
        self.temperatureF = temperatureF
        self.summary = summary
    }
}
