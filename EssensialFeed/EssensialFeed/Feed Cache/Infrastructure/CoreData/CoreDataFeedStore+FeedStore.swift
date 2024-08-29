//
//  CoreDataFeedStore+FeedStore.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 6/5/24.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    public func retrieve(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedFeed.find(in: context).map {
                    return CachedFeed(feed: $0.localFeedImages, timestamp: $0.timestamp)
                }
            })
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedFeed.createUniqueFeed(in: context, timestamp: timestamp, feed: feed)
                try context.save()
            })
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedFeed.find(in: context)
                    .map(context.delete)
                    .map(context.save)
            })
        }
    }
}
