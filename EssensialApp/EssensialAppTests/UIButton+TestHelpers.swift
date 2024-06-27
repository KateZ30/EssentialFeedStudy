//
//  UIButton+TestHelpers.swift
//  EssensialFeediOSTests
//
//  Created by Kate Zemskova on 4/30/24.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
