//
//  UIRefreshControl+TestHelpers.swift
//  EssensialFeediOSTests
//
//  Created by Kate Zemskova on 4/24/24.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
