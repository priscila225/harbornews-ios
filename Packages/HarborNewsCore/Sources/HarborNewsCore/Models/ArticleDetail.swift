import Foundation

public struct ArticleDetail: Equatable, Decodable {
    public let id: String
    public let title: String
    public let body: String
    public let heroImageURL: URL?
    public let shareURL: String

    public init(id: String, title: String, body: String = "", heroImageURL: URL? = nil, shareURL: String = "") {
        self.id = id
        self.title = title
        self.body = body
        self.heroImageURL = heroImageURL
        self.shareURL = shareURL
    }

    private enum CodingKeys: String, CodingKey {
        case id, title
        case body = "bodyText"
        case heroImageURL = "heroImageUrl"
        case shareURL = "shareUrl"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decodeIfPresent(String.self, forKey: .body) ?? ""
        heroImageURL = try container.decodeIfPresent(String.self, forKey: .heroImageURL).flatMap { URL(string: $0) }
        shareURL = try container.decodeIfPresent(String.self, forKey: .shareURL) ?? ""
    }
}
