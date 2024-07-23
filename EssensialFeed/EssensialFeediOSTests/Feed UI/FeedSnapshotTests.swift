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
    }

    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
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
        let cells: [FeedImageCellController] = stubs.map { stub in
            let controller = FeedImageCellController(viewModel: stub.viewModel, delegate: stub)
            stub.controller = controller
            return controller
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
