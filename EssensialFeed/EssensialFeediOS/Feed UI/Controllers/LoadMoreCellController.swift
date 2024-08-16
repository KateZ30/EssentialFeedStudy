//
//  LoadMoreCellController.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 8/15/24.
//

import UIKit
import EssensialFeed

public class LoadMoreCellController: NSObject, UITableViewDataSource {
    private let cell = LoadMoreCell()

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }
}

extension LoadMoreCellController: ResourceLoadingView {
    public func display(_ viewModel: ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
}

extension LoadMoreCellController: ResourceErrorView {
    public func display(_ viewModel: ResourceErrorViewModel) {
        cell.message = viewModel.message
    }
}
