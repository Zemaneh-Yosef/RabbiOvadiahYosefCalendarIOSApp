//
//  DailyMishnehTorah.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 12/27/25.
//

import Foundation

struct RambamReading {
    let bookName: String
    let chapter: String // String because it can be a number ("1") or a range ("1-21")
}

enum DailyMishnehTorah {
    
    private static let cycleLength = 1017
    
    // April 29, 1984
    private static let startDate: Date = {
        var components = DateComponents()
        components.year = 1984
        components.month = 4
        components.day = 29
        return Calendar(identifier: .gregorian).date(from: components)!
    }()

    // Special formatting for the first 4 books
    private static let specialVerseRanges: [[String]] = [
        ["1-21", "22-33", "34-45"], // Transmission of the Oral Law
        ["1-83", "84-166", "167-248"], // Positive Mitzvot
        ["1-122", "123-245", "246-365"], // Negative Mitzvot
        ["1:1-4:8", "5:1-9:9", "10:1-14:10"] // Overview of Mishneh Torah Contents
    ]

    private struct Book {
        let name: String
        let chapterCount: Int
    }

    private static let books: [Book] = [
        Book(name: "הקדמת הרמב\"ם", chapterCount: 3),
        Book(name: "מצוות עשה", chapterCount: 3),
        Book(name: "מצוות לא תעשה", chapterCount: 3),
        Book(name: "תוכן ההלכות", chapterCount: 3),
        Book(name: "הלכות יסודי התורה", chapterCount: 10),
        Book(name: "הלכות דעות", chapterCount: 7),
        Book(name: "הלכות תלמוד תורה", chapterCount: 7),
        Book(name: "הלכות עבודה זרה וחוקות הגויים", chapterCount: 12),
        Book(name: "הלכות תשובה", chapterCount: 10),
        Book(name: "הלכות קריאת שמע", chapterCount: 4),
        Book(name: "הלכות תפילה וברכת כהנים", chapterCount: 15),
        Book(name: "הלכות תפילין ומזוזה וספר תורה", chapterCount: 10),
        Book(name: "הלכות ציצית", chapterCount: 3),
        Book(name: "הלכות ברכות", chapterCount: 11),
        Book(name: "הלכות מילה", chapterCount: 3),
        Book(name: "סדר התפילה", chapterCount: 4),
        Book(name: "הלכות שבת", chapterCount: 30),
        Book(name: "הלכות ערובין", chapterCount: 8),
        Book(name: "הלכות שביתת עשור", chapterCount: 3),
        Book(name: "הלכות שביתת יום טוב", chapterCount: 8),
        Book(name: "הלכות חמץ ומצה", chapterCount: 9),
        Book(name: "הלכות שופר וסוכה ולולב", chapterCount: 8),
        Book(name: "הלכות שקלים", chapterCount: 4),
        Book(name: "הלכות קידוש החודש", chapterCount: 19),
        Book(name: "הלכות תעניות", chapterCount: 5),
        Book(name: "הלכות מגילה וחנוכה", chapterCount: 4),
        Book(name: "הלכות אישות", chapterCount: 25),
        Book(name: "הלכות גירושין", chapterCount: 13),
        Book(name: "הלכות ייבום וחליצה", chapterCount: 8),
        Book(name: "הלכות נערה בתולה", chapterCount: 3),
        Book(name: "הלכות סוטה", chapterCount: 4),
        Book(name: "הלכות איסורי ביאה", chapterCount: 22),
        Book(name: "הלכות מאכלות אסורות", chapterCount: 17),
        Book(name: "הלכות שחיטה", chapterCount: 14),
        Book(name: "הלכות שבועות", chapterCount: 12),
        Book(name: "הלכות נדרים", chapterCount: 13),
        Book(name: "הלכות נזירות", chapterCount: 10),
        Book(name: "הלכות ערכים וחרמים", chapterCount: 8),
        Book(name: "הלכות כלאיים", chapterCount: 10),
        Book(name: "הלכות מתנות עניים", chapterCount: 10),
        Book(name: "הלכות תרומות", chapterCount: 15),
        Book(name: "הלכות מעשרות", chapterCount: 14),
        Book(name: "הלכות מעשר שני ונטע רבעי", chapterCount: 11),
        Book(name: "הלכות ביכורים ושאר מתנות כהונה שבגבולין", chapterCount: 12),
        Book(name: "הלכות שמיטה ויובל", chapterCount: 13),
        Book(name: "הלכות בית הבחירה", chapterCount: 8),
        Book(name: "הלכות כלי המקדש והעובדים בו", chapterCount: 10),
        Book(name: "הלכות ביאת המקדש", chapterCount: 9),
        Book(name: "הלכות איסורי מזבח", chapterCount: 7),
        Book(name: "הלכות מעשה הקרבנות", chapterCount: 19),
        Book(name: "הלכות תמידין ומוספין", chapterCount: 10),
        Book(name: "הלכות פסולי המוקדשין", chapterCount: 19),
        Book(name: "הלכות עבודת יום הכיפורים", chapterCount: 5),
        Book(name: "הלכות מעילה", chapterCount: 8),
        Book(name: "הלכות קרבן פסח", chapterCount: 10),
        Book(name: "הלכות חגיגה", chapterCount: 3),
        Book(name: "הלכות בכורות", chapterCount: 8),
        Book(name: "הלכות שגגות", chapterCount: 15),
        Book(name: "הלכות מחוסרי כפרה", chapterCount: 5),
        Book(name: "הלכות תמורה", chapterCount: 4),
        Book(name: "הלכות טומאת מת", chapterCount: 25),
        Book(name: "הלכות פרה אדומה", chapterCount: 15),
        Book(name: "הלכות טומאת צרעת", chapterCount: 16),
        Book(name: "הלכות מטמאי משכב ומושב", chapterCount: 13),
        Book(name: "הלכות שאר אבות הטומאות", chapterCount: 20),
        Book(name: "הלכות טומאת אוכלין", chapterCount: 16),
        Book(name: "הלכות כלים", chapterCount: 28),
        Book(name: "הלכות מקוואות", chapterCount: 11),
        Book(name: "הלכות נזקי ממון", chapterCount: 14),
        Book(name: "הלכות גנבה", chapterCount: 9),
        Book(name: "הלכות גזילה ואבידה", chapterCount: 18),
        Book(name: "הלכות חובל ומזיק", chapterCount: 8),
        Book(name: "הלכות רוצח ושמירת נפש", chapterCount: 13),
        Book(name: "הלכות מכירה", chapterCount: 30),
        Book(name: "הלכות זכייה ומתנה", chapterCount: 12),
        Book(name: "הלכות שכנים", chapterCount: 14),
        Book(name: "הלכות שלוחין ושותפין", chapterCount: 10),
        Book(name: "הלכות עבדים", chapterCount: 9),
        Book(name: "הלכות שכירות", chapterCount: 13),
        Book(name: "הלכות שאלה ופיקדון", chapterCount: 8),
        Book(name: "הלכות מלווה ולווה", chapterCount: 27),
        Book(name: "הלכות טוען ונטען", chapterCount: 16),
        Book(name: "הלכות נחלות", chapterCount: 11),
        Book(name: "הלכות סנהדרין והעונשין המסורין להם", chapterCount: 26),
        Book(name: "הלכות עדות", chapterCount: 22),
        Book(name: "הלכות ממרים", chapterCount: 7),
        Book(name: "הלכות אבל", chapterCount: 14),
        Book(name: "הלכות מלכים ומלחמות", chapterCount: 12)
    ]

