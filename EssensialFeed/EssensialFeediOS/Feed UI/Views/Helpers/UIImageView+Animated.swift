//
//  UIImageView+Animated.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 5/6/24.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        guard newImage != nil else { return }

        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
