//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 4/12/24.
//

import XCTest
import EssensialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        let insertionError = insert((uniqueFeed().local, Date()), to: sut)
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail", file: file, line: line)
    }

    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) {
        insert((uniqueFeed().local, Date()), to: sut)
        expect(sut, toRetrieve: .empty, file: file, line: line)
    }
}