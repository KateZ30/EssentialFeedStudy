//
//  EssensialAppUIAcceptanceTests.swift
//  EssensialAppUIAcceptanceTests
//
//  Created by Kate Zemskova on 6/24/24.
//

import XCTest

final class EssensialAppUIAcceptanceTests: XCTestCase {
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        let app = XCUIApplication()

        app.launch()

        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 22)

        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
}
