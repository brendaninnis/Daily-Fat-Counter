
import Foundation

class DebugLog {
    static func log(_ message: String) {
        #if DEBUG
        NSLog(message)
        #endif
    }
}
