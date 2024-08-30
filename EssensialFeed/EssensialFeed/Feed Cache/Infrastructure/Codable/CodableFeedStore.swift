//
//  CodableFeedStore.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 3/22/24.
//

import Foundation

public class CodableFeedStore: FeedStore {
    private struct CodableFeed: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date

        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }

    private struct CodableFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL

        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }

        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }

    private let storeURL: URL

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }

    public func retrieve() throws -> CachedFeed? {
        guard let data = try? Data(contentsOf: self.storeURL) else {
            return nil
        }

        let cache = try JSONDecoder().decode(CodableFeed.self, from: data)
        return CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        let encoder = JSONEncoder()
        let cache = CodableFeed(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try encoder.encode(cache)
        try encoded.write(to: self.storeURL)
    }

    public func deleteCachedFeed() throws {
        guard FileManager.default.fileExists(atPath: self.storeURL.path) else {
            return
        }

        try FileManager.default.removeItem(at: self.storeURL)
    }
}
