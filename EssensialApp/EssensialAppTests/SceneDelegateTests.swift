//
//  SceneDelegateTests.swift
//  EssensialAppTests
//
//  Created by Kate Zemskova on 6/27/24.
//

import XCTest
import EssensialFeediOS
@testable import EssensialApp

class SceneDelegateTests: XCTest {
    func  test_sceneWillConnectToSession_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()

        sut.configureWindow()

        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController

        XCTAssertNotNil(rootNavigation, "Expected a navigation controller as root, got \(String(describing: root))")
        XCTAssertTrue(topController is FeedViewController, "Expected a feed view controller as top view controller, got \(String(describing: topController))")
    }
}
