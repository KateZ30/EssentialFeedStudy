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
        refreshController.onRefresh = { [weak feedController] feed in
            feedController?.tableModel = feed.map { FeedImageCellController(model: $0, imageLoader: imageLoader) }
        }

        return feedController
    }
}
