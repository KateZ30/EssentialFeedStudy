//
//  FeedImageDataStore.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 5/23/24.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrieveResult = Swift.Result<Data?, Error>
    typealias InsertResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrieveResult) -> Void)
}
