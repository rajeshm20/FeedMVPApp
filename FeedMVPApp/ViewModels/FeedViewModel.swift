//
//  FeedViewModel.swift
//  FeedViewModel
//
//  Created by Rajesh Mani on 27/02/26.
//

import Foundation
internal import Combine

@MainActor
final class FeedViewModel: ObservableObject {
    enum LoadState: Equatable {
        case idle
        case initialLoading
        case loadingMore
        case endReached
        case failed(String)
    }

    @Published private(set) var items: [FeedItem] = []
    @Published private(set) var state: LoadState = .idle

    private let repository: FeedRepository
    private let pageSize: Int
    private let prefetchWindow: Int

    private var nextPage = 0
    private var canLoadMore = true
    private var isLoading = false
    private var seenIDs = Set<Int>()

    init(
        repository: FeedRepository? = nil,
        pageSize: Int = 20,
        prefetchWindow: Int = 5
    ) {
        self.repository = repository ?? JSONFeedRepository()
        self.pageSize = pageSize
        self.prefetchWindow = prefetchWindow
    }

    var showsLoadingFooter: Bool {
        state == .loadingMore && !items.isEmpty
    }

    var showsEndOfFeed: Bool {
        state == .endReached && !items.isEmpty
    }

    func loadInitialIfNeeded() {
        guard items.isEmpty else { return }
        Task {
            await refresh()
        }
    }

    func refresh() async {
        nextPage = 0
        canLoadMore = true
        isLoading = false
        seenIDs.removeAll()
        items.removeAll(keepingCapacity: true)
        state = .initialLoading

        await loadNextPage()
    }

    func retry() {
        Task {
            await loadNextPage()
        }
    }

    func loadMoreIfNeeded(currentItem: FeedItem) {
        guard shouldPrefetch(afterSeeing: currentItem) else { return }
        Task {
            await loadNextPage()
        }
    }

    private func shouldPrefetch(afterSeeing item: FeedItem) -> Bool {
        guard canLoadMore, !isLoading else { return false }
        guard let currentIndex = items.firstIndex(where: { $0.id == item.id }) else { return false }

        let thresholdIndex = max(items.count - prefetchWindow, 0)
        return currentIndex >= thresholdIndex
    }

    private func loadNextPage() async {
        guard canLoadMore, !isLoading else { return }

        isLoading = true
        if items.isEmpty {
            state = .initialLoading
        } else {
            state = .loadingMore
        }

        do {
            let page = try await repository.fetchPage(page: nextPage, pageSize: pageSize)
            let uniqueItems = page.items.filter { seenIDs.insert($0.id).inserted }

            items.append(contentsOf: uniqueItems)
            nextPage += 1
            canLoadMore = page.hasMore

            state = canLoadMore ? .idle : .endReached
        } catch {
            state = .failed(error.localizedDescription)
        }

        isLoading = false
    }
}
