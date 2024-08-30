//
//  UITableView+HeaderSizing.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 6/28/24.
//

import UIKit

extension UITableView {
    func sizeHeaderToFit() {
        guard let header = tableHeaderView else { return }

        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        if header.frame.size.height != size.height {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
}
