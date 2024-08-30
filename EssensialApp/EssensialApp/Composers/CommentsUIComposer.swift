//
//  CommentsUIComposer.swift
//  EssensialApp
//
//  Created by Kate Zemskova on 8/9/24.
//

import Foundation

import Combine
import UIKit
import EssensialFeed
import EssensialFeediOS

public final class CommentsUIComposer {
    private init() {}

    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>

    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
        let presentationAdapter = CommentsPresentationAdapter(loader: commentsLoader)
        let commentsController = ListViewController.makeWith(title: ImageCommentsPresenter.title)
        commentsController.onRefresh = presentationAdapter.load
        presentationAdapter.presenter = LoadResourcePresenter(
            resourceView: CommentsViewAdapter(controller: commentsController),
            loadingView: WeakRefVirtualProxy(commentsController),
            errorView: WeakRefVirtualProxy(commentsController),
            mapper: { ImageCommentsPresenter.map($0) })
        return commentsController
    }
}

private extension ListViewController {
    static func makeWith(title: String) -> ListViewController {
        let storyboard = UIStoryboard(name: "ImageComments", bundle: Bundle(for: ListViewController.self))
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.title = title
        return controller
    }
}

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?

    init(controller: ListViewController?) {
        self.controller = controller
    }

    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map {
            CellController(id: $0, ImageCommentCellController(model: $0))
        })
    }
}
