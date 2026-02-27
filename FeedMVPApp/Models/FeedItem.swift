//
//  FeedItem.swift
//  FeedItem
//
//  Created by Rajesh Mani on 27/02/26.
//

import Foundation

struct FeedItem: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let createdAt: Date
}
