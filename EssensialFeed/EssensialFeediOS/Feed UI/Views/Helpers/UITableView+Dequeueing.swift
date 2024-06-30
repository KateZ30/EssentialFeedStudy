//
//  UITableView+Dequeueing.swift
//  EssensialFeediOS
//
//  Created by Kate Zemskova on 5/6/24.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
