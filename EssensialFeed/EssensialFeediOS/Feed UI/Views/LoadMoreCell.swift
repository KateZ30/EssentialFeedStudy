//
//  LoadMoreCell.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 8/15/24.
//

import UIKit

public class LoadMoreCell: UITableViewCell {
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        contentView.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(lessThanOrEqualToConstant: 40)
        ])
        return indicator
    }()

    public var isLoading: Bool {
        get { indicator.isAnimating }
        set { newValue ? indicator.startAnimating() : indicator.stopAnimating() }
    }
}
