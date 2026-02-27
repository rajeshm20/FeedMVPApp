import Foundation
import Combine

@MainActor
final class FeedService: ObservableObject {
    @Published var posts: [FeedItem] = []
    @Published var isLoading = false
    @Published var hasMoreContent = true
    @Published var errorMessage: String?

    private var currentCursor: String?
    private let pageSize: Int
    private let prefetchThreshold: Int
    private let maxInMemoryItems: Int
    private let repository: FeedRepository
    private var seenIDs = Set<Int>()

    init(
        repository: FeedRepository? = nil,
        pageSize: Int = 20,
        prefetchThreshold: Int = 5,
        maxInMemoryItems: Int = 120
    ) {
        self.repository = repository ?? JSONFeedRepository()
        self.pageSize = pageSize
        self.prefetchThreshold = prefetchThreshold
        self.maxInMemoryItems = maxInMemoryItems
    }

    func loadInitialPosts() async {
        currentCursor = nil
        posts.removeAll(keepingCapacity: true)
        seenIDs.removeAll(keepingCapacity: true)
        hasMoreContent = true
        errorMessage = nil

        await loadMorePosts()
    }

    func loadMorePosts() async {
        // Debounce duplicate requests and stop once feed ends.
        guard !isLoading && hasMoreContent else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await repository.fetchPosts(cursor: currentCursor, limit: pageSize)

            let uniquePosts = response.data.filter { post in
                seenIDs.insert(post.id).inserted
            }

            posts.append(contentsOf: uniquePosts)
            trimIfNeeded()

            currentCursor = response.pagination.nextCursor
            hasMoreContent = response.pagination.hasMore
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func shouldPrefetch(for post: FeedItem) -> Bool {
        guard !isLoading && hasMoreContent else { return false }
        guard let index = posts.firstIndex(of: post) else { return false }

        return index >= max(posts.count - prefetchThreshold, 0)
    }

    private func trimIfNeeded() {
        let overflow = posts.count - maxInMemoryItems
        guard overflow > 0 else { return }

        let removed = posts.prefix(overflow)
        posts.removeFirst(overflow)

        for item in removed {
            seenIDs.remove(item.id)
        }
    }
}
