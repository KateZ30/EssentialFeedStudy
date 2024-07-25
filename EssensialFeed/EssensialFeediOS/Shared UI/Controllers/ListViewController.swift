//
//  ListViewController.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 4/24/24.
//

import UIKit
import EssensialFeed

public protocol CellController {
    func view(in tableView: UITableView) -> UITableViewCell
}

public extension CellController {
    func preload() {}
    func cancelLoad() {}
}

final public class ListViewController: UITableViewController, UITableViewDataSourcePrefetching, ResourceLoadingView , ResourceErrorView {
    public var onRefresh: (() -> Void)?

    private var loadingControllers = [IndexPath: CellController]()

    private var tableModel: [CellController] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    @IBOutlet public private(set) weak var errorView: ErrorView!

    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        refresh()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeHeaderToFit()
    }

    @IBAction private func refresh() {
        onRefresh?()
    }

    public func display(_ cellControllers: [CellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(for: indexPath).view(in: tableView)
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableModel.count > indexPath.row else { return }
        cancelCellControllerLoad(for: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(for: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    private func cellController(for indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }

    private func cancelCellControllerLoad(for indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }

    // MARK: - FeedErrorView
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }

    func hideError() {
        errorView.message = nil
    }

    public func display(_ viewModel: ResourceLoadingViewModel) {
        if viewModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
}
