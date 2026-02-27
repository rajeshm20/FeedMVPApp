import SwiftUI

struct FeedListView: View {
    @StateObject private var service = FeedService()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(service.posts) { post in
                        PostCard(post: post)
                            .onAppear {
                                if service.shouldPrefetch(for: post) {
                                    Task {
                                        await service.loadMorePosts()
                                    }
                                }
                            }
                    }

                    if service.isLoading {
                        LoadingFooterView()
                    }

                    if let errorMessage = service.errorMessage {
                        ErrorFooterView(message: errorMessage) {
                            Task {
                                await service.loadMorePosts()
                            }
                        }
                    }

                    if !service.hasMoreContent && !service.posts.isEmpty {
                        Text("You are all caught up")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            .navigationTitle("Feed")
            .refreshable {
                await service.loadInitialPosts()
            }
            .task {
                if service.posts.isEmpty {
                    await service.loadInitialPosts()
                }
            }
        }
    }
}

#Preview {
    FeedListView()
}
