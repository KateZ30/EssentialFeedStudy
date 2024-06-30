//
//  FeedLoaderStub.swift
//  EssensialAppTests
//
//  Created by Kate Zemskova on 6/17/24.
//

import Foundation
import EssensialFeed

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result

    init(result: FeedLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
