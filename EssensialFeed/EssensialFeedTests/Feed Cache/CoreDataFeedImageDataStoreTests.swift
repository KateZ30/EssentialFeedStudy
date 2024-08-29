//
//  CoreDataFeedImageDataStoreTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 5/23/24.
//

import XCTest
import EssensialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {
    func test_retrieveImageData_deliversNotFoundOnEmptyCache() throws {
        let sut = try makeSUT()

        expect(sut, toCompleteWith: notFound(), for: anyURL())
    }

    func test_retieveImageData_deliversNotFoundWhenURLDoesNotMatchToStored() throws {
        let sut = try makeSUT()
        let url = URL(string: "http://a-url.com")!
        let anotherURL = URL(string: "http://another-url.com")!

        insert(anyData(), for: url, into: sut)

        expect(sut, toCompleteWith: notFound(), for: anotherURL)
    }

    func test_retriveImageData_deliversFoundDataOnURLMatch() throws {
        let sut = try makeSUT()
        let url = anyURL()
        let data = anyData()

        insert(data, for: url, into: sut)

        expect(sut, toCompleteWith: found(data), for: url)
    }

    func test_retrieveImageData_deliversLastInsertedDataOnMultipleInsertions() throws {
        let sut = try makeSUT()
        let url = anyURL()
        let firstData = Data("first".utf8)
        let lastData = Data("last".utf8)

        insert(firstData, for: url, into: sut)
        insert(lastData, for: url, into: sut)

        expect(sut, toCompleteWith: found(lastData), for: url)
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

    private func notFound() -> Result<Data?, Error> {
        .success(.none)
    }

    private func found(_ data: Data) -> Result<Data?, Error> {
        .success(data)
    }

    private func localImage(url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), description: "any", location: "any", url: url)
    }

    private func insert(_ data: Data, for url: URL, into store: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache insertion")

        store.insert([localImage(url: url)], timestamp: Date()) { result in
            if case let .failure(error) = result {
                XCTFail("Expected image to be inserted successfully, got error: \(error)", file: file, line: line)
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
        do {
            try store.insert(data, for: url)
        } catch {
            XCTFail("Expected to insert data successfully, got error: \(error)", file: file, line: line)
        }
    }

    private func expect(_ sut: CoreDataFeedStore, toCompleteWith expectedResult: Result<Data?, Error>, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let receivedResult = Result { try sut.retrieve(dataForURL: url) }
        switch (receivedResult, expectedResult) {
        case let (.success(receivedData), .success(expectedData)):
            XCTAssertEqual(receivedData, expectedData, file: file, line: line)
        case (.failure, .failure):
            break
        default:
            XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }

}