    // --- 1 Chapter Per Day Logic ---

    /// Calculates Daily Rambam (Mishneh Torah) for 1 chapter a day cycle.
    static func getDailyLearning(date: Date) -> RambamReading? {
        guard date >= startDate else { return nil }

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day], from: startDate, to: date)
        guard let daysDifference = components.day else { return nil }
        
        let cycleIndex = daysDifference % cycleLength

        return getChapterByIndex(index: cycleIndex)
    }

    // --- 3 Chapters Per Day Logic ---

    /// Calculates Daily Rambam (Mishneh Torah) for 3 chapters a day cycle.
    static func getDailyLearning3(date: Date) -> [RambamReading]? {
        guard date >= startDate else { return nil }

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day], from: startDate, to: date)
        guard let daysDifference = components.day else { return nil }

        let cycleLength3 = cycleLength / 3
        let dayInCycle = daysDifference % cycleLength3

        let baseIndex = dayInCycle * 3

        guard let r1 = getChapterByIndex(index: baseIndex),
              let r2 = getChapterByIndex(index: baseIndex + 1),
              let r3 = getChapterByIndex(index: baseIndex + 2) else {
            return nil
        }

        if r1.bookName == r2.bookName && r2.bookName == r3.bookName {
            return [combineReadings(first: r1, last: r3)]
        } else if r1.bookName == r2.bookName {
            return [combineReadings(first: r1, last: r2), r3]
        } else if r2.bookName == r3.bookName {
            return [r1, combineReadings(first: r2, last: r3)]
        }

        return [r1, r2, r3]
    }

    private static func combineReadings(first: RambamReading, last: RambamReading) -> RambamReading {
        let startChapter = first.chapter
        let endChapter = last.chapter

        let rangeString: String
        if startChapter.contains("-") || endChapter.contains("-") {
            let firstPart = startChapter.components(separatedBy: "-").first ?? startChapter
            let lastPart = endChapter.components(separatedBy: "-").last ?? endChapter
            rangeString = "\(firstPart)-\(lastPart)"
        } else {
            rangeString = "\(startChapter)-\(endChapter)"
        }

        return RambamReading(bookName: first.bookName, chapter: rangeString)
    }

    // --- Core Calculation Logic ---

    private static func getChapterByIndex(index: Int) -> RambamReading? {
        var remainingChapters = index

        for (bookIndex, book) in books.enumerated() {
            if remainingChapters < book.chapterCount {
                let chapterNum = remainingChapters + 1

                let chapterDisplay: String
                if bookIndex < 4 {
                    chapterDisplay = specialVerseRanges[bookIndex][chapterNum - 1]
                } else {
                    chapterDisplay = String(chapterNum)
                }

                return RambamReading(bookName: book.name, chapter: chapterDisplay)
            }
            remainingChapters -= book.chapterCount
        }
        return nil
    }
}
