//
//  RemoteFeedItem.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 2/27/24.
//

import Foundation

struct RemoteFeedItem: Decodable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let image: URL
}
