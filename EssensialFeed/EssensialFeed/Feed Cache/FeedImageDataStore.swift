//
//  FeedImageDataStore.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 5/23/24.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>

    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
