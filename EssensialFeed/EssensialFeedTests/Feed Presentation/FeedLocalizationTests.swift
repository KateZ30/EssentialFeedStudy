//
//  FeedLocalizationTests.swift
//  EssensialFeediOSTests
//
//  Created by Kate Zemskova on 5/6/24.
//

import XCTest
@testable import EssensialFeed

final class FeedLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)

        assertLocalizedKeysAndValuesExist(in: bundle, table)
    }
}
