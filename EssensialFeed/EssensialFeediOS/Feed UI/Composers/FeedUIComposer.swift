//
//  FeedUIComposer.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 4/30/24.
//

import Foundation
import EssensialFeed

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, imageLoader: imageLoader)

        return feedController
    }

    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader) }
        }
    }
}
