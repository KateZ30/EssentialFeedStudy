//
//  CodableFeedStoreTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 3/4/24.
//

import XCTest
import EssensialFeed

class CodableFeedStore {
    private struct CodableFeed: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date

        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }

    private struct CodableFeedImage: Codable {
        let id: UUID
        let description: String?
        let location: String?
        let url: URL

        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }

        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }

    private let storeURL: URL

    init(storeURL: URL) {
        self.storeURL = storeURL
    }


    func retrieve(completion: @escaping FeedStore.RetrivalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }

        let decoder = JSONDecoder()
        let cache = try! decoder.decode(CodableFeed.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = CodableFeed(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_retrive_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for retrieval")

        sut.retrieve { result in
            sut.retrieve { result in
                switch result {
                case .empty:
                    break
                default:
                    XCTFail("Expected empty result, got \(result) instead")
                }
                exp.fulfill()
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueFeed().local
        let timestamp = Date()

        let exp = expectation(description: "Wait for retrieval")
        sut.insert(feed, timestamp: timestamp) { insertResult in
            XCTAssertNil(insertResult, "Expected feed to be inserted successfully")
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for retrieval")
        let feed = uniqueFeed().local
        let timestamp = Date()

        sut.insert(feed, timestamp: timestamp) { insertResult in
            XCTAssertNil(insertResult, "Expected feed to be inserted successfully")

            sut.retrieve { firstResult in
                sut.retrieve { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.found(firstFound, firstTimestamp), .found(secondFound, secondTimestamp)):
                        XCTAssertEqual(firstFound, feed)
                        XCTAssertEqual(firstTimestamp, timestamp)
                        XCTAssertEqual(secondFound, feed)
                        XCTAssertEqual(secondTimestamp, timestamp)
                    default:
                        XCTFail("Expected retriving twice to deliver same feed and timestamp, got \(firstResult) and \(secondResult) instead")
                    }
                    exp.fulfill()
                }
            }
        }

        wait(for: [exp], timeout: 1.0)
    }

    // Mark: - Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for retrieval")

        sut.retrieve { retrievedResult in
            switch (retrievedResult, expectedResult) {
                case (.empty, .empty):
                    break
            case let (.found(expectedFeed, expectedTimestamp), .found(retrivedFeed, retrivedTimestamp)):
                XCTAssertEqual(expectedFeed, retrivedFeed)
                XCTAssertEqual(expectedTimestamp, retrivedTimestamp)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
