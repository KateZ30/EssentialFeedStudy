//
//  FeedImagePresenterTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 7/22/24.
//

import XCTest
import EssensialFeed

final class FeedImagePresenterTests: XCTestCase {
    func test_map_createsViewModel() {
        let image = uniqueImage()

        let viewModel = FeedImagePresenter<DummyView, Any>.map(image)

        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }


    private class DummyView: FeedImageView {
        func display(_ model: EssensialFeed.FeedImageViewModel<Any>) {}
    }

}
