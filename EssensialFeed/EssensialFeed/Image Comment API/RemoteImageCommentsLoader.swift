//
//  RemoteImageCommentsLoader.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 7/5/24.
//

import Foundation

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentMapper.map)
    }
}
