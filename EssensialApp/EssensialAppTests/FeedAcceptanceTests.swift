//
//  FeedAcceptanceTests.swift
//  EssensialAppTests
//
//  Created by Kate Zemskova on 6/27/24.
//

import XCTest
import EssensialFeed
import EssensialFeediOS
@testable import EssensialApp

class FeedAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: HttpClientStub.online(response))

        XCTAssertEqual(feed.numberOfRenderedFeedImageViews, 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
    }

    // MARK: - Helpers
    private func launch(httpClient: HttpClientStub = .offline,
                        store: InMemoryFeedStore = .empty) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()

        let nav = sut.window?.rootViewController as? UINavigationController
        let feed = nav?.topViewController as! FeedViewController
        feed.simulateAppearance()

        return feed
    }

    private func response(_ url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
        default:
            return makeFeedData()
        }
    }

    private func makeImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }

    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }

    private class HttpClientStub: HTTPClient {
        private class Task: HTTPClientTask {
            func cancel() {}
        }

        private let stub: (URL) -> HTTPClient.Result

        init(stub: @escaping (URL) -> HTTPClient.Result) {
            self.stub = stub
        }

        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            completion(stub(url))
            return Task()
        }

        static var offline: HttpClientStub {
            HttpClientStub { _ in .failure(NSError(domain: "offline", code: 0)) }
        }

        static func online(_ stub: @escaping (URL) -> (Data, HTTPURLResponse)) -> HttpClientStub {
            HttpClientStub { url in .success(stub(url)) }
        }
    }

    private class InMemoryFeedStore: FeedStore, FeedImageDataStore {
        private var feed: CachedFeed?
        private var feedImageData = [URL: Data]()

        func deleteCachedFeed(completion: @escaping DeletionCompletion) {
            feed = nil
            completion(.success(()))
        }

        func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            self.feed = CachedFeed(feed: feed, timestamp: timestamp)
            completion(.success(()))
        }

        func retrieve(completion: @escaping RetrievalCompletion) {
            completion(.success(feed))
        }

        func insert(_ data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {
            feedImageData[url] = data
            completion(.success(()))
        }

        func retrieve(dataForURL url: URL, completion: @escaping (RetrieveResult) -> Void) {
            completion(.success(feedImageData[url]))
        }

        static var empty: InMemoryFeedStore {
            InMemoryFeedStore()
        }
    }
}
