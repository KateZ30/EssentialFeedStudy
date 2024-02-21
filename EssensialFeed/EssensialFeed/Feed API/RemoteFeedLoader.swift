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
            case let .success((data, response)):
                do {
                    completion(.success(try FeedItemsMapper.map(data, from: response)))
                } catch {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private class FeedItemsMapper {
    struct Root: Decodable {
        let items: [Item]
    }

    struct Item: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL

        public init(id: UUID, description: String?, location: String?, image: URL) {
            self.id = id
            self.description = description
            self.location = location
            self.image = image
        }

        var feedItem: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }

        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.feedItem }
    }
}
