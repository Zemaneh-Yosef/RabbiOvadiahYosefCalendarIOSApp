//
//  DailyHalacha.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 12/27/25.
//

import Foundation
import KosherSwift

// MARK: - Models

struct HalachaSegment {
    let bookName: String
    let siman: Int
    let firstSeif: Int
    let seifim: String
}

struct SimanInfo {
    let simanNumber: Int
    let seifCount: Int
}

// MARK: - Halacha Yomi Logic

enum HalachaYomi {
    
    private static let startDate: Date = {
        var components = DateComponents()
        components.year = 2020
        components.month = 11
        components.day = 12
        return Calendar(identifier: .gregorian).date(from: components)!
    }()
    
    private static let rateSA = 3
    private static let rateKitzur = 5
    
    private static let nameSA = "שו\"ע - או\"ח"
    private static let nameKitzur = "קיצשו\"ע"

    static func getDailyLearning(date: Date) -> [HalachaSegment]? {
        guard date >= startDate else { return nil }

        let saStructure = SimanRepository.shulchanAruchStructure
        let kitzurStructure = SimanRepository.kitzurStructure

        let totalSaSeifim = saStructure.reduce(0) { $0 + $1.seifCount }
        let totalKitzurSeifim = kitzurStructure.reduce(0) { $0 + $1.seifCount }

        let daysInSaPhase = Int(ceil(Double(totalSaSeifim) / Double(rateSA)))
        let daysInKitzurPhase = Int(ceil(Double(totalKitzurSeifim) / Double(rateKitzur)))
        let totalDaysInCycle = daysInSaPhase + daysInKitzurPhase

        let calendar = Calendar(identifier: .gregorian)
        let daysPassed = calendar.dateComponents([.day], from: startDate, to: date).day ?? 0
        let dayInCurrentCycle = daysPassed % totalDaysInCycle

        if dayInCurrentCycle < daysInSaPhase {
            let startSeifIndex = dayInCurrentCycle * rateSA
            return calculateSegments(
                globalStartIndex: startSeifIndex,
                amountToRead: rateSA,
                structure: saStructure,
                bookName: nameSA,
                totalSeifimInBook: totalSaSeifim
            )
        } else {
            let daysIntoKitzur = dayInCurrentCycle - daysInSaPhase
            let startSeifIndex = daysIntoKitzur * rateKitzur
            return calculateSegments(
                globalStartIndex: startSeifIndex,
                amountToRead: rateKitzur,
                structure: kitzurStructure,
                bookName: nameKitzur,
                totalSeifimInBook: totalKitzurSeifim
            )
        }
    }

    private static func calculateSegments(
        globalStartIndex: Int,
        amountToRead: Int,
        structure: [SimanInfo],
        bookName: String,
        totalSeifimInBook: Int
    ) -> [HalachaSegment] {
        var results = [HalachaSegment]()

        let actualAmountToRead = min(amountToRead, totalSeifimInBook - globalStartIndex)
        let globalEndIndex = globalStartIndex + actualAmountToRead

        var currentSimanStartGlobalIndex = 0

        for simanInfo in structure {
            let simanNumber = simanInfo.simanNumber
            let seifCountInSiman = simanInfo.seifCount
            let currentSimanEndGlobalIndex = currentSimanStartGlobalIndex + seifCountInSiman

            let overlapStart = max(currentSimanStartGlobalIndex, globalStartIndex)
            let overlapEnd = min(currentSimanEndGlobalIndex, globalEndIndex)

            if overlapStart < overlapEnd {
                let localStart = (overlapStart - currentSimanStartGlobalIndex) + 1
                let localEnd = (overlapEnd - currentSimanStartGlobalIndex)

                let numberFormatter = HebrewDateFormatter()
                numberFormatter.hebrewFormat = true
                numberFormatter.useGershGershayim = false
                
                let startHebrew = numberFormatter.formatHebrewNumber(number: localStart)
                let endHebrew = numberFormatter.formatHebrewNumber(number: localEnd)
                
                let rangeString = (localStart == localEnd) ? startHebrew : "\(startHebrew)-\(endHebrew)"

                results.append(HalachaSegment(bookName: bookName, siman: simanNumber, firstSeif: localStart, seifim: rangeString))
                
                // Specific edge case logic from your Kotlin file
                if bookName == nameSA && simanNumber == 696 && localEnd == 8 {
                    results.append(HalachaSegment(bookName: bookName, siman: 697, firstSeif: 1, seifim: numberFormatter.formatHebrewNumber(number: 1)))
                }
            }

            if currentSimanEndGlobalIndex >= globalEndIndex { break }
            currentSimanStartGlobalIndex += seifCountInSiman
        }

        return results
    }
}

