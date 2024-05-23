//
//  CoreDataFeedImageDataStoreTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 5/23/24.
//

import XCTest
import EssensialFeed

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertResult) -> Void) {
    }

    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrieveResult) -> Void) {
        completion(.success(.none))
    }
}

class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundOnEmptyCache() throws {
        let sut = try makeSUT()

        expect(sut, toCompleteWith: .success(.none), for: anyURL())
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) throws -> CoreDataFeedStore {
        let sut = try CoreDataFeedStore(storeURL: inMemoryStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func inMemoryStoreURL() -> URL {
        URL(fileURLWithPath: "/dev/null")
            .appendingPathComponent("\(type(of: self)).store")
    }

    private func expect(_ sut: CoreDataFeedStore, toCompleteWith expectedResult: FeedImageDataStore.RetrieveResult, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieve completion")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

}
