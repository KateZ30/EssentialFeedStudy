//
//  FeedViewController+Localization.swift
//  EssensialFeediOSTests
//
//  Created by Kate Zemskova on 5/6/24.
//

import Foundation
import XCTest
import EssensialFeediOS

extension FeedUIIntegrationTests {
    func localized(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: FeedViewController.self)
        let localizedString = bundle.localizedString(forKey: key, value: nil, table: table)
        XCTAssertNotEqual(key, localizedString, "Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        return localizedString
    }

}
