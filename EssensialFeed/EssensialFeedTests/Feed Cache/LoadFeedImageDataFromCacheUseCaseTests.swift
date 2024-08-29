//
//  LocalFeedImageDataLoaderTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 5/21/24.
//

import XCTest
import EssensialFeed

final class LoadFeedImageDataFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_loadImageData_requestsStoreRetrieval() {
        let (store, sut) = makeSUT()
        let url = anyURL()

        _ = try? sut.loadImageData(from: url)

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

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedImageDataStoreSpy, sut: LocalFeedImageDataLoader) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }

    private func failed() -> Result<Data, Error> {
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }

    private func notFound() -> Result<Data, Error> {
        return .failure(LocalFeedImageDataLoader.Error.notFound)
    }


    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Data, Error>, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {

        action()

        let receivedResult = Result {
            try sut.loadImageData(from: anyURL())
        }
        switch (receivedResult, expectedResult) {
        case let (.success(receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
            XCTFail("Expected \(expectedResult), got \(receivedResult)", file: file, line: line)
        }
    }
}
