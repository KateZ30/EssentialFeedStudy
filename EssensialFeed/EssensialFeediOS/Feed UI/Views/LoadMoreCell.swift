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
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        return indicator
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        contentView.addSubview(label)
        label.textColor = .tertiaryLabel
        label.font = .preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            contentView.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            contentView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 8)
        ])

        return label

    }()

    public var isLoading: Bool {
        get { indicator.isAnimating }
        set { newValue ? indicator.startAnimating() : indicator.stopAnimating() }
    }


    public var message: String? {
        get { messageLabel.text }
        set { messageLabel.text = newValue }
    }

}
