//
//  FeedImageDataMapper.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 8/29/24.
//

import Foundation

public final class FeedImageDataMapper {
    public enum Error: Swift.Error {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.isOK200, !data.isEmpty else {
            throw Error.invalidData
        }

        return data
    }
}
