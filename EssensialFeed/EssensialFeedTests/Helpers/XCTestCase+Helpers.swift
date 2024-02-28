//
//  XCTestCase+Helpers.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 2/27/24.
//

import XCTest

extension XCTestCase {
    func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
