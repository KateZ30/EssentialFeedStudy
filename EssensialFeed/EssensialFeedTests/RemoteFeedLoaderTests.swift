//
//  RemoteFeedLoaderTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 2/20/24.
//

import XCTest
@testable import EssensialFeed

class RemoteFeedLoader {
    func load(client: HTTPClient) {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}

class HTTPClient {
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

final class EssensialFeedTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() throws {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let client = HTTPClient()
        let sut = RemoteFeedLoader()
        
        sut.load(client: client)
        
        XCTAssertNotNil(client.requestedURL)

    }
}
