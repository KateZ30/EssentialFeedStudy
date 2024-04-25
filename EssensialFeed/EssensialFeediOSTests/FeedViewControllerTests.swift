//
//  FeedViewControllerTests.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 4/24/24.
//

import XCTest
import UIKit

class FeedViewController: UIViewController {
    private var loader: FeedViewControllerTests.LoaderSpy?

    convenience init(loader: FeedViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loader?.load()
    }

}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(loader.loadCallCount, 1)
    }

    // MARK: - Helpers
    private func makeSUT() -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)

        return (sut, loader)
    }
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0

        func load() {
            loadCallCount += 1
        }
    }
}
