//
//  CommentsUIComposer.swift
//  EssensialApp
//
//  Created by Kate Zemskova on 8/9/24.
//

import Foundation

import Combine
import UIKit
import EssensialFeed
import EssensialFeediOS

public final class CommentsUIComposer {
    private init() {}

    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) -> ListViewController {
        let presentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>(loader: commentsLoader)
        let feedController = ListViewController.makeWith(title: ImageCommentsPresenter.title)
        feedController.onRefresh = presentationAdapter.load
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(controller: feedController,
                                          imageLoader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController),
            mapper: FeedPresenter.map)
        return feedController
    }
}

private extension ListViewController {
    static func makeWith(title: String) -> ListViewController {
        let storyboard = UIStoryboard(name: "Feed", bundle: Bundle(for: ListViewController.self))
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}
