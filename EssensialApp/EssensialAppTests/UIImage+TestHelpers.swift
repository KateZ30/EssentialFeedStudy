//
//  UIImage+TestHelpers.swift
//  EssensialAppTests
//
//  Created by Kate Zemskova on 6/28/24.
//

import UIKit

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { context in
            color.setFill()
            context.fill(rect)
        }
    }
}
