//
//  FeedSnapshotTests.swift
//  EssensialFeediOSTests
//
//  Created by Kate Zemskova on 6/27/24.
//

import XCTest
import EssensialFeediOS
@testable import EssensialFeed
import UIKit

class FeedSnapshotTests: XCTestCase {
    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")
    }

    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
    }

    func test_feedWithLoadMoreIndicator() {
        let sut = makeSUT()

        sut.display(feedWithLoadMoreIndicator())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
    }

    func test_feedWithLoadMoreError() {
        let sut = makeSUT()

        sut.display(feedWithLoadMoreError())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_LOAD_MORE_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_LOAD_MORE_ERROR_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_LOAD_MORE_ERROR_light_extraExtraExtraLarge")
    }

    // MARK: - Helpers
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }

    private func feedWithLoadMoreError() -> [CellController] {
        let loadMore = LoadMoreCellController()
        loadMore.display(ResourceErrorViewModel(message: "This is a\nmulti-line\nerror message"))
        return feedWithLoadMore(loadMore)
    }

    private func feedWithLoadMoreIndicator() -> [CellController] {
        let loadMore = LoadMoreCellController()
        loadMore.display(ResourceLoadingViewModel(isLoading: true))
        return feedWithLoadMore(loadMore)
    }

    private func feedWithLoadMore(_ loadMore: LoadMoreCellController) -> [CellController] {
        let stub = feedWithContent().last!
        let image = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
        stub.controller = image
        return [
            CellController(id: UUID(), image),
            CellController(id: UUID(), loadMore)
        ]
    }

    private func feedWithContent() -> [ImageStub] {
        [
            ImageStub(
                description: "Description 1\nsecond line\nthird line",
                location: "Location 1",
                image: UIImage.make(withColor: .red)
            ),
            ImageStub(
                description: "Description 2\nsecond line\nthird line",
                location: "Location 2",
                image: UIImage.make(withColor: .green)
            ),
            ImageStub(
                description: "Description 3",
                location: "Location 3",
                image: UIImage.make(withColor: .blue)
            )
        ]
    }

    private func feedWithFailedImageLoading() -> [ImageStub] {
        [
            ImageStub(
                description: nil,
                location: "Location 1",
                image: nil
            ),
            ImageStub(
                description: "Description 2",
                location: "Location 2",
                image: nil
            )
        ]
    }
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellController] = stubs.map { stub in
            let controller = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
            stub.controller = controller
            return CellController(id: UUID(), controller)
        }

        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel
    let image: UIImage?
    weak var controller: FeedImageCellController?

    init(description: String?, location: String?, image: UIImage?) {
        self.image = image
        self.viewModel = FeedImageViewModel(description: description,
                                            location: location)
    }

    func didRequestImage() {
        controller?.display(ResourceLoadingViewModel(isLoading: true))

        if let image = image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel(message: .none))
        } else {
            controller?.display(ResourceErrorViewModel(message: "any"))
        }

        controller?.display(ResourceLoadingViewModel(isLoading: false))
    }

    func didCancelImageRequest() {}
}
