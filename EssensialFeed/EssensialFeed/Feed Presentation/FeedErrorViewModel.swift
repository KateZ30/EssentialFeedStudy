//
//  FeedErrorViewModel.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 5/16/24.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?

    public static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }

    public static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
