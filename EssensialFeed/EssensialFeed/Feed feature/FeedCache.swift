//
//  FeedCache.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 6/17/24.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
