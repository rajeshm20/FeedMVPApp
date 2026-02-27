import SwiftUI

struct LoadingFooterView: View {
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("Loading more...")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
    }
}
