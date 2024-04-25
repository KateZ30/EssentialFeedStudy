//
//  FeedViewControllerTests.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 4/24/24.
//

import XCTest

class FeedViewController {
    private var loader: FeedViewControllerTests.LoaderSpy

    init(loader: FeedViewControllerTests.LoaderSpy) {
        self.loader = loader
    }

}

final class FeedViewControllerTests: XCTestCase {
    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()

        XCTAssertEqual(loader.loadCallCount, 0)
    }

    // MARK: - Helpers
    private func makeSUT() -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)

        return (sut, loader)
    }
    class LoaderSpy {
        private(set) var loadCallCount: Int = 0
    }
}
