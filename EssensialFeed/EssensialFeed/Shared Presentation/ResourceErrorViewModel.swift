//
//  FeedErrorViewModel.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 5/16/24.
//

import Foundation

public struct ResourceErrorViewModel {
    public let message: String?

    public static var noError: ResourceErrorViewModel {
        return ResourceErrorViewModel(message: nil)
    }

    public static func error(message: String) -> ResourceErrorViewModel {
        return ResourceErrorViewModel(message: message)
    }
}
