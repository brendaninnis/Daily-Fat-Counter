
import Foundation
import SwiftUI

class DailyFatStore: ObservableObject {
    @Published var history: [DailyFat] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        .appendingPathComponent("history.data")
    }
    
    static func load(completion: @escaping (Result<[DailyFat], Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let fileURL = try fileURL()
                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                    DispatchQueue.main.async {
                        completion(.success([]))
                    }
                    return
                }
                let history = try JSONDecoder().decode([DailyFat].self, from: file.availableData)
                DispatchQueue.main.async {
                    completion(.success(history))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    static func save(history: [DailyFat], completion: @escaping (Result<Int, Error>)->Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(history)
                let outfile = try fileURL()
                try data.write(to: outfile)
                DispatchQueue.main.async {
                    completion(.success(history.count))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: CounterDataDelegate
extension DailyFatStore: CounterDataDelegate {
    func newDailyFat(_ dailyFat: DailyFat) {
        guard dailyFat.id > history.first?.id ?? -1 else {
            print("Daily fat already logged for \(dailyFat.dateLabel)")
            return
        }
        history.insert(dailyFat, at: 0)
        Self.save(history: history) { result in
            switch result {
            case .success(let count):
                print("Daily fat #\(count) saved for \(dailyFat.dateLabel)")
            case .failure(let error):
                print("Failed to save daily fat: \(error.localizedDescription)")
            }
        }
    }
}
