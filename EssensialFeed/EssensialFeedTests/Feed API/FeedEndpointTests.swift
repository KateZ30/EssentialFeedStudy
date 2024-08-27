//
//  FeedEndpointTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 8/13/24.
//

import XCTest
import EssensialFeed

class FeedEndpointTests: XCTestCase {
    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        let received = FeedEndpoint.get.url(baseURL: baseURL)

        XCTAssertEqual(received.scheme, "http", "host")
        XCTAssertEqual(received.host, "base-url.com", "host")
        XCTAssertEqual(received.path, "/v1/feed", "path")
        XCTAssertEqual(received.query, "limit=10", "query")
    }
}
