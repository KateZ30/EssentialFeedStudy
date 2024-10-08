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

extension WeakRefVirtualProxy: ResourceLoadingView where T: ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceView where T: ResourceView, T.ResourceViewModel == UIImage {
    func display(_ model: UIImage) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: ResourceErrorView where T: ResourceErrorView {
    func display(_ model: ResourceErrorViewModel) {
        object?.display(model)
    }
}
