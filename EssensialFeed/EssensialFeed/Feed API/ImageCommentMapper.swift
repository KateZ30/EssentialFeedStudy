//
//  ImageCommentMapper.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 7/5/24.
//

import Foundation

class ImageCommentMapper {
    struct Root: Decodable {
        let items: [RemoteFeedItem]
    }

    private static var OK_200: Int { 200 }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }

        return root.items
    }

}
