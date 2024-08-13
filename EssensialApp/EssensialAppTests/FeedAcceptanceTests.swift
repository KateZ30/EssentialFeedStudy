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
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: HttpClientStub.online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)

        let offlineFeed = launch(httpClient: .offline, store: sharedStore)

        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews, 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let offlineFeed = launch(httpClient: .offline)

        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews, 0)
    }

    func test_onEnteringBackground_deletesExpiredFeedCache() {
        let store = InMemoryFeedStore.withExpiredFeedCache

        enterBackground(with: store)

        XCTAssertNil(store.feed, "Expected to delete expired cache")
    }

    func test_onEnteringBackground_keepsNonExpiredFeedCache() {
        let store = InMemoryFeedStore.withNonExpiredFeedCache

        enterBackground(with: store)

        XCTAssertNotNil(store.feed, "Expected to keep non-expired cache")
    }

    func test_onFeedImageSelection_displaysComments() {
        let comments = showCommentsForFirstImage()

        XCTAssertEqual(comments.numberOfRenderedComments, 1)
        XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
        XCTAssertEqual(comments.commentUsername(at: 0), makeCommentUsername())
    }

    // MARK: - Helpers
    private func launch(httpClient: HttpClientStub = .offline,
                        store: InMemoryFeedStore = .empty) -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()

        let nav = sut.window?.rootViewController as? UINavigationController
        let feed = nav?.topViewController as! ListViewController
        feed.simulateAppearance()

        return feed
    }

    private func enterBackground(with store: InMemoryFeedStore) {
        let sut = SceneDelegate(httpClient: HttpClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }

    private func showCommentsForFirstImage() -> ListViewController {
        let feed = launch(httpClient: .online(response), store: .empty)

        feed.simulateTapOnFeedImageView(at: 0)
        RunLoop.current.run(until: Date())

        let nav = feed.navigationController
        let vc = nav?.topViewController as! ListViewController
        vc.simulateAppearance()

        return vc
    }

    private func response(_ url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        switch url.path {
        case "/image-0", "/image-1":
            return makeImageData()
        case "/essential-feed/v1/feed":
            return makeFeedData()
        case "/essential-feed/v1/image/EA8846C8-A60A-4488-888C-D5EC6D442217/comments",
            "/essential-feed/v1/image/38DBCC5F-26D9-4201-919F-80C1BD957C70/comments":
            return makeCommentsData()
            default:
                return Data()
        }
    }

    private func makeImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }

    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "EA8846C8-A60A-4488-888C-D5EC6D442217", "image": "http://image.com/image-0"],
            ["id": "38DBCC5F-26D9-4201-919F-80C1BD957C70", "image": "http://image.com/image-1"]
        ]])
    }

    private func makeCommentsData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString,
             "message": makeCommentMessage(),
             "created_at": "2020-05-20T11:24:59+0000",
             "author": [
                "username": makeCommentUsername()
             ]
            ]
        ]])
    }

    private func makeCommentMessage() -> String {
        "a message"
    }

    private func makeCommentUsername() -> String {
        "a username"
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
        private(set) var feed: CachedFeed?
        private var feedImageData = [URL: Data]()

        private init(feed: CachedFeed? = nil) {
            self.feed = feed
        }

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

        static var withExpiredFeedCache: InMemoryFeedStore {
            InMemoryFeedStore(feed: CachedFeed(feed: [], timestamp: Date.distantPast))
        }

        static var withNonExpiredFeedCache: InMemoryFeedStore {
            InMemoryFeedStore(feed: CachedFeed(feed: [], timestamp: Date()))
        }
    }
}
