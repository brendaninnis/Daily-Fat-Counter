
import Foundation
import SwiftUI
import WatchConnectivity

class DailyFatStore: ObservableObject {
    @Published var history: [DailyFat] = []

    private static func oldFileUrl() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("history.data")
    }

    static func fileURL() throws -> URL {
        guard let url = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: APP_GROUP_IDENTIFIER)?
            .appendingPathComponent("history.data")
        else {
            throw DailyFatStoreError.appGroupNotFound
        }
        return url
    }

    static func load(completion: @escaping (Result<[DailyFat], Error>) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            // If there is a Daily Fat store file from an old install, we need to first copy that data to the new file
            migrateStoreIfNeeded()

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

    static func save(history: [DailyFat], completion: @escaping (Result<Int, Error>) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
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

    private static func migrateStoreIfNeeded() {
        do {
            let oldUrl = try oldFileUrl()
            let path: String
            if #available(iOS 16.0, watchOS 9.0, *) {
                path = oldUrl.path()
            } else {
                path = oldUrl.path
            }
            guard FileManager.default.fileExists(atPath: path) else {
                // Nothing to migrate
                return
            }
            DebugLog.log("Start Daily Fat store migration")
            let file = try FileHandle(forReadingFrom: oldUrl)
            try file.availableData.write(to: try fileURL())
            try FileManager.default.removeItem(at: oldUrl)
            DebugLog.log("Daily Fat store migrated successfully")
        } catch {
            DebugLog.log("Failed to migrate old data store: \(error)")
        }
    }
}

// MARK: CounterDataDelegate

extension DailyFatStore: CounterDataDelegate {
    func newDailyFat(start: Double, usedFat: Double, totalFat: Double) {
        history.insert(DailyFat(id: history.count,
                                start: start,
                                usedFat: usedFat,
                                totalFat: totalFat),
                       at: 0)
        Self.save(history: history) { [self] result in
            switch result {
            case let .success(count):
                DebugLog.log("Daily fat #\(count) saved.")
                updateCompanion()
            case let .failure(error):
                DebugLog.log("Failed to save daily fat: \(error.localizedDescription)")
            }
        }
    }

    func historyDidUpdate() {
        // Reload updated history
        Self.load { result in
            switch result {
            case let .success(history):
                self.history = history
            case let .failure(failure):
                DebugLog.log("Failed to load updated history")
                DebugLog.log(failure.localizedDescription)
            }
        }
    }

    func updateCompanion() {
        guard let url = try? Self.fileURL() else {
            return
        }
        WCSession.default.transferFile(url, metadata: nil)
    }
}

// MARK: - Errors

enum DailyFatStoreError: Error {
    case appGroupNotFound
}
