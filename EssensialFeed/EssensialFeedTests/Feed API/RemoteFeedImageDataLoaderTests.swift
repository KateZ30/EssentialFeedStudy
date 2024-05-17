//
//  RemoteFeedImageDataLoaderTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 5/17/24.
//

import XCTest
import EssensialFeed

final class RemoteFeedImageDataLoader {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }
}

final class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)

        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, client)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }

        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
    }
}
