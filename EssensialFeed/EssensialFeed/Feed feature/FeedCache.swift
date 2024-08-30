//
//  FeedCache.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 6/17/24.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
