//
//  LocalFeedImageDataLoader.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 5/23/24.
//

import Foundation

public class LocalFeedImageDataLoader: FeedImageDataLoader {
    private final class Task: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?

        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            self.completion = nil
        }
    }

    private var store: FeedImageDataStore

    public enum Error: Swift.Error {
        case notFound
        case failed
    }

    public init(store: FeedImageDataStore) {
        self.store = store
    }

    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion)

        task.complete(
            with: Swift.Result {
                try store.retrieve(dataForURL: url)
            }
            .mapError { _ in Error.failed }
            .flatMap { data in
                data.map { .success($0) } ?? .failure(Error.notFound)
            })
        return task
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public typealias SaveResult = FeedImageDataCache.Result

    public func save(_ data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        completion(SaveResult {
            try store.insert(data, for: url)
        }.mapError{ _ in Error.failed })
    }
}
