//
//  RemoteFeedLoaderTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 2/20/24.
//

import XCTest
@testable import EssensialFeed

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

final class EssensialFeedTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() throws {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
