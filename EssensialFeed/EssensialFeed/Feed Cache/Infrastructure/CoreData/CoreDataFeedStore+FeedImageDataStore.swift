//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 6/5/24.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertResult) -> Void) {
        perform { context in
            completion(Result {
                guard let image = try ManagedFeedImage.first(with: url, in: context) else { return }
                image.data = data
                try context.save()
            })
        }

    }

    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)?.data
            })
        }
    }
}
