//
//  ValidateFeedCacheUseCase.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 2/28/24.
//

import XCTest
import EssensialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validate_deletesCacheOnRetrievalError() {
        let (store, sut) = makeSUT()

        store.completeRetrieval(with: anyNSError())
        sut.validateCache()


        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }

    func test_validate_doesNotDeleteCacheOnEmptyCache() {
        let (store, sut) = makeSUT()

        store.completeRetrievalWithEmptyCache()
        sut.validateCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validate_doesNotDeleteCacheOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (store, sut) = makeSUT(currentDate: { fixedCurrentDate })

        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        sut.validateCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_validate_deleteCacheOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (store, sut) = makeSUT(currentDate: { fixedCurrentDate })

        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        sut.validateCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }

    func test_validate_deletesCacheOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (store, sut) = makeSUT(currentDate: { fixedCurrentDate })

        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        sut.validateCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)

        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (store, sut)
    }
}
