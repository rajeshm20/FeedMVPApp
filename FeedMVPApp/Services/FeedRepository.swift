//
//  FeedRepository.swift
//  FeedRepository
//
//  Created by Rajesh Mani on 27/02/26.
//

import Foundation

struct FeedPage {
    let items: [FeedItem]
    let hasMore: Bool
}

protocol FeedRepository {
    func fetchPage(page: Int, pageSize: Int) async throws -> FeedPage
}

enum FeedRepositoryError: Error, LocalizedError {
    case missingResource
    case corruptedData

    var errorDescription: String? {
        switch self {
        case .missingResource:
            return "Could not find bundled feed.json"
        case .corruptedData:
            return "Feed data is invalid"
        }
    }
}

final class JSONFeedRepository: FeedRepository {
    private let bundle: Bundle
    private let resourceName: String
    private var cachedItems: [FeedItem]?

    init(bundle: Bundle = .main, resourceName: String = "feed") {
        self.bundle = bundle
        self.resourceName = resourceName
    }

    func fetchPage(page: Int, pageSize: Int) async throws -> FeedPage {
        let items = try loadFeedItems()

        // Simulate network latency so loading indicators and prefetch are visible.
        try await Task.sleep(for: .milliseconds(300))

        let start = page * pageSize
        guard start < items.count else {
            return FeedPage(items: [], hasMore: false)
        }

        let end = min(start + pageSize, items.count)
        let slice = Array(items[start..<end])

        return FeedPage(items: slice, hasMore: end < items.count)
    }

    private func loadFeedItems() throws -> [FeedItem] {
        if let cachedItems {
            return cachedItems
        }

        guard let url = bundle.url(forResource: resourceName, withExtension: "json") else {
            throw FeedRepositoryError.missingResource
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let items = try decoder.decode([FeedItem].self, from: data)
            cachedItems = items
            return items
        } catch {
            throw FeedRepositoryError.corruptedData
        }
    }
}
