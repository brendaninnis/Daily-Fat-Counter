//
//  DateFormatters.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-06-07.
//

import Foundation

let currentDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d"
    formatter.timeZone = TimeZone.autoupdatingCurrent
    return formatter
}()

let mdyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM dd, YYYY"
    formatter.timeZone = TimeZone.autoupdatingCurrent
    return formatter
}()

let shortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM dd"
    formatter.timeZone = TimeZone.autoupdatingCurrent
    return formatter
}()

let monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM"
    formatter.timeZone = TimeZone.autoupdatingCurrent
    return formatter
}()
