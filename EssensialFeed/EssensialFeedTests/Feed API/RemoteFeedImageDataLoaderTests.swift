//
//  RemoteFeedImageDataLoaderTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 5/17/24.
//

import XCTest
import EssensialFeed

final class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_loadImageDataFromURL_requestsImageDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT()

        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = anyNSError()

        expect(sut, toCompleteWith: failure(.connectivity)) {
            client.complete(with: anyNSError())
        }
    }

    func test_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            }
        }
    }

    func test_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData)) {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        }
    }

    func test_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)

        expect(sut, toCompleteWith: .success(nonEmptyData)) {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        }
    }

    func test_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteFeedImageDataLoader? = RemoteFeedImageDataLoader(client: client)

        var capturedResults = [FeedImageDataLoader.Result]()
        sut?.loadImageData(from: anyURL()) { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: anyData())

        XCTAssertTrue(capturedResults.isEmpty)
    }

    // MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: client)

        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)

        return (sut, client)
    }

    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")

        sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func anyData() -> Data {
        return Data("any data".utf8)
    }

    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        return .failure(error)
    }

    private class HTTPClientSpy: HTTPClient {
        private struct Task: HTTPClientTask {
            func cancel() {}
        }

        var requestedURLs: [URL] {
            messages.map { $0.url }
        }

        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url, completion))
            return Task()
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }

        func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
}