// MARK: - Repository

enum SimanRepository {

    static let shulchanAruchCounts: [Int] = [
        9, 6, 17, 23, 1, 4, 4, 17, 6, 12, 15, 3, 3, 5, 6, 1, 3, 3, 2, 2, 4, 1, 3, 6, 13, 2, 11, 3, 1, 5, 2, 52, 5, 4, 1, 3, 3, 13, 10, 8, 1, 3, 9, 1, 2, 9, 14, 1, 1, 1, 9, 1, 26, 3, 22, 5, 2, 7, 5, 5, 26, 5, 9, 4, 3, 10, 1, 1, 2, 5, 7, 5, 4, 6, 6, 8, 2, 1, 9, 1, 2, 2, 5, 1, 2, 1, 3, 1, 8, 27, 6, 10, 4, 9, 4, 2, 5, 5, 3, 1, 4, 5, 3, 8, 1, 2, 4, 12, 3, 8, 3, 2, 9, 9, 1, 1, 5, 1, 4, 1, 3, 3, 6, 12, 2, 4, 2, 45, 2, 1, 8, 2, 1, 2, 14, 1, 6, 1, 11, 3, 8, 2, 5, 4, 3, 4, 8, 1, 1, 5, 12, 1, 22, 15, 2, 1, 1, 13, 20, 15, 4, 10, 2, 2, 2, 1, 20, 17, 3, 22, 5, 2, 3, 8, 6, 1, 5, 7, 6, 5, 10, 7, 12, 6, 5, 2, 4, 10, 2, 5, 3, 2, 6, 3, 3, 4, 4, 1, 11, 2, 4, 18, 8, 13, 5, 6, 1, 18, 3, 2, 6, 2, 3, 1, 4, 14, 8, 9, 9, 2, 2, 4, 6, 13, 10, 1, 3, 3, 2, 5, 1, 3, 2, 2, 4, 4, 1, 2, 2, 17, 1, 1, 2, 6, 6, 5, 6, 4, 4, 2, 2, 7, 5, 9, 3, 1, 8, 1, 7, 2, 4, 3, 17, 10, 4, 13, 3, 13, 1, 2, 17, 10, 7, 4, 12, 5, 5, 1, 7, 2, 1, 7, 1, 7, 7, 5, 1, 10, 2, 2, 6, 2, 3, 5, 1, 8, 5, 15, 10, 1, 51, 13, 27, 3, 23, 14, 22, 52, 5, 9, 9, 10, 10, 12, 13, 12, 7, 19, 17, 20, 19, 6, 10, 15, 16, 13, 4, 49, 9, 11, 10, 4, 3, 27, 5, 13, 4, 8, 7, 14, 3, 1, 1, 2, 19, 3, 1, 1, 5, 3, 1, 2, 3, 2, 5, 2, 3, 14, 1, 3, 2, 12, 36, 5, 8, 15, 1, 5, 1, 8, 6, 19, 1, 4, 4, 4, 1, 5, 2, 4, 7, 20, 1, 2, 4, 9, 1, 1, 1, 2, 2, 8, 3, 3, 1, 2, 18, 11, 11, 1, 1, 1, 1, 1, 9, 1, 3, 4, 13, 3, 1, 1, 1, 2, 4, 5, 1, 5, 1, 2, 1, 7, 4, 1, 3, 4, 1, 8, 2, 1, 2, 2, 11, 4, 1, 3, 4, 2, 4, 4, 2, 11, 3, 8, 3, 4, 12, 7, 1, 7, 27, 7, 9, 4, 6, 3, 2, 1, 6, 7, 5, 7, 3, 1, 3, 6, 16, 10, 1, 3, 3, 16, 7, 1, 7, 2, 2, 2, 1, 1, 2, 1, 1, 1, 1, 1, 4, 3, 10, 9, 2, 1, 4, 3, 4, 3, 17, 20, 5, 6, 7, 4, 2, 4, 1, 9, 7, 2, 7, 11, 4, 3, 8, 11, 9, 3, 4, 9, 5, 1, 3, 4, 4, 2, 2, 12, 24, 2, 4, 1, 8, 2, 5, 3, 3, 4, 16, 6, 14, 8, 5, 2, 3, 2, 11, 5, 12, 20, 2, 4, 18, 12, 2, 25, 2, 1, 1, 1, 10, 5, 5, 13, 1, 1, 6, 8, 3, 12, 2, 3, 3, 3, 1, 5, 13, 16, 1, 1, 3, 3, 4, 9, 2, 4, 5, 23, 3, 5, 9, 9, 8, 4, 2, 1, 1, 1, 3, 1, 1, 3, 2, 1, 1, 2, 1, 4, 6, 4, 1, 4, 2, 10, 12, 4, 2, 2, 4, 10, 6, 1, 6, 4, 6, 5, 1, 3, 4, 3, 19, 13, 10, 4, 10, 4, 1, 2, 3, 2, 8, 10, 1, 1, 3, 2, 9, 11, 2, 22, 6, 2, 15, 2, 2, 1, 1, 1, 1, 9, 1, 3, 1, 3, 3, 11, 2, 1, 1, 2, 1, 3, 8, 2, 4, 2, 3, 5, 4, 1, 1, 2, 2, 3, 1, 3, 7, 3, 2, 8, 6, 18, 11, 4, 4, 4, 4, 8
    ]

