//
//  WeeklySephardicHaftarot.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 3/16/26.
//

import Foundation
import KosherSwift

struct HaftarahReading {
    let text: String
    let source: String
}

struct WeeklySephardicHaftarot {
    
    private static let specialShabbatot: [JewishCalendar.Parsha: HaftarahReading] = [
        .SHKALIM: HaftarahReading(text: "ויכרת יהוידע", source: "מלכים ב י\"א"),
        .ZACHOR: HaftarahReading(text: "ויאמר שמואל", source: "שמואל א ט\"ו"),
        .PARA: HaftarahReading(text: "ויהי דבר", source: "יחזקאל ל\"ו"),
        .HACHODESH: HaftarahReading(text: "כה אמר", source: "יחזקאל מ\"ה"),
        .HAGADOL: HaftarahReading(text: "וערבה", source: "מלאכי ג")
    ]
    
    static func getThisWeeksHaftarah(jCal: JewishCalendar) -> HaftarahReading {
        
        let special = jCal.getSpecialShabbos()// Special Shabbatot
        if special != .NONE, let reading = specialShabbatot[special] {
            return reading
        }
        
        // Yom Tov cases
        if jCal.isRoshHashana() || jCal.isYomKippur() || (jCal.isSuccos() && !jCal.isHoshanaRabba()) ||
            jCal.isShminiAtzeres() || jCal.isPesach() || jCal.isShavuos() {
            
            switch jCal.getYomTovIndex() {
            case JewishCalendar.ROSH_HASHANA: return HaftarahReading(text: "ויהי איש", source: "שמואל א א")
            case JewishCalendar.YOM_KIPPUR: return HaftarahReading(text: "סלו סלו", source: "ישעיה נ\"ז")
            case JewishCalendar.SUCCOS: return HaftarahReading(text: "הנה יום", source: "זכריה י\"ד")
            case JewishCalendar.CHOL_HAMOED_SUCCOS: return HaftarahReading(text: "ויהי ביום", source: "יחזקאל לח")
            case JewishCalendar.SHEMINI_ATZERES, JewishCalendar.SIMCHAS_TORAH:
                if jCal.inIsrael {
                    return HaftarahReading(text: "ויהי אחרי", source: "יהושע א")
                } else {
                    return HaftarahReading(text: "ויהי ככלות", source: "מלכים א ח")
                }
            case JewishCalendar.PESACH:
                switch jCal.getJewishDayOfMonth() {
                case 15: return HaftarahReading(text: "בעת ההיא", source: "יהושע ה")
                case 16: return HaftarahReading(text: "וישלח המלך", source: "מלכים ב כ\"ג")
                case 21: return HaftarahReading(text: "וידבר דוד", source: "שמואל ב כ\"ב")
                case 22: return HaftarahReading(text: "עוד היום", source: "ישעיהו י")
                default: break
                }
            case JewishCalendar.CHOL_HAMOED_PESACH: return HaftarahReading(text: "היתה עלי", source: "יחזקאל ל\"ז")
            case JewishCalendar.SHAVUOS:
                return jCal.getJewishDayOfMonth() == 7
                    ? HaftarahReading(text: "וה' בהיכל", source: "חבקוק ב")
                    : HaftarahReading(text: "ויהי בשלושים", source: "יחזקאל א")
            default: break
            }
        }
        
        // Chanukah
        if jCal.isChanukah() {
            return [7, 8].contains(jCal.getDayOfChanukah())
                ? HaftarahReading(text: "ויעש חירום", source: "מלכים א ז")
                : HaftarahReading(text: "רני ושמחי", source: "זכריה ב")
        }
        
        // Rosh Chodesh / Erev Rosh Chodesh
        if !([JewishCalendar.Parsha.MATOS_MASEI, JewishCalendar.Parsha.REEH].contains(jCal.getParshah())) {
            if jCal.isErevRoshChodesh() {
                return HaftarahReading(text: "מחר חודש", source: "שמואל א כ")
            } else if jCal.isRoshChodesh() {
                return HaftarahReading(text: "כה אמר", source: "ישעיה ס\"ו [הפטרת ר\"ח]")
            }
        }
        
        // Prepare 17 Tammuz date for Pinchas logic
        let tammuz17 = jCal.copy() 
        tammuz17.setJewishDate(year: jCal.getJewishYear(), month: JewishCalendar.TAMMUZ, dayOfMonth: 17)
        
        // Default weekly parasha mapping
        switch jCal.getParshah() {
        case .BERESHIS: return HaftarahReading(text: "כה אמר", source: "ישעיה מ\"ב")
        case .NOACH: return HaftarahReading(text: "רני עקרה", source: "ישעיה נ\"ד")
        case .LECH_LECHA: return HaftarahReading(text: "למה תאמר", source: "ישעיה מ")
        case .VAYERA: return HaftarahReading(text: "ואשה אחת", source: "מלכים ב ד")
        case .CHAYEI_SARA: return HaftarahReading(text: "והמלך דוד", source: "מלכים א א")
        case .TOLDOS: return HaftarahReading(text: "משא דבר", source: "מלאכי א")
        case .VAYETZEI: return HaftarahReading(text: "ועמי תלואים", source: "הושע י\"א")
        case .VAYISHLACH: return HaftarahReading(text: "חזון עובדיה", source: "עובדיה")
        case .VAYESHEV: return HaftarahReading(text: "כה אמר", source: "עמוס ב")
        case .MIKETZ: return HaftarahReading(text: "ויקץ שלמה", source: "מלכים א ג")
        case .VAYIGASH: return HaftarahReading(text: "ויהי דבר", source: "יחזקאל ל\"ז")
        case .VAYECHI: return HaftarahReading(text: "ויקרבו", source: "מלכים א ב")
        case .SHEMOS: return HaftarahReading(text: "דברי ירמיה", source: "ירמיה א")
        case .VAERA: return HaftarahReading(text: "כה אמר", source: "יחזקאל כ\"ח")
        case .BO: return HaftarahReading(text: "הדבר אשר", source: "ירמיה מ\"ו")
        case .BESHALACH: return HaftarahReading(text: "ותשר דבורה", source: "שופטים ד")
        case .YISRO: return HaftarahReading(text: "בשנת מות", source: "ישעיה ו")
        case .MISHPATIM: return HaftarahReading(text: "הדבר אשר", source: "ירמיה ל\"ד")
        case .TERUMAH: return HaftarahReading(text: "ויהוה נתן", source: "מלכים א ה")
        case .TETZAVEH: return HaftarahReading(text: "אתה בן אדם", source: "יחזקאל מ\"ג")
        case .KI_SISA: return HaftarahReading(text: "וישלח אחאב", source: "מלכים א י\"ח")
        case .VAYAKHEL: return HaftarahReading(text: "וישלח המלך", source: "מלכים א ז")
        case .PEKUDEI, .VAYAKHEL_PEKUDEI: return HaftarahReading(text: "ויעש חירום", source: "מלכים א ז")
        case .VAYIKRA: return HaftarahReading(text: "עם זו", source: "ישעיה מ\"ג")
        case .TZAV: return HaftarahReading(text: "כה אמרס", source: "ירמיה ז")
        case .SHMINI: return HaftarahReading(text: "ויסף עוד", source: "שמואל ב ו")
        case .TAZRIA: return HaftarahReading(text: "ואיש בא", source: "מלכים ב ד")
        case .METZORA, .TAZRIA_METZORA: return HaftarahReading(text: "וארבעה אנשים", source: "מלכים ב ז")
        case .ACHREI_MOS: return HaftarahReading(text: "ויהי דבר", source: "יחזקאל כ\"ב")
        case .KEDOSHIM, .ACHREI_MOS_KEDOSHIM: return HaftarahReading(text: "ויהי דבר", source: "יחזקאל כ")
        case .EMOR: return HaftarahReading(text: "והכהנים", source: "יחזקאל מ\"ד")
        case .BEHAR: return HaftarahReading(text: "ויאמר ירמיהו", source: "ירמיה ל\"ב")
        case .BECHUKOSAI, .BEHAR_BECHUKOSAI: return HaftarahReading(text: "ה' עזי", source: "ירמיה ט\"ז")
        case .BAMIDBAR: return HaftarahReading(text: "והיה מספר", source: "הושע ב")
        case .NASSO: return HaftarahReading(text: "ויהי איש", source: "שופטים י\"ג")
        case .BEHAALOSCHA: return HaftarahReading(text: "רני ושמחי", source: "זכריה ב")
        case .SHLACH: return HaftarahReading(text: "וישלח", source: "יהושע ב")
        case .KORACH: return HaftarahReading(text: "ויאמר שמואל", source: "שמואל א י\"א")
        case .CHUKAS: return HaftarahReading(text: "ויפתח", source: "שופטים י\"א")
        case .BALAK, .CHUKAS_BALAK: return HaftarahReading(text: "והיה", source: "מיכה ה")
        case .PINCHAS:
            // Swift Date/Calendar comparison
            return jCal.workingDate < tammuz17.workingDate
                ? HaftarahReading(text: "ויד יהוה", source: "מלכים י\"ח")
                : HaftarahReading(text: "דברי ירמיהו", source: "ירמיהו א")
        case .MATOS: return HaftarahReading(text: "דברי ירמיהו", source: "ירמיהו א")
        case .MASEI, .MATOS_MASEI: return HaftarahReading(text: "שמעו דבר", source: "ירמיהו ב")
        case .DEVARIM: return HaftarahReading(text: "חזון", source: "ישעיה א")
        case .VAESCHANAN: return HaftarahReading(text: "נחמו", source: "ישעיה מ")
        case .EIKEV: return HaftarahReading(text: "ותאמר ציון", source: "ישעיה מ\"ט")
        case .REEH: return HaftarahReading(text: "עניה סערה", source: "ישעיה נ\"ד")
        case .SHOFTIM: return HaftarahReading(text: "אנכי אנכי", source: "ישעיה נ\"א")
        case .KI_SEITZEI: return HaftarahReading(text: "רני עקרה", source: "ישעיה נ\"ד")
        case .KI_SAVO: return HaftarahReading(text: "קומי אורי", source: "ישעיה ס")
        case .NITZAVIM, .NITZAVIM_VAYEILECH: return HaftarahReading(text: "שוש אשיש", source: "ישעיה ס\"א")
        case .VAYEILECH: return HaftarahReading(text: "שובה", source: "הושע י\"ד")
        case .HAAZINU:
            if jCal.getJewishMonth() == JewishCalendar.TISHREI && jCal.getJewishDayOfMonth() > 10 {
                return HaftarahReading(text: "וידבר דוד", source: "שמואל ב כ\"ב")
            } else {
                return HaftarahReading(text: "שובה", source: "הושע י\"ד")
            }
        default: return HaftarahReading(text: "", source: "")
        }
    }
}
