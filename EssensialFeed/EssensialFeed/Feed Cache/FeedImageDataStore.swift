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


    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?

    @available(*, deprecated)
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertResult) -> Void)

    @available(*, deprecated)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrieveResult) -> Void)
}

public extension FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws {
        let group = DispatchGroup()
        group.enter()
        var result: InsertResult!
        insert(data, for: url) {
            result = $0
            group.leave()
        }
        group.wait()
        return try result.get()

    }
    func retrieve(dataForURL url: URL) throws -> Data? {
        let group = DispatchGroup()
        group.enter()
        var result: RetrieveResult!
        retrieve(dataForURL: url) {
            result = $0
            group.leave()
        }
        group.wait()
        return try result.get()
    }

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {}
    func retrieve(dataForURL url: URL, completion: @escaping (RetrieveResult) -> Void) {}
}
