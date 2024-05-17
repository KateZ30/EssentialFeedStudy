//
//  ErrorView.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 5/16/24.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private(set) public var button: UIButton!

    public var message: String? {
        get { return isVisible ? button.title(for: .normal) : nil }
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

    public override func awakeFromNib() {
        super.awakeFromNib()

        button.setTitle(nil, for: .normal)
        alpha = 0
    }

    private func show(message: String) {
        button.setTitle(message, for: .normal)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @IBAction private func hideMessage() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed {
                    self.button.setTitle(nil, for: .normal)
                }
            })
    }
}
