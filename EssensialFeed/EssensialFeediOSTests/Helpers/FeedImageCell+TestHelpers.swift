//
//  FeedImageCell+TestHelpers.swift
//  EssensialFeediOSTests
//
//  Created by Kate Zemskova on 4/26/24.
//
import UIKit
import EssensialFeediOS

extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }

    var locationText: String? {
        return locationLabel.text
    }

    var descriptionText: String? {
        return descriptionLabel.text
    }

    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }

    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }

    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }
}
