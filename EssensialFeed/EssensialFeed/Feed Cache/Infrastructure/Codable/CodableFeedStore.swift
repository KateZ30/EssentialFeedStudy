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
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)

    public init(storeURL: URL) {
        self.storeURL = storeURL
    }


    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            completion(Result {
                guard let data = try? Data(contentsOf: storeURL) else {
                    return nil
                }

                let cache = try JSONDecoder().decode(CodableFeed.self, from: data)
                return CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)
            })
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            completion(Result {
                let encoder = JSONEncoder()
                let cache = CodableFeed(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let encoded = try encoder.encode(cache)
                try encoded.write(to: storeURL)
            })
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            completion(Result {
                guard FileManager.default.fileExists(atPath: storeURL.path) else {
                    return
                }

                try FileManager.default.removeItem(at: storeURL)
            })
        }
    }
}
