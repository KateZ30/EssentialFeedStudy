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
    private var completions = [(FeedImageDataStore.RetrieveResult) -> Void]()

    func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
    }

    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
        receivedMessages.append(.retrieve(from: url))
        completions.append(completion)
    }

    func complete(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }

    func complete(with data: Data?, at index: Int = 0) {
        completions[index](.success(data))
    }
}
