//
//  FeedRefreshViewController.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 4/30/24.
//

import UIKit

public final class FeedRefreshViewController: NSObject, FeedLoadingView {
    public lazy var view = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()

    private let loadFeed: () -> Void

    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }

    @objc func refresh() {
        loadFeed()
    }

    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
}
