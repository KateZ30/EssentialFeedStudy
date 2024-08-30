//
//  LocalFeedImageDataLoader.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 5/23/24.
//

import Foundation

public class LocalFeedImageDataLoader: FeedImageDataLoader {
    private var store: FeedImageDataStore

    public enum Error: Swift.Error {
        case notFound
        case failed
    }

    public init(store: FeedImageDataStore) {
        self.store = store
    }

    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let data = try store.retrieve(dataForURL: url) {
                return data
            }
        } catch {
            throw Error.failed
        }

        throw Error.notFound
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw Error.failed
        }
    }
}
