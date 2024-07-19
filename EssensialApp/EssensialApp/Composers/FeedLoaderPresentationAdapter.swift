//
//  FeedLoaderPresentationAdapter.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 5/10/24.
//

import Combine
import EssensialFeed
import EssensialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    var presenter: FeedPresenter?
    private var cancellable: Cancellable?

    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        cancellable = feedLoader()
            .dispatchOnMainQueue()
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case let .failure(error) = completion {
                        self?.presenter?.didFinishLoadingFeed(with: error)
                    }
                },
                receiveValue: { [weak self] feed in
                    self?.presenter?.didFinishLoadingFeed(with: feed)
                })
    }
}
