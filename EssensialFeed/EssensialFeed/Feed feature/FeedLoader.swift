//
//  FeedLoader.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 2/20/24.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
