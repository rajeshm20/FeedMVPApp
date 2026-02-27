import Foundation

struct FeedItem: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let imageURL: URL?
    let createdAt: Date
}