    static let shulchanAruchStructure: [SimanInfo] = {
        return shulchanAruchCounts.enumerated().map { (index, count) in
            SimanInfo(simanNumber: index + 1, seifCount: count)
        }
    }()

    static let actualKitzurSeifimCounts: [Int] = [
        7, 9, 8, 6, 17, 11, 8, 6, 21, 26, 25, 15, 5, 8, 13, 5, 10, 22, 14, 12, 10, 10, 30, 12, 8, 22, 5, 13, 21, 9, 7, 27, 14, 16, 9, 28, 13, 15, 3, 21, 10, 23, 7, 18, 23, 46, 22, 10, 49, 16, 15, 18, 6, 9, 5, 7, 7, 14, 21, 15, 10, 18, 5, 4, 30, 12, 11, 12, 9, 5, 5, 23, 11, 4, 14, 23, 24, 11, 10, 94, 5, 13, 6, 19, 8, 7, 24, 18, 6, 23, 18, 10, 5, 27, 18, 15, 15, 37, 5, 22, 6, 7, 14, 21, 2, 8, 3, 7, 9, 15, 17, 6, 9, 13, 6, 18, 13, 11, 12, 11, 11, 17, 5, 22, 8, 4, 18, 16, 23, 6, 17, 5, 31, 15, 22, 10, 13, 10, 26, 3, 23, 10, 22, 9, 26, 4, 5, 4, 13, 17, 7, 17, 16, 7, 12, 3, 8, 4, 10, 6, 20, 14, 8, 10, 16, 5, 15, 7, 3, 2, 3, 3, 4, 3, 6, 8, 15, 5, 15, 16, 22, 16, 7, 11, 6, 4, 5, 5, 6, 3, 6, 10, 14, 12, 14, 22, 13, 16, 17, 11, 7, 16, 5, 11, 9, 11, 7, 15, 8, 9, 15, 5, 5, 3, 3, 2, 4, 2, 9, 10, 8
    ]

    static let kitzurStructure: [SimanInfo] = {
        let rangesToLearn: [ClosedRange<Int>] = [
            11...11,
            24...24,
            27...38,
            46...47,
            62...67,
            71...71,
            143...221
        ]

        var structure = [SimanInfo]()

        for range in rangesToLearn {
            for simanNum in range {
                let listIndex = simanNum - 1
                if listIndex >= 0 && listIndex < actualKitzurSeifimCounts.count {
                    structure.append(
                        SimanInfo(
                            simanNumber: simanNum,
                            seifCount: actualKitzurSeifimCounts[listIndex]
                        )
                    )
                }
            }
        }
        return structure
    }()
}
