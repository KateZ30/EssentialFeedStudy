//
//  ImageCommentsLocalizationTests.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 7/22/24.
//

import XCTest
import EssensialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)

        assertLocalizedKeysAndValuesExist(in: bundle, table)
    }
}
