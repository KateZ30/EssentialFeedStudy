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

    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>

    init(controller: ListViewController?,
         imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
         selection: @escaping (FeedImage) -> Void) {
        self.controller = controller
        self.imageLoader = imageLoader
        self.selection = selection
    }

    func display(_ viewModel: Paginated<FeedImage>) {
        let feed: [CellController] = viewModel.items.map { model in
            let adapter = ImageDataPresentationAdapter(loader: { [imageLoader] in
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
        }

        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller?.display(feed)
            return
        }

        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.load)

        loadMoreAdapter.presenter = LoadResourcePresenter(resourceView: self,
                                                          loadingView: WeakRefVirtualProxy(loadMore),
                                                          errorView: WeakRefVirtualProxy(loadMore),
                                                          mapper: { $0 })

        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        controller?.display(feed, loadMoreSection)
    }
}

private struct InvalidImageData: Error {}
