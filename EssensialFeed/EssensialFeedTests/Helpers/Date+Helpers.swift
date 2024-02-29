//
//  Date+Helpers.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 2/28/24.
//

import Foundation

extension Date {
    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }

    func adding(seconds: TimeInterval) -> Date {
        addingTimeInterval(seconds)
    }
}
