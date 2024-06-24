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

        XCTAssertEqual(app.cells.count, 22)
        XCTAssertEqual(app.images.count > 0, true)
    }
}
