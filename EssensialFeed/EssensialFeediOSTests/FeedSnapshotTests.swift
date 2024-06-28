//
//  FeedSnapshotTests.swift
//  EssensialFeediOSTests
//
//  Created by Kate Zemskova on 6/27/24.
//

import XCTest
import EssensialFeediOS
import EssensialFeed
import UIKit

class FeedSnapshotTests: XCTestCase {
    func test_emptyFeed() {
        let sut = makeSUT()

        sut.display(emptyFeed())

        record(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }

    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        record(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }

    func test_feedWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        record(snapshot: sut.snapshot(), named: "FEED_WITH_ERROR_MESSAGE")
    }

    // MARK: - Helpers
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! FeedViewController
        controller.loadViewIfNeeded()
        return controller
    }

    private func emptyFeed() -> [FeedImageCellController] {
        return []
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

    private func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        guard let snapshotData = snapshot.pngData() else {
            return XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
        }
        let snapshotURL = URL(fileURLWithPath: "\(file)")
            .deletingPathExtension()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")

        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }
}

extension UIViewController {
    func snapshot() -> UIImage {
        return UIGraphicsImageRenderer(bounds: view.bounds).image { action in
            view.layer.render(in: action.cgContext)
        }
    }
}

private extension FeedViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [FeedImageCellController] = stubs.map { stub in
            let controller = FeedImageCellController(delegate: stub)
            stub.controller = controller
            return controller
        }

        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel<UIImage>
    weak var controller: FeedImageCellController?

    init(description: String?, location: String?, image: UIImage?) {
        viewModel = FeedImageViewModel(description: description,
                                       location: location,
                                       image: image,
                                       isLoading: false,
                                       shouldRetry: image == nil)
    }

    func didRequestImage() {
        controller?.display(viewModel)
    }
    func didCancelImageRequest() {}
}
