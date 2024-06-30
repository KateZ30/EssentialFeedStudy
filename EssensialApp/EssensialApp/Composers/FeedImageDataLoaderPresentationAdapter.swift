//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 5/10/24.
//

import Foundation
import Combine
import EssensialFeed
import EssensialFeediOS

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?

    var presenter: FeedImagePresenter<View, Image>?

    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }

    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)

        let model = self.model

        cancellable = imageLoader(model.url)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                }
            } receiveValue: { [weak self] data in
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            }
    }

    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
