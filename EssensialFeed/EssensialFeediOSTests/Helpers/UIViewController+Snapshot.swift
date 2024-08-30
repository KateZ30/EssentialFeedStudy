//
//  UIViewController+Snapshot.swift
//  EssensialFeediOSTests
//
//  Created by Kate Zemskova on 7/23/24.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection

    static func iPhone8(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        SnapshotConfiguration(
            size: CGSize(width: 375, height: 667),
            safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
            layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
            traitCollection: UITraitCollection(mutations: { mutableTraits in
                mutableTraits.forceTouchCapability = .available
                mutableTraits.displayScale = 2
                mutableTraits.userInterfaceIdiom = .phone
                mutableTraits.horizontalSizeClass = .compact
                mutableTraits.verticalSizeClass = .regular
                mutableTraits.layoutDirection = .leftToRight
                mutableTraits.preferredContentSizeCategory = contentSize
                mutableTraits.userInterfaceStyle = style
                mutableTraits.displayGamut = .P3
            }))
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone8(style: .light)
    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }
    override var traitCollection: UITraitCollection {
        return configuration.traitCollection
    }

    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }

    func snapshot() -> UIImage {
        return UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection)).image { action in
            layer.render(in: action.cgContext)
        }
    }
}
