//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 7/5/24.
//

import XCTest
import EssensialFeed

class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {

    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 150, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let json = makeItemsJson([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }

    func test_load_deliversErrorOn2xxHttpResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        let invalidJSON = Data("invalid json".utf8)

        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            }
        }
    }

    func test_load_deliversNoItemsOn2xxHttpResponseWithEmptyJSONItems() {
        let (sut, client) = makeSUT()
        let emptyListJSON = makeItemsJson([])

        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success([])) {
                client.complete(withStatusCode: code, data: emptyListJSON, at: index)
            }
        }

    }

    func test_load_deliversItemsOn2xxHttpResponseWithJSONList() {
        let (sut, client) = makeSUT()
        let item1 = makeItem(id: UUID(),
                             message: "a message",
                             createdAt: (Date(timeIntervalSince1970: 1720220256), "2024-07-05T22:57:36+00:00"),
                             username: "user 1")
        let item2 = makeItem(id: UUID(),
                             message: "a message",
                             createdAt: (Date(timeIntervalSince1970: 1712260517), "2024-04-04T19:55:17+00:00"),
                             username: "user 1")
        let itemsJSON = makeItemsJson([item1.json, item2.json])
        let items = [item1.model, item2.model]

        let samples = [200, 201, 250, 280, 299]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .success(items)) {
                client.complete(withStatusCode: code, data: itemsJSON, at: index)
            }
        }
    }

    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!,
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }

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

    private func expect(_ sut: RemoteImageCommentsLoader,
                        toCompleteWith result: RemoteImageCommentsLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #filePath,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, result) {
                case let (.success(receivedItems), .success(expectedItems)):
                    XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                case let (.failure(receivedError), .failure(expectedError)):
                    XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                default:
                    XCTFail("Expected result \(result) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
        .failure(error)
    }

    private class HTTPClientSpy: HTTPClient {
        private struct Task: HTTPClientTask {
            func cancel() {}
        }

        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task()
        }

        func complete(with error: Error, at index: Int) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data, at index: Int) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }

    }
}
