//
//  WeakRefVirtualProxy.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 5/10/24.
//

import UIKit
import EssensialFeed
import EssensialFeediOS

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: FeedErrorView where T: FeedErrorView {
    func display(_ model: FeedErrorViewModel) {
        object?.display(model)
    }
}
