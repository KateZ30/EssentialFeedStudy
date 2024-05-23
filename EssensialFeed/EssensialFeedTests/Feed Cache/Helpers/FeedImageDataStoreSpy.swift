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
    private var retrieveCompletions = [(FeedImageDataStore.RetrieveResult) -> Void]()
    private var insertCompletions = [(FeedImageDataStore.InsertResult) -> Void]()

    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertCompletions.append(completion)
    }

    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
        receivedMessages.append(.retrieve(from: url))
        retrieveCompletions.append(completion)
    }

    func complete(with error: Error, at index: Int = 0) {
        retrieveCompletions[index](.failure(error))
    }

    func complete(with data: Data?, at index: Int = 0) {
        retrieveCompletions[index](.success(data))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertCompletions[index](.failure(error))
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertCompletions[index](.success(()))
    }
}
