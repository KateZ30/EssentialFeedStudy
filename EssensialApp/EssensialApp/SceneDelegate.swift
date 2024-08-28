//
//  SceneDelegate.swift
//  EssensialApp
//
//  Created by Kate Zemskova on 6/6/24.
//

import UIKit
import EssensialFeed
import EssensialFeediOS
import CoreData
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()

    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("feed-store.sqlite"))
    }()

    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()

    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

    private lazy var  navigationController = UINavigationController(
        rootViewController: FeedUIComposer.feedComposedWith(
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageDataLoaderWithRemoteFallback,
            selection: showComments))

    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        configureWindow()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache()
    }

    func configureWindow() {
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }

    private func showComments(_ image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)

        let commentsController = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(commentsController, animated: true)
    }

    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [httpClient] in
            httpClient
                .getPublisher(from: url)
                .tryMap(ImageCommentMapper.map)
                .eraseToAnyPublisher()
        }
    }

    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .eraseToAnyPublisher()
    }

    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }

    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items, loadMorePublisher: last.map { last in
            { self.makeRemoteLoadMoreLoader(items: items, last: last) }
        })
    }

    private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
        makeRemoteFeedLoader(after: last)
                .map { (items + $0, $0.last) }
                .map(makePage)
                .caching(to: localFeedLoader)
                .eraseToAnyPublisher()
    }

    private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
        let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)

        return httpClient
            .getPublisher(from: url)
            .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
    }

    private func makeLocalImageDataLoaderWithRemoteFallback(for url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)

        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            })
    }
}
