//
//  FeedImageDataStore.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 5/23/24.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
