
import Foundation

struct DailyFat: Identifiable, Codable {
    let id: Int
    let start: Double
    let usedFat: Double
    let totalFat: Double
    let dateLabel: String
    let monthLabel: String

    internal init(id: Int, start: Double, usedFat: Double, totalFat: Double) {
        self.id = id
        self.start = start
        self.usedFat = usedFat
        self.totalFat = totalFat
        dateLabel = mdyFormatter.string(from: Date(timeIntervalSince1970: start))
        monthLabel = monthFormatter.string(from: Date(timeIntervalSince1970: start))
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(Int.self, forKey: .id)
        start = try values.decode(Double.self, forKey: .start)
        usedFat = try values.decode(Double.self, forKey: .usedFat)
        totalFat = try values.decode(Double.self, forKey: .totalFat)
        dateLabel = mdyFormatter.string(from: Date(timeIntervalSince1970: start))
        monthLabel = monthFormatter.string(from: Date(timeIntervalSince1970: start))
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case start
        case usedFat
        case totalFat
    }
}
