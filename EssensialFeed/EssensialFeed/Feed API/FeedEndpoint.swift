//
//  FeedEndpoint.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 8/13/24.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
