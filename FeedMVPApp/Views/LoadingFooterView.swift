//
//  LoadingFooterView.swift
//  LoadingFooterView
//
//  Created by Rajesh Mani on 27/02/26.
//

import SwiftUI

struct LoadingFooterView: View {
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
            Text("Loading more...")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 12)
        .listRowSeparator(.hidden)
    }
}
