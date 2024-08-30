//
//  ImageCommentsEndpoint.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 8/13/24.
//

import Foundation

public enum ImageCommentsEndpoint {
    case get(UUID)

    public func url(baseURL: URL) -> URL {
        switch self {
        case let .get(id):
            return baseURL.appendingPathComponent("/v1/image/\(id.uuidString)/comments")
        }
    }
}
