//
//  FeedLoader.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 2/20/24.
//

import Foundation

public enum LoadFeedLoader<Error> {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    associatedtype Error: Swift.Error
    func load(completion: @escaping (LoadFeedLoader<Error>) -> Void)
}
