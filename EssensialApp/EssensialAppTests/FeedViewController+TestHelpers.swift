//
//  FeedViewController+TestHelpers.swift
//  EssensialFeediOSTests
//
//  Created by Kate Zemskova on 4/24/24.
//

import UIKit
import EssensialFeediOS

extension ListViewController {
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }

        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }

    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }

    var errorMessage: String? {
        return errorView.message
    }

    func simulateTapOnErrorView() {
        errorView.simulateTap()
    }

    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithSpyForiOS17Support()
    }

    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }

    private func replaceRefreshControlWithSpyForiOS17Support() {
        let spyRefreshControl = UIRefreshControlSpy()

        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                spyRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }

        refreshControl = spyRefreshControl
    }
}

// Feed specific helpers
extension ListViewController {
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }

    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)

        let delegate = tableView.delegate
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: IndexPath(row: row, section: feedImagesSection))

        return view
    }

    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }

    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)

        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }

    var numberOfRenderedFeedImageViews: Int {
        tableView.numberOfSections == 0 ? 0 :
            tableView.numberOfRows(inSection: feedImagesSection)
    }

    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }

    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: feedImagesSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }

    private var feedImagesSection: Int { 0 }
}

// Comments specific helpers
extension ListViewController {
    var numberOfRenderedComments: Int {
        tableView.numberOfSections == 0 ? 0 :
            tableView.numberOfRows(inSection: commentsSection)
    }

    func commentView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedComments > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: commentsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }

    private func commentCell(at row: Int) -> ImageCommentCell? {
        commentView(at: row) as? ImageCommentCell
    }


    func commentMessage(at row: Int) -> String? {
        return commentCell(at: row)?.messageLabel.text
    }

    func commentUsername(at row: Int) -> String? {
        return commentCell(at: row)?.usernameLabel?.text
    }

    private var commentsSection: Int { 0 }
}

private class UIRefreshControlSpy: UIRefreshControl {
    private var _isRefreshing = false

    override var isRefreshing: Bool { _isRefreshing }

    override func beginRefreshing() {
        _isRefreshing = true
    }

    override func endRefreshing() {
        _isRefreshing = false
    }
}
