//
//  DailyFatStore.swift
//  Daily Fat Counter
//
//  Created by Brendan Innis on 2022-04-15.
//

import Foundation
import SwiftUI

class DailyFatStore: ObservableObject {
    @Published var history: [DailyFat] = [
        DailyFat(id: 0x07E60709, usedFat: 25, totalFat: 45),
        DailyFat(id: 0x07E6070A, usedFat: 45, totalFat: 45),
        DailyFat(id: 0x07E6070B, usedFat: 105, totalFat: 45),
        DailyFat(id: 0x07E6070C, usedFat: 30, totalFat: 45),
        DailyFat(id: 0x07E6070D, usedFat: 32, totalFat: 45),
        DailyFat(id: 0x07E6070E, usedFat: 10, totalFat: 45),
        DailyFat(id: 0x07E6070F, usedFat: 39, totalFat: 45),

        DailyFat(id: 0x07E60809, usedFat: 25, totalFat: 45),
        DailyFat(id: 0x07E6080A, usedFat: 45, totalFat: 45),
        DailyFat(id: 0x07E6080B, usedFat: 105, totalFat: 45),
        DailyFat(id: 0x07E6080C, usedFat: 30, totalFat: 45),
        DailyFat(id: 0x07E6080D, usedFat: 32, totalFat: 45),
        DailyFat(id: 0x07E6080E, usedFat: 10, totalFat: 45),
        DailyFat(id: 0x07E6080F, usedFat: 39, totalFat: 45),
        
        DailyFat(id: 0x07E60909, usedFat: 25, totalFat: 45),
        DailyFat(id: 0x07E6090A, usedFat: 45, totalFat: 45),
        DailyFat(id: 0x07E6090B, usedFat: 105, totalFat: 45),
        DailyFat(id: 0x07E6090C, usedFat: 30, totalFat: 45),
        DailyFat(id: 0x07E6090D, usedFat: 32, totalFat: 45),
        DailyFat(id: 0x07E6090E, usedFat: 10, totalFat: 45),
        DailyFat(id: 0x07E6090F, usedFat: 39, totalFat: 45),
    ]
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false)
        .appendingPathComponent("history.data")
    }
    
    static func load(completion: @escaping (Result<[DailyFat], Error>)->Void) {
//        DispatchQueue.global(qos: .background).async {
//            do {
//                let fileURL = try fileURL()
//                guard let file = try? FileHandle(forReadingFrom: fileURL) else {
//                    DispatchQueue.main.async {
//                        completion(.success([]))
//                    }
//                    return
//                }
//                let history = try JSONDecoder().decode([DailyFat].self, from: file.availableData)
//                DispatchQueue.main.async {
//                    completion(.success(history))
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//        }
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
