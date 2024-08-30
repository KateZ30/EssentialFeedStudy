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
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() throws {
        let feed = try launch(httpClient: HttpClientStub.online(response), store: .empty)

        XCTAssertEqual(feed.numberOfRenderedFeedImageViews, 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertTrue(feed.canLoadMore)

        feed.simulateLoadMoreFeedAction()

        XCTAssertEqual(feed.numberOfRenderedFeedImageViews, 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData2())
        XCTAssertTrue(feed.canLoadMore)

        feed.simulateLoadMoreFeedAction()

        XCTAssertEqual(feed.numberOfRenderedFeedImageViews, 3)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertEqual(feed.renderedFeedImageData(at: 2), makeImageData2())
        XCTAssertFalse(feed.canLoadMore)
    }

    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() throws {
        let sharedStore = try CoreDataFeedStore.empty
        let onlineFeed = launch(httpClient: HttpClientStub.online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        onlineFeed.simulateLoadMoreFeedAction()
        onlineFeed.simulateFeedImageViewVisible(at: 2)

        let offlineFeed = launch(httpClient: .offline, store: sharedStore)

        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews, 3)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData0())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData1())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 2), makeImageData2())
    }

    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() throws {
        let offlineFeed = try launch(httpClient: .offline, store: .empty)

        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews, 0)
    }

    func test_onEnteringBackground_deletesExpiredFeedCache() throws {
        let store = try CoreDataFeedStore.withExpiredFeedCache

        enterBackground(with: store)

        XCTAssertNil(try store.retrieve(), "Expected to delete expired cache")
    }

    func test_onEnteringBackground_keepsNonExpiredFeedCache() throws {
        let store = try CoreDataFeedStore.withNonExpiredFeedCache

        enterBackground(with: store)

        XCTAssertNotNil(try store.retrieve(), "Expected to keep non-expired cache")
    }

    func test_onFeedImageSelection_displaysComments() throws {
        let comments = try showCommentsForFirstImage()

        XCTAssertEqual(comments.numberOfRenderedComments, 1)
        XCTAssertEqual(comments.commentMessage(at: 0), makeCommentMessage())
        XCTAssertEqual(comments.commentUsername(at: 0), makeCommentUsername())
    }

    // MARK: - Helpers
    private func launch(httpClient: HttpClientStub = .offline,
                        store: CoreDataFeedStore) -> ListViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()

        let nav = sut.window?.rootViewController as? UINavigationController
        let feed = nav?.topViewController as! ListViewController
        feed.simulateAppearance()

        return feed
    }

    private func enterBackground(with store: CoreDataFeedStore) {
        let sut = SceneDelegate(httpClient: HttpClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }

    private func showCommentsForFirstImage() throws -> ListViewController {
        let feed = try launch(httpClient: .online(response), store: .empty)

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
        case "/image-0": return makeImageData0()
        case "/image-1": return makeImageData1()
        case "/image-2": return makeImageData2()
        case "/essential-feed/v1/feed" where url.query()?.contains("after_id") == false:
            return makeFirstPageFeedData()
        case "/essential-feed/v1/feed" where url.query()?.contains("after_id=38DBCC5F-26D9-4201-919F-80C1BD957C70") == true:
            return makeSecondPageFeedData()
        case "/essential-feed/v1/feed" where url.query()?.contains("after_id=87BD2CFF-4383-4A50-A984-FE58D94DC707") == true:
            return makeLastPageFeedData()

        case "/essential-feed/v1/image/EA8846C8-A60A-4488-888C-D5EC6D442217/comments":
            return makeCommentsData()
        default:
            return Data()
        }
    }

    private func makeImageData0() -> Data { UIImage.make(withColor: .red).pngData()! }
    private func makeImageData1() -> Data { UIImage.make(withColor: .green).pngData()! }
    private func makeImageData2() -> Data { UIImage.make(withColor: .blue).pngData()! }

    private func makeFirstPageFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "EA8846C8-A60A-4488-888C-D5EC6D442217", "image": "http://image.com/image-0"],
            ["id": "38DBCC5F-26D9-4201-919F-80C1BD957C70", "image": "http://image.com/image-1"]
        ]])
    }

    private func makeSecondPageFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": "87BD2CFF-4383-4A50-A984-FE58D94DC707", "image": "http://image.com/image-2"]
        ]])
    }

    private func makeLastPageFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": []])
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
}

extension CoreDataFeedStore {
    private static var inMemoryStoreURL: URL {
        URL(fileURLWithPath: "/dev/null")
            .appendingPathComponent("\(type(of: self)).store")
    }

    static var empty: CoreDataFeedStore {
        get throws {
            try CoreDataFeedStore(storeURL: Self.inMemoryStoreURL, contextQueueType: .main)
        }
    }

    static var withExpiredFeedCache: CoreDataFeedStore {
        get throws {
            let store = try Self.empty
            try store.insert([], timestamp: Date.distantPast)
            return store
        }
    }

    static var withNonExpiredFeedCache: CoreDataFeedStore {
        get throws {
            let store = try Self.empty
            try store.insert([], timestamp: Date())
            return store
        }

    }
}
