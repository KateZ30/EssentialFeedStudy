//
//  FeedLoaderWithFallbackCompositeTests.swift
//  EssensialAppTests
//
//  Created by Kate Zemskova on 6/6/24.
//

import XCTest
import EssensialFeed

class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader

    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load(completion: completion)
    }
}

final class FeedLoaderWithFallbackCompositeTests: XCTestCase {
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let remoteLoader = LoaderStub(result: .success(primaryFeed))
        let localLoader = LoaderStub(result: .success(fallbackFeed))
        let sut = FeedLoaderWithFallbackComposite(primary: remoteLoader, fallback: localLoader)

        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(receivedFeed):
                XCTAssertEqual(receivedFeed, primaryFeed)
            default:
                XCTFail("Expected success, got \(result) instead")
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers
    private class LoaderStub: FeedLoader {
        private let result: FeedLoader.Result

        init(result: FeedLoader.Result) {
            self.result = result
        }

        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completion(result)
        }
    }

    func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
    }

    func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }


}
