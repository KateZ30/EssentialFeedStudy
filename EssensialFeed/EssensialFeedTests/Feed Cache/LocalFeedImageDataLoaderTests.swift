//
//  LocalFeedImageDataLoaderTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 5/21/24.
//

import XCTest
import EssensialFeed

final class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_loadImageData_requestsStoreRetrieval() {
        let (store, sut) = makeSUT()
        let url = anyURL()

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve(from: url)])
    }

    func test_loadImageData_failsOnStoreError() {
        let (store, sut) = makeSUT()

        expect(sut, toCompleteWith: failed()) {
            store.complete(with: anyNSError())
        }
    }

    func test_loadImageData_deliversNotFoundErrorOnNotFound() {
        let (store, sut) = makeSUT()

        expect(sut, toCompleteWith: notFound()) {
            store.complete(with: .none)
        }
    }

    func test_loadImageData_deliversFoundDataOnFoundData() {
        let (store, sut) = makeSUT()
        let foundData = anyData()

        expect(sut, toCompleteWith: .success(foundData)) {
            store.complete(with: foundData)
        }
    }

    func test_loadImageData_doesNotDeliverResultAfterCancellingTask() {
        let (store, sut) = makeSUT()
        let foundData = anyData()

        var received = [FeedImageDataLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()

        store.complete(with: foundData)
        store.complete(with: .none)
        store.complete(with: anyNSError())

        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }

    func test_loadImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = StoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)

        var received = [FeedImageDataLoader.Result]()
        _ = sut?.loadImageData(from: anyURL()) { received.append($0) }

        sut = nil
        store.complete(with: .none)

        XCTAssertTrue(received.isEmpty, "Expected no received results after instance has been deallocated")
    }

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: StoreSpy, sut: LocalFeedImageDataLoader) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }

    private func failed() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }

    private func notFound() -> FeedImageDataLoader.Result {
        return .failure(LocalFeedImageDataLoader.Error.notFound)
    }


    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private class StoreSpy: FeedImageDataStore {
        enum Message: Equatable {
            case retrieve(from: URL)
        }
        private(set) var receivedMessages = [Message]()
        private var completions = [(FeedImageDataStore.Result) -> Void]()

        func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.Result) -> Void) {
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
}
