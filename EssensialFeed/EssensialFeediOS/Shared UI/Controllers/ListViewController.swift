//
//  ListViewController.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 4/24/24.
//

import UIKit
import EssensialFeed

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
        let ds = cellController(for: indexPath).dataSource
        return ds.tableView(tableView, cellForRowAt: indexPath)
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard tableModel.count > indexPath.row else { return }
        let dl = removeLoadingController(for: indexPath)?.delegate
        dl?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = cellController(for: indexPath).dataSourcePrefetching
            dsp?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let dsp = removeLoadingController(for: indexPath)?.dataSourcePrefetching
            dsp?.tableView?(tableView, cancelPrefetchingForRowsAt:[indexPath])
        }
    }

    private func cellController(for indexPath: IndexPath) -> CellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }

    private func removeLoadingController(for indexPath: IndexPath) -> CellController? {
        let controller = loadingControllers[indexPath]
        loadingControllers[indexPath] = nil
        return controller
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
