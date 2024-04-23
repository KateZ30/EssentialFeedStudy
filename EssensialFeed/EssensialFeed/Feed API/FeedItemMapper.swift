//
//  FeedItemMapper.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 2/20/24.
//

import Foundation

class FeedItemsMapper {
    struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static var OK_200: Int { 200 }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }

        return root.items
    }

}
