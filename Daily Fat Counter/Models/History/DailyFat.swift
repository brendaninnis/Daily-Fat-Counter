
import Foundation

// ID in the format 0xYYYYMMDD
let DAY_MASK   = 0x000000FF
let MONTH_MASK = 0x0000FF00
let YEAR_MASK  = 0xFFFF0000

let MONTH_SHIFT = 8
let YEAR_SHIFT  = 16

struct DailyFat: Identifiable, Codable {
    let id      : Int
    let usedFat : Double
    let totalFat: Double
    
    var dateLabel: String {
        let year  = (id & YEAR_MASK) >> YEAR_SHIFT
        let day   = (id & DAY_MASK)
        return String(format: "%@ %02d, %04d", monthLabel, day, year)
    }
    
    var monthLabel: String {
        let month = (id & MONTH_MASK) >> MONTH_SHIFT
        return DateFormatter().monthSymbols[month - 1]
    }
    
    static func createDailyFat(year: Int, month: Int, day: Int, usedFat: Double, totalFat: Double) -> DailyFat {
        let id = year << YEAR_SHIFT + month << MONTH_SHIFT + day
        return DailyFat(id: id, usedFat: usedFat, totalFat: totalFat)
    }
}
