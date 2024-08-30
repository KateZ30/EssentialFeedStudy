//
//  FeedImageDataStoreSpy.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 5/23/24.
//

import Foundation
import EssensialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case retrieve(from: URL)
        case insert(data: Data, for: URL)
    }
    private(set) var receivedMessages = [Message]()
    private var retrieveResult: Result<Data?, Error>?
    private var insertResult: Result<Void, Error>?

    func insert(_ data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertResult?.get()
    }

    func retrieve(dataForURL url: URL) throws -> Data? {
        receivedMessages.append(.retrieve(from: url))
        return try retrieveResult?.get()
    }

    func complete(with error: Error, at index: Int = 0) {
        retrieveResult = .failure(error)
    }

    func complete(with data: Data?, at index: Int = 0) {
        retrieveResult = .success(data)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertResult = .failure(error)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertResult = .success(())
    }
}
