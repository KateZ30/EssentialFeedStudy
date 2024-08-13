//
//  ImageCommentsEndpointTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 8/13/24.
//

import Foundation

import XCTest
import EssensialFeed

class ImageCommentsEndpointTests: XCTestCase {
    func test_comments_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        let id = UUID()

        let received = ImageCommentsEndpoint.get(id).url(baseURL: baseURL)
        let expected = URL(string: "http://base-url.com/v1/image/\(id.uuidString)/comments")!

        XCTAssertEqual(received, expected)
    }
}
