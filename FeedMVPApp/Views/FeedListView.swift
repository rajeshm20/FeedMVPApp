//
//  FeedListView.swift
//  FeedListView
//
//  Created by Rajesh Mani on 27/02/26.
//

import SwiftUI

struct FeedListView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.items.isEmpty && viewModel.state == .initialLoading {
                    ProgressView("Loading feed...")
                } else {
                    feedList
                }
            }
            .navigationTitle("Discover")
            .task {
                viewModel.loadInitialIfNeeded()
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    private var feedList: some View {
        List {
            ForEach(viewModel.items) { item in
                FeedRowView(item: item)
                    .onAppear {
                        viewModel.loadMoreIfNeeded(currentItem: item)
                    }
            }

            if viewModel.showsLoadingFooter {
                LoadingFooterView()
            }

            if case .failed(let message) = viewModel.state {
                ErrorFooterView(message: message) {
                    viewModel.retry()
                }
            }

            if viewModel.showsEndOfFeed {
                Text("You are all caught up")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    FeedListView()
}
