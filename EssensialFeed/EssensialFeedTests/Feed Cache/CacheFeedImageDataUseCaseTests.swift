//
//  CacheFeedimageDataUseCaseTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 5/23/24.
//

import XCTest
import EssensialFeed

class CacheFeedimageDataUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_saveImageData_requestsStoreInsertionWithExpectedData() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()

        try? sut.save(data, for: url)

        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }

    func test_saveImageData_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: failed()) {
            store.completeInsertion(with: anyNSError())
        }
    }

    func test_saveImageData_succeedsOnStoreInsertionSuccess() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(())) {
            store.completeInsertionSuccessfully()
        }
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func failed() -> Result<Void, Error> {
        return .failure(LocalFeedImageDataLoader.Error.failed)
    }

    private func expect(_ sut: LocalFeedImageDataLoader, toCompleteWith expectedResult: Result<Void, Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        action()

        let receivedResult = Result {
            try sut.save(anyData(), for: anyURL())
        }
        switch (receivedResult, expectedResult) {
        case (.success, .success):
            break
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
}

