//
//  FeedItemMapper.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 2/20/24.
//

import Foundation

public class FeedItemsMapper {
    struct Root: Decodable {
        private let items: [RemoteFeedItem]

        private struct RemoteFeedItem: Decodable {
            public let id: UUID
            public let description: String?
            public let location: String?
            public let image: URL
        }

        var feed: [FeedImage] {
            return items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
        }
    }

    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.isOK200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }

        return root.feed
    }
}
