//
//  InMemoryFeedStore.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 8/30/24.
//

import Foundation

public class InMemoryFeedStore: FeedStore, FeedImageDataStore {
    private(set) var feed: CachedFeed?
    private var feedImageData = [URL: Data]()

    private init(feed: CachedFeed? = nil) {
        self.feed = feed
    }

    public func deleteCachedFeed() throws {
        feed = nil
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        self.feed = CachedFeed(feed: feed, timestamp: timestamp)
    }

    public func retrieve() throws -> CachedFeed? {
        return feed
    }

    public func insert(_ data: Data, for url: URL) throws {
        feedImageData[url] = data
    }

    public func retrieve(dataForURL url: URL) throws -> Data? {
        return feedImageData[url]
    }

    public static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
}
