import Foundation

public enum ShareLinkBuilder {
    /// The URL handed to the system share sheet, tagged with where the share came from.
    public static func url(for detail: ArticleDetail) -> URL {
        let base = URL(string: detail.shareURL)!
        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        let existing = components?.queryItems ?? []
        components?.queryItems = existing + [URLQueryItem(name: "utm_source", value: "ios_share")]
        return components?.url ?? base
    }
}
