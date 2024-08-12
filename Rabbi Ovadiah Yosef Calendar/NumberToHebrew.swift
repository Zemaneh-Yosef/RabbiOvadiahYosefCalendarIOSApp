//
//  NumberToHebrew.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 8/6/24.
//

import Foundation

class NumberToHebrew {
    private static let hebrewUnits: [Int: String] = [
        1: "אֶחָד",
        2: "שְׁנַיִם",
        3: "שְׁלֹשָׁה",
        4: "אַרְבָּעָה",
        5: "חֲמִשָּׁה",
        6: "שִׁשָּׁה",
        7: "שִׁבְעָה",
        8: "שְׁמֹנָה",
        9: "תִּשְׁעָה"
    ]

    private static let hebrewTens: [Int: String] = [
        10: "עָשָׂרָה",
        20: "עֶשְׂרִים",
        30: "שְׁלֹשִׁים",
        40: "אַרְבָּעִים",
        50: "חֲמִשִּׁים",
        60: "שִׁשִּׁים",
        70: "שִׁבְעִים",
        80: "שְׁמֹנִים",
        90: "תִּשְׁעִים"
    ]

    private static let hebrewHundreds: [Int: String] = [
        100: "מֵאָה",
        200: "מָאתַיִם",
        300: "שְׁלֹשׁ מֵאוֹת",
        400: "אַרְבַּע מֵאוֹת",
        500: "חֲמֵשׁ מֵאוֹת",
        600: "שֵׁשׁ מֵאוֹת",
        700: "שֶׁבַע מֵאוֹת",
        800: "שְׁמוֹנֶה מֵאוֹת",
        900: "תְּשַׁע מֵאוֹת"
    ]

    private static let hebrewThousands: [Int: String] = [
        1000: "אֶלֶף",
        2000: "אֲלָפַיִם",
        3000: "שְׁלֹשֶׁת אֲלָפִים",
        4000: "אַרְבָּעַת אֲלָפִים",
        5000: "חֲמֵשֶׁת אֲלָפִים",
        6000: "שֵׁשֶׁת אֲלָפִים",
        7000: "שִׁבְעַת אֲלָפִים",
        8000: "שְׁמוֹנַת אֲלָפִים",
        9000: "תִּשְׁעַת אֲלָפִים"
    ]

    static func numberToHebrew(_ number: Int) -> String {
        var hebrewSentence = ""

        if number <= 0 || number > 9999 {
            return "מספר לא ידוע" // Unknown number
        }

        var num = number

        if num >= 1000 {
            let thousands = (num / 1000) * 1000
            if let hebrewThousand = hebrewThousands[thousands] {
                hebrewSentence.append(hebrewThousand)
                num %= 1000
                if num > 0 {
                    hebrewSentence.append(" ו")
                }
            }
        }

        if num >= 100 {
            let hundreds = (num / 100) * 100
            if let hebrewHundred = hebrewHundreds[hundreds] {
                hebrewSentence.append(hebrewHundred)
                num %= 100
                if num > 0 {
                    hebrewSentence.append(" ו")
                }
            }
        }

        if num >= 20 {
            let tens = (num / 10) * 10
            if let hebrewTen = hebrewTens[tens] {
                hebrewSentence.append(hebrewTen)
                num %= 10
                if num > 0 {
                    hebrewSentence.append(" ו")
                }
            }
        } else if num >= 10 {
            if hebrewUnits[num - 10] != nil {
                hebrewSentence.append("עָשָׂרָה")
                num = 0
            }
        }

        if num > 0 {
            if let hebrewUnit = hebrewUnits[num] {
                hebrewSentence.append(hebrewUnit)
            }
        }

        return hebrewSentence
    }
}

