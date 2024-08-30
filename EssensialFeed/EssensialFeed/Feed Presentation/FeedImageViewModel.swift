//
//  FeedImageViewModel.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 5/3/24.
//

import Foundation

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?

    public var hasLocation: Bool {
        return location != nil
    }
}
