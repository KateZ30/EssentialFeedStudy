//
//  FeedViewController+Localization.swift
//  EssensialFeediOSTests
//
//  Created by Kate Zemskova on 5/6/24.
//

import Foundation
import XCTest
import EssensialFeed

extension FeedUIIntegrationTests {
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }

    var feedTitle: String {
        FeedPresenter.title
    }

    private class DummyView: ResourceView {
        func display(_ viewModel: Any) {}
    }
}
