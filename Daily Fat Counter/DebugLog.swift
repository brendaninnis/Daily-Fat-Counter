//
//  DebugLog.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-04-17.
//

import Foundation

class DebugLog {
    static func log(_ message: String) {
        #if DEBUG
        NSLog(message)
        #endif
    }
}
