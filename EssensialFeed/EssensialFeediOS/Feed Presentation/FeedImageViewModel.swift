//
//  FeedImageViewModel.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 5/3/24.
//

import Foundation

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool

    var hasLocation: Bool {
        return location != nil
    }
}
