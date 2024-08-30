//
//  ErrorView.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 5/16/24.
//

import UIKit

public final class ErrorView: UIButton {
    public var onHide: (() -> Void)?

    public var message: String? {
        get { return isVisible ? configuration?.title : nil }
        set {
            if let msg = newValue {
                show(message: msg)
            } else {
                hideMessage()
            }
        }
    }

    private var isVisible: Bool {
        return alpha > 0
    }

    private var titleAttributes: AttributeContainer {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        return AttributeContainer([.paragraphStyle: paragraphStyle,
                                   .font: UIFont.preferredFont(forTextStyle: .body)])
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func configure() {
        var configuration = Configuration.plain()
        configuration.titlePadding = 0
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .errorBackgroundColor
        configuration.background.cornerRadius = 0
        self.configuration = configuration
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        hideMessage()
    }

    private func hideMessage() {
        alpha = 0
        configuration?.attributedTitle = nil
        configuration?.contentInsets = .zero

        onHide?()
    }

    private func show(message: String) {
        configuration?.attributedTitle = AttributedString(message, attributes: titleAttributes)
        configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed {
                    self.hideMessage()
                }
            })
    }
}

extension UIColor {
    static let errorBackgroundColor = UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
}
