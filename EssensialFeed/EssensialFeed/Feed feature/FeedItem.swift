//
//  FeedItem.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 2/20/24.
//

import Foundation

public struct FeedItem: Equatable, Decodable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL

    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

extension FeedItem {
    enum CodingKeys: String, CodingKey {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
