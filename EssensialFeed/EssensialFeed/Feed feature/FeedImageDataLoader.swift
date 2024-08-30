//
//  FeedImageDataLoader.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 4/30/24.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
}
