//
//  HTTPURLResponse+StatusCode.swift
//  EssensialFeed
//
//  Created by Kate Zemskova on 8/29/24.
//

import Foundation

extension HTTPURLResponse {
    var isOK2xx: Bool {
        (200...299).contains(statusCode)
    }

    var isOK200: Bool {
        statusCode == 200
    }
}
