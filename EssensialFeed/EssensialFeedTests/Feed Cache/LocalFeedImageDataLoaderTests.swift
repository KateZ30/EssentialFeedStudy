//
//  LocalFeedImageDataLoaderTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 5/21/24.
//

import XCTest

class LocalFeedImageDataLoader {
    private var store: Any

    init(store: Any) {
        self.store = store
    }

}

final class LocalFeedImageDataLoaderTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (store, _) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    // MARK: - Helpers
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedImageDataLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }

    private class FeedStoreSpy {
        private(set) var receivedMessages = [Any]()
    }
}
