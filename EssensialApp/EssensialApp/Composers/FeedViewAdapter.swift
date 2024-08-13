//
//  FeedViewAdapter.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 5/10/24.
//

import Combine
import Foundation
import UIKit
import EssensialFeed
import EssensialFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let selection: (FeedImage) -> Void

    init(controller: ListViewController?,
         imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
         selection: @escaping (FeedImage) -> Void) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }

    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [imageLoader] in
                imageLoader(model.url)
            })
            let view = FeedImageCellController(viewModel: FeedImagePresenter.map(model),
                                               delegate: adapter) { [selection] in
                selection(model)
            }

            adapter.presenter = LoadResourcePresenter(resourceView: WeakRefVirtualProxy(view),
                                                      loadingView: WeakRefVirtualProxy(view),
                                                      errorView: WeakRefVirtualProxy(view),
                                                      mapper: { data in
                guard let image = UIImage(data: data) else {
                    throw InvalidImageData()
                }
                return image
            })

            return CellController(id: model, view)
        })
    }
}

private struct InvalidImageData: Error {}
