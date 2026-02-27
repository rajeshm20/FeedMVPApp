import SwiftUI

struct PostCard: View {
    let post: FeedItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: post.imageURL) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.18))
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.18))
                        .overlay {
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        }
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.18))
                }
            }
            .frame(height: 190)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(post.title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(post.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Text(post.createdAt, style: .date)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}
