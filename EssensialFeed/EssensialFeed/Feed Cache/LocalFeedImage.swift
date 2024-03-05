//
//  LocalFeedItem.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 2/27/24.
//

import Foundation

public struct LocalFeedImage: Equatable, Codable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL

    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
