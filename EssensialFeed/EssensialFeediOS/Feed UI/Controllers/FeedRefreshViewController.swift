//
//  FeedRefreshViewController.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 4/30/24.
//

import UIKit

public final class FeedRefreshViewController: NSObject {
    public private(set) lazy var view = binded(UIRefreshControl())

    private let viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    @objc func refresh() {
        viewModel.loadFeed()
    }

    public func setView(_ view: UIRefreshControl) {
        self.view = binded(view)
    }

    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onChange = { viewModel in
            if viewModel.isLoading {
                view.beginRefreshing()
            } else {
                view.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
