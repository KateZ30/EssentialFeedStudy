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
        try makeSUT { sut in
            self.expect(sut, toCompleteWith: self.notFound(), for: anyURL())
        }
    }

    func test_retieveImageData_deliversNotFoundWhenURLDoesNotMatchToStored() throws {
        try makeSUT { sut in
            let url = URL(string: "http://a-url.com")!
            let anotherURL = URL(string: "http://another-url.com")!

            self.insert(anyData(), for: url, into: sut)

            self.expect(sut, toCompleteWith: self.notFound(), for: anotherURL)
        }
    }

    func test_retriveImageData_deliversFoundDataOnURLMatch() throws {
        try makeSUT { sut in
            let url = anyURL()
            let data = anyData()

            self.insert(data, for: url, into: sut)

            self.expect(sut, toCompleteWith: self.found(data), for: url)
        }
    }

    func test_retrieveImageData_deliversLastInsertedDataOnMultipleInsertions() throws {
        try makeSUT { sut in
            let url = anyURL()
            let firstData = Data("first".utf8)
            let lastData = Data("last".utf8)

            self.insert(firstData, for: url, into: sut)
            self.insert(lastData, for: url, into: sut)

            self.expect(sut, toCompleteWith: self.found(lastData), for: url)
        }
    }

    // MARK: - Helpers
    private func makeSUT(_ test: @escaping (CoreDataFeedStore) -> Void,
                         file: StaticString = #filePath, line: UInt = #line) throws {
        let sut = try CoreDataFeedStore(storeURL: inMemoryStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)

        let exp = expectation(description: "Wait for operation")
        sut.perform {
            test(sut)
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
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
        do {
            try store.insert([localImage(url: url)], timestamp: Date())
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
