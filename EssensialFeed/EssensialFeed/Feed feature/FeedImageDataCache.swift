//
//  FeedImageDataCache.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 6/24/24.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, for url: URL) throws
}
