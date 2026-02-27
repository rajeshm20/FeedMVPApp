# FeedMVP (iOS)

This is an MVP SwiftUI feed that implements pagination + infinite scrolling from the Medium guide.

## What is implemented

- Page-based loading (`page` + `pageSize`)
- Infinite scroll trigger when the user reaches the last few rows (`prefetchWindow`)
- Load guards to prevent duplicate concurrent fetches (`isLoading`, `canLoadMore`)
- Initial loading, load-more footer, retry-on-error, and end-of-feed UI states
- Pull-to-refresh to reset and reload from page 0
- ID de-duplication across pages to avoid repeated rows
- Data source from bundled JSON feed (`Resources/feed.json`)

## Files

- `FeedMVP/FeedMVPApp.swift`
- `FeedMVP/Models/FeedItem.swift`
- `FeedMVP/Services/FeedRepository.swift`
- `FeedMVP/ViewModels/FeedViewModel.swift`
- `FeedMVP/Views/*`
- `FeedMVP/Resources/feed.json`

## Run in Xcode

1. Create a new iOS App project in Xcode named `FeedMVP` (SwiftUI lifecycle).
2. Replace the generated Swift files with files from `iOSFeedMVP/FeedMVP`.
3. Add `feed.json` to the app target (check "Copy items if needed" and target membership).
4. Build and run on iOS Simulator.

## Tuning

- Change page size in `FeedViewModel` initializer (`pageSize`, default `20`).
- Change infinite-scroll trigger distance with `prefetchWindow` (default `5`).
