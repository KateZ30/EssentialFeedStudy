//
//  FeedUIComposer.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 4/30/24.
//

import UIKit
import EssensialFeed

public final class FeedUIComposer {
    private init() {}

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, imageLoader: imageLoader)

        return feedController
    }

    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, imageLoader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
        return { [weak controller] feed in
            controller?.tableModel = feed.map {
                FeedImageCellController(viewModel: FeedImageViewModel(model: $0,
                                                                      imageLoader: imageLoader,
                                                                      imageTransformer: UIImage.init))
            }
        }
    }
}
