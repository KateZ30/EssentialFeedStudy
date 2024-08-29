//
//  FeedImagePresenter.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 5/3/24.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location)
    }
}
