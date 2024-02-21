//
//  RemoteFeedLoader.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 2/20/24.
//

import Foundation

public protocol HTTPClient {
    typealias HTTPClientResult = Result<(Data, HTTPURLResponse), Error>
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}


public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = Swift.Result<[FeedItem], Error>

    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, _)):
                if let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    let items: [FeedItem]
}
