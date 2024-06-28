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

        assert(snapshot: sut.snapshot(), named: "EMPTY_FEED")
    }

    func test_feedWithContent() {
        let sut = makeSUT()

        sut.display(feedWithContent())

        assert(snapshot: sut.snapshot(), named: "FEED_WITH_CONTENT")
    }

    func test_feedWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        assert(snapshot: sut.snapshot(), named: "FEED_WITH_ERROR_MESSAGE")
    }

    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()

        sut.display(feedWithFailedImageLoading())

        assert(snapshot: sut.snapshot(), named: "FEED_WITH_FAILED_IMAGE_LOADING")
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

    private func record(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

        do {
            try FileManager.default.createDirectory(at: snapshotURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try snapshotData?.write(to: snapshotURL)
        } catch {
            XCTFail("Failed to record snapshot with error: \(error)", file: file, line: line)
        }
    }

    private func assert(snapshot: UIImage, named name: String, file: StaticString = #filePath, line: UInt = #line) {
        let snapshotURL = makeSnapshotURL(named: name, file: file)
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)

        guard let storedSnapshotData = try? Data(contentsOf: snapshotURL) else {
            return XCTFail("Failed to read snapshot data from disk: \(snapshotURL). Use `record` method to store a snapshot before asserting.", file: file, line: line)
        }

        if snapshotData != storedSnapshotData {
            let temporarySnapshotURL = URL(fileURLWithPath: "\(file)")
                .deletingPathExtension()
                .appendingPathComponent("snapshots")
                .appendingPathComponent("\(name)-temp.png")
            try? snapshotData?.write(to: temporarySnapshotURL)
            return XCTFail("New snapshot does not match stored snapshot. See difference at new snapshot: \(temporarySnapshotURL) versus the stored snapshot: \(snapshotURL)", file: file, line: line)
        }
    }

    private func makeSnapshotURL(named name: String, file: StaticString) -> URL {
        URL(fileURLWithPath: "\(file)")
            .deletingPathExtension()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }

    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let snapshotData = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }

        return snapshotData
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
