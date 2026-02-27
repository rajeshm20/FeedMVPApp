import Foundation

struct Pagination: Codable {
    let nextCursor: String?
    let hasMore: Bool
}

struct PaginatedResponse<T: Codable>: Codable {
    let data: [T]
    let pagination: Pagination
}

protocol FeedRepository {
    func fetchPosts(cursor: String?, limit: Int) async throws -> PaginatedResponse<FeedItem>
}

enum FeedRepositoryError: Error, LocalizedError {
    case missingResource
    case corruptedData
    case invalidCursor

    var errorDescription: String? {
        switch self {
        case .missingResource:
            return "Could not find bundled feed.json"
        case .corruptedData:
            return "Feed data is invalid"
        case .invalidCursor:
            return "Cursor is invalid"
        }
    }
}

final class JSONFeedRepository: FeedRepository {
    private struct CursorPayload: Codable {
        let index: Int
    }

    private struct FeedSeed: Codable {
        let data: [FeedItem]
        let pagination: Pagination
    }

    private let bundle: Bundle
    private let resourceName: String
    private var cachedSeed: FeedSeed?

    init(bundle: Bundle = .main, resourceName: String = "feed") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func fetchPosts(cursor: String?, limit: Int) async throws -> PaginatedResponse<FeedItem> {
        let seed = try loadFeedSeed()
        let items = seed.data

        // Simulate API latency so loading/prefetch behavior is visible.
        try await Task.sleep(for: .milliseconds(250))

        let startIndex = try decodeCursor(cursor)
        guard startIndex <= items.count else {
            throw FeedRepositoryError.invalidCursor
        }

        let endIndex = min(startIndex + limit, items.count)
        let pageItems = Array(items[startIndex..<endIndex])

        let hasMore = endIndex < items.count
        let nextCursor = hasMore ? encodeCursor(endIndex) : nil

        return PaginatedResponse(
            data: pageItems,
            pagination: Pagination(nextCursor: nextCursor, hasMore: hasMore)
        )
    }

    private func loadFeedSeed() throws -> FeedSeed {
        if let cachedSeed {
            return cachedSeed
        }

        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw FeedRepositoryError.missingResource
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let seed = try decoder.decode(FeedSeed.self, from: data)
            cachedSeed = seed
            return seed
        } catch {
            throw FeedRepositoryError.corruptedData
        }
    }

    private func encodeCursor(_ value: Int) -> String {
        let payload = CursorPayload(index: value)
        let data = (try? JSONEncoder().encode(payload)) ?? Data()
        return data.base64EncodedString()
    }

    private func decodeCursor(_ cursor: String?) throws -> Int {
        guard let cursor else { return 0 }

        guard let rawData = Data(base64Encoded: cursor) else {
            throw FeedRepositoryError.invalidCursor
        }

        guard
            let payload = try? JSONDecoder().decode(CursorPayload.self, from: rawData),
            payload.index >= 0
        else {
            throw FeedRepositoryError.invalidCursor
        }

        return payload.index
    }
}
