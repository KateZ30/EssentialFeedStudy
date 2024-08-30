//
//  FeedStoreSpy.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 2/27/24.
//

import Foundation
import EssensialFeed

class FeedStoreSpy: FeedStore {
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<CachedFeed?, Error>?

    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }

    private(set) var receivedMessages = [ReceivedMessage]()

    func deleteCachedFeed() throws {
        receivedMessages.append(.deleteCachedFeed)
        try deletionResult?.get()
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        receivedMessages.append(.insert(feed, timestamp))
        try insertionResult?.get()
    }

    func retrieve() throws -> CachedFeed? {
        receivedMessages.append(.retrieve)
        return try retrievalResult?.get()
    }

    func completeDeletion(with error: NSError, at index: Int = 0) {
        deletionResult = .failure(error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionResult = .success(())
    }

    func completeInsertion(with error: NSError, at index: Int = 0) {
        insertionResult = .failure(error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }

    func completeRetrieval(with error: NSError, at index: Int = 0) {
        retrievalResult = .failure(error)
    }

    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalResult = .success(nil)
    }

    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalResult = .success(CachedFeed(feed: feed, timestamp: timestamp))
    }
}
