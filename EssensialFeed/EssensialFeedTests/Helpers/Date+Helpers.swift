//
//  Date+Helpers.swift
//  EssensialFeedTests
//
//  Created by Kate Zemskova on 7/22/24.
//

import Foundation

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        addingTimeInterval(seconds)
    }

    func adding(minutes: Int) -> Date {
        addingTimeInterval(TimeInterval(minutes * 60))
    }

    func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
