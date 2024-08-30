//
//  FeedStore.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 2/26/24.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionResult = Result<Void, Error>
    typealias DeletionCompletion = (DeletionResult) -> Void

    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrivalResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrivalResult) -> Void

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed() throws

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve() throws -> CachedFeed?
}
