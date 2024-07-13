//
//  ImageCommentMapperTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 7/5/24.
//

import XCTest
import EssensialFeed

class ImageCommentMapperTests: XCTestCase {

    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let samples = [199, 150, 300, 400, 500]
        let json = makeItemsJson([])

        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_throwsErrorOn2xxHttpResponseWithInvalidJSON() throws {
        let invalidJSON = Data("invalid json".utf8)

        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: code))
            )
        }
    }

    func test_map_deliversNoItemsOn2xxHttpResponseWithEmptyJSONItems() throws {
        let emptyListJSON = makeItemsJson([])

        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            let result = try ImageCommentMapper.map(emptyListJSON, from: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }

    func test_map_deliversItemsOn2xxHttpResponseWithJSONList() throws {
        let item1 = makeItem(id: UUID(),
                             message: "a message",
                             createdAt: (Date(timeIntervalSince1970: 1720220256), "2024-07-05T22:57:36+00:00"),
                             username: "user 1")
        let item2 = makeItem(id: UUID(),
                             message: "a message",
                             createdAt: (Date(timeIntervalSince1970: 1712260517), "2024-04-04T19:55:17+00:00"),
                             username: "user 1")
        let json = makeItemsJson([item1.json, item2.json])

        let samples = [200, 201, 250, 280, 299]

        try samples.forEach { code in
            let result = try ImageCommentMapper.map(json, from: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [item1.model, item2.model])
        }
    }

    // MARK: - Helpers
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, ios8601String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.ios8601String,
            "author": [
                "username": username
            ]
        ].compactMapValues { $0 }

        return (item, json)
    }

    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        try! JSONSerialization.data(withJSONObject: ["items": items])
    }
}
