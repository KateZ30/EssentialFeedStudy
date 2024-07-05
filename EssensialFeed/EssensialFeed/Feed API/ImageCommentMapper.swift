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

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteImageCommentsLoader.Error.invalidData
        }

        return root.items
    }

}

private extension HTTPURLResponse {
    var isOK: Bool {
        (200...299).contains(statusCode)
    }
}
