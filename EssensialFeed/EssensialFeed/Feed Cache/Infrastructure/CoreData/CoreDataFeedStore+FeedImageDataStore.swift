//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 6/5/24.
//

import Foundation

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertResult) -> Void) {
    }

    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
        completion(.success(.none))
    }
}
