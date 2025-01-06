//
//  Extensions.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 12/26/23.
//

import Foundation
import KosherSwift

public extension JewishCalendar {
    
    func getSpecialDay(addOmer: Bool) -> String {
        var result = Array<String>()
                
        let yomTovOfToday = yomTovAsString()
        forward()
        let yomTovOfNextDay = yomTovAsString()
        back()
        
        if yomTovOfToday.isEmpty && yomTovOfNextDay.isEmpty {
            //Do nothing
        } else if yomTovOfToday.isEmpty && !yomTovOfNextDay.hasPrefix("Erev") {
            if Locale.isHebrewLocale() {
                if !yomTovOfNextDay.hasPrefix("ערב") {
                    result.append("ערב ".appending(yomTovOfNextDay))
                }
            } else {
                result.append("Erev " + yomTovOfNextDay)
            }
        } else if !(yomTovOfNextDay.isEmpty) && !yomTovOfNextDay.hasPrefix("Erev") && !yomTovOfToday.hasSuffix(yomTovOfNextDay) {
            if Locale.isHebrewLocale() {
                if !yomTovOfNextDay.hasPrefix("ערב") {
                    result.append(yomTovOfToday.appending(" / ערב ").appending(yomTovOfNextDay))
                } else {
                    result.append(yomTovOfToday)
                }
            } else {
                result.append(yomTovOfToday + " / Erev " + yomTovOfNextDay)
            }
        } else {
            if !yomTovOfToday.isEmpty {
                result.append(yomTovOfToday)
            }
        }
        
        result = addTaanitBechorot(result: result)
        result = addRoshChodesh(result: result)

        if addOmer {
            result = addDayOfOmer(result: result)
        }

        result = replaceChanukahWithDayOfChanukah(result: result)

        return result.joined(separator: " / ")
    }
    
    func addTaanitBechorot(result:Array<String>) -> Array<String> {
        var arr = result
        if tomorrowIsTaanitBechorot() {
            arr.append("Erev Taanit Bechorot".localized())
        }
        if isTaanisBechoros() {
            arr.append("Taanit Bechorot".localized())
        }
        return arr
    }
    
    func tomorrowIsTaanitBechorot() -> Bool {
        forward()
        let result = isTaanisBechoros()
        back()
        return result
    }
    
    func addRoshChodesh(result:Array<String>) -> Array<String> {
        var arr = result
        let roshChodeshOrErevRoshChodesh = getRoshChodeshOrErevRoshChodesh()
        if !roshChodeshOrErevRoshChodesh.isEmpty {
            arr.append(roshChodeshOrErevRoshChodesh)
        }
        return arr
    }
    
    func getRoshChodeshOrErevRoshChodesh() -> String {
        var result = ""
        let hebrewDateFormatter = DateFormatter()
        hebrewDateFormatter.calendar = Calendar(identifier: .hebrew)
        hebrewDateFormatter.dateFormat = "MMMM"

        let nextHebrewMonth = hebrewDateFormatter.string(from: workingDate.advanced(by: 86400 * 3))
            .replacingOccurrences(of: "Heshvan", with: "Cheshvan")
            .replacingOccurrences(of: "Tamuz", with: "Tammuz")// advance 3 days into the future, because Rosh Chodesh can be 2 days and we need to know what the next month is at most 3 days before
        
        if isRoshChodesh() {
            result = "Rosh Chodesh ".localized() + nextHebrewMonth
        } else if isErevRoshChodesh() {
            result = "Erev Rosh Chodesh ".localized() + nextHebrewMonth
        }
        
        return result
    }
    
    func replaceChanukahWithDayOfChanukah(result:Array<String>) -> Array<String> {
        var arr = result
        let dayOfChanukah = getDayOfChanukah()
        if dayOfChanukah != -1 {
            if let index = arr.firstIndex(of: "Chanukah") {
                arr.remove(at: index)
            }
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            if !Locale.isHebrewLocale() {
                arr.append(formatter.string(from: dayOfChanukah as NSNumber)! + " day of Chanukah")
            }
        }
        return arr
    }
    
    func addDayOfOmer(result:Array<String>) -> Array<String> {
        var arr = result
        let dayOfOmer = getDayOfOmer()
        if dayOfOmer != -1 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            if Locale.isHebrewLocale() {
                let hebrewDateFormatter = HebrewDateFormatter()
                hebrewDateFormatter.hebrewFormat = true
                arr.append(hebrewDateFormatter.formatHebrewNumber(number: dayOfOmer).appending(" ימים לעומר (לפני השקיעה)"))
            } else {
                arr.append(formatter.string(from: dayOfOmer as NSNumber)! + " day of Omer (before sunset)")
            }
        }
        return arr
    }
    
    func yomTovAsString() -> String {
        if Locale.isHebrewLocale() {
            let hebrewDateFormatter = HebrewDateFormatter()
            hebrewDateFormatter.hebrewFormat = true
            return hebrewDateFormatter.formatYomTov(jewishCalendar: self)
        }
        let hebrewDateFormatter = HebrewDateFormatter()
        let yomtov = hebrewDateFormatter.formatYomTov(jewishCalendar: self)
        if yomtov.contains("Shemini Atzeres") {
            if inIsrael {
                return "Shemini Atzeret & Simchat Torah"
            }
        }
        if yomtov.contains("Simchas Torah") {
            if !inIsrael {
                return "Shemini Atzeret & Simchat Torah"
            }
        }
        if yomtov.contains("Chanukah") {
            return "Chanukah" // to remove the numbers
        }
        return yomtov.replacingOccurrences(of: "Teves", with: "Tevet")
            .replacingOccurrences(of: "Shavuos", with: "Shavuot")
            .replacingOccurrences(of: "Succos", with: "Succot")
            .replacingOccurrences(of: "Atzeres", with: "Atzeret")
            .replacingOccurrences(of: "Simchas", with: "Simchat")
    }
    
    func getTachanun() -> String {
        let yomTovIndex = getYomTovIndex();
        if (isRoshChodesh()
            || yomTovIndex == JewishCalendar.PESACH_SHENI
            || yomTovIndex == JewishCalendar.LAG_BAOMER
            || yomTovIndex == JewishCalendar.TISHA_BEAV
            || yomTovIndex == JewishCalendar.TU_BEAV
            || yomTovIndex == JewishCalendar.EREV_ROSH_HASHANA
            || yomTovIndex == JewishCalendar.ROSH_HASHANA
            || yomTovIndex == JewishCalendar.EREV_YOM_KIPPUR
            || yomTovIndex == JewishCalendar.YOM_KIPPUR
            || yomTovIndex == JewishCalendar.TU_BESHVAT
            || yomTovIndex == JewishCalendar.PURIM_KATAN
            || yomTovIndex == JewishCalendar.SHUSHAN_PURIM_KATAN
            || yomTovIndex == JewishCalendar.PURIM
            || yomTovIndex == JewishCalendar.SHUSHAN_PURIM
            || yomTovIndex == JewishCalendar.YOM_YERUSHALAYIM //tachanun erev before, however, Rav ovadia would not say on the day itself
            || isChanukah()
            || getJewishMonth() == JewishCalendar.NISSAN
            || (getJewishMonth() == JewishCalendar.SIVAN && getJewishDayOfMonth() <= 12)
            || (getJewishMonth() == JewishCalendar.TISHREI && getJewishDayOfMonth() >= 11)) {
            if (yomTovIndex == JewishCalendar.ROSH_HASHANA && getDayOfWeek() == 7) {//Edge case for rosh hashana that falls on shabbat (Shulchan Aruch, Chapter 598 and Chazon Ovadia page 185)
                return "צדקתך";
            }//TODO check source on this
            if Locale.isHebrewLocale() {
                return "לא אומרים תחנון"
            } else {
                return "No Tachanun today";
            }
        }
        let yomTovIndexForNextDay = getYomTovIndexForNextDay();
        if (getDayOfWeek() == 6
            || yomTovIndexForNextDay == JewishCalendar.PURIM
            || yomTovIndexForNextDay == JewishCalendar.TISHA_BEAV
            || yomTovIndexForNextDay == JewishCalendar.CHANUKAH
            || yomTovIndexForNextDay == JewishCalendar.TU_BEAV
            || yomTovIndexForNextDay == JewishCalendar.TU_BESHVAT
            || yomTovIndexForNextDay == JewishCalendar.LAG_BAOMER
            || yomTovIndexForNextDay == JewishCalendar.PESACH_SHENI
            || yomTovIndexForNextDay == JewishCalendar.PURIM_KATAN
            || isErevRoshChodesh()) {
            if (getDayOfWeek() == 7) {
                if Locale.isHebrewLocale() {
                    return "לא אומרים תחנון"
                } else {
                    return "No Tachanun today";
                }
            }
            if Locale.isHebrewLocale() {
                return "אומרים תחנון רק בבוקר";
            }
            return "Tachanun only in the morning";
        }
        // According to Rabbi Meir Gavriel Elbaz, Rabbi Ovadiah would only skip tachanun on the day of Yom Yerushalayim itself as is the custom of the Yeshiva of Yechaveh Daat.
         // He WOULD say tachanun on Erev Yom Yerushalayim and on Yom Ha'atmaut. However, since there are disagreements, it was recommended for the app to just say that "Some say tachanun" on both days.
         if (yomTovIndex == JewishCalendar.YOM_YERUSHALAYIM || yomTovIndex == JewishCalendar.YOM_HAATZMAUT) {
             if Locale.isHebrewLocale() {
                 return "יש אומרים תחנון";
             }
             return "Some say Tachanun today";
         }
         if (yomTovIndexForNextDay == JewishCalendar.YOM_YERUSHALAYIM || yomTovIndexForNextDay == JewishCalendar.YOM_HAATZMAUT) {
             if Locale.isHebrewLocale() {
                 return "יש מדלגים תחנון במנחה";
             }
             return "Some skip Tachanun by mincha";
         }
        if (getDayOfWeek() == 7) {
            return "צדקתך";
        }
        if Locale.isHebrewLocale() {
            return "אומרים תחנון";
        }
        return "There is Tachanun today";
    }
    
    func getYomTovIndexForNextDay() -> Int {
        //set workingDate to next day
        let temp = workingDate
        forward()
        let yomTovIndexForTomorrow = getYomTovIndex()
        workingDate = temp //reset
        return yomTovIndexForTomorrow
    }
    
    func getHallelOrChatziHallel() -> String {
        let yomTovIndex = getYomTovIndex()
        let jewishMonth = getJewishMonth()
        let jewishDay = getJewishDayOfMonth()
        if (jewishMonth == JewishCalendar.NISSAN && jewishDay == 15) || (!inIsrael && jewishMonth == JewishCalendar.NISSAN && jewishDay == 16) || yomTovIndex == JewishCalendar.SHAVUOS || yomTovIndex == JewishCalendar.SUCCOS || yomTovIndex == JewishCalendar.SHEMINI_ATZERES || isSimchasTorah() || isCholHamoedSuccos() || isChanukah() {
            return "הלל שלם";
        } else if isRoshChodesh() || isCholHamoedPesach() || (jewishMonth == JewishCalendar.NISSAN && jewishDay == 21) || (!inIsrael && jewishMonth == JewishCalendar.NISSAN && jewishDay == 22) {
            return "חצי הלל";
        } else {
            return ""
        }
    }
    
    func getIsUlChaparatPeshaSaid() -> String {
        if isRoshChodesh() {
            if isJewishLeapYear(year: getJewishYear()) {
                let month = getJewishMonth()
                if month == JewishCalendar.TISHREI || month == JewishCalendar.CHESHVAN || month == JewishCalendar.KISLEV || month == JewishCalendar.TEVES || month == JewishCalendar.SHEVAT || month == JewishCalendar.ADAR || month == JewishCalendar.ADAR_II {
                    if Locale.isHebrewLocale() {
                        return "אומרים וּלְכַפָּרַת פֶּשַׁע";
                    }
                    return "Say וּלְכַפָּרַת פֶּשַׁע";
                } else {
                    if Locale.isHebrewLocale() {
                        return "לא אומרים וּלְכַפָּרַת פֶּשַׁע";
                    }
                    return "Do not say וּלְכַפָּרַת פֶּשַׁע";
                }
            } else {
                if Locale.isHebrewLocale() {
                    return "לא אומרים וּלְכַפָּרַת פֶּשַׁע";
                }
                return "Do not say וּלְכַפָּרַת פֶּשַׁע";
            }
        }
        return ""
    }
    
    func isOKToListenToMusic() -> String {
        if getDayOfOmer() >= 8 && getDayOfOmer() <= 32 {
            return "No Music".localized()
        } else if getJewishMonth() == JewishCalendar.TAMMUZ {
            if getJewishDayOfMonth() >= 17 {
                return "No Music".localized()
            }
        } else if getJewishMonth() == JewishCalendar.AV {
            if getJewishDayOfMonth() <= 9 {
                return "No Music".localized()
            }
        }
        return "";
    }
    
    func isSelichotSaid() -> Bool {
        if getJewishMonth() == JewishCalendar.ELUL {
            if !isRoshChodesh() {
                return true;
            }
        }
        return isAseresYemeiTeshuva();
    }
    
    func is3Weeks() -> Bool {
        if getJewishMonth() == JewishCalendar.TAMMUZ {
            return getJewishDayOfMonth() >= 17
        } else if getJewishMonth() == JewishCalendar.AV {
            return getJewishDayOfMonth() < 9
        }
        return false
    }
    
    func is9Days() -> Bool {
        if getJewishMonth() == JewishCalendar.AV {
            return getJewishDayOfMonth() < 9
        }
        return false
    }
    
    func isShevuahShechalBo() -> Bool {
        if getJewishMonth() != JewishCalendar.AV {
            return false
        }
        
        let backup = workingDate
        
        workingDate = Calendar(identifier: .hebrew).date(bySetting: .day, value: 9, of: workingDate)!
        
        if getDayOfWeek() == 1 || getDayOfWeek() == 7 {
            return false
        }
        workingDate = backup// reset
        
        let tishaBeav = Calendar(identifier: .hebrew).date(bySetting: .day, value: 8, of: workingDate)!
        let jewishCal = JewishCalendar()
        jewishCal.workingDate = tishaBeav
        
        var daysOfShevuahShechalBo = Array<Int>()
        
        while jewishCal.getDayOfWeek() != 7 {
            daysOfShevuahShechalBo.append(jewishCal.getJewishDayOfMonth())
            jewishCal.forward()
        }
        return daysOfShevuahShechalBo.contains(getJewishDayOfMonth())
    }
    
    func getBirchatLevanaStatus() -> String {
        let molad = getMoladAsDate()
        
        let calendar = Calendar(identifier: .gregorian)
        
        let sevenDays = calendar.date(byAdding: .day, value: 7, to: molad)!
        
        if getJewishMonth() != JewishCalendar.AV {
            if Calendar.current.isDate(workingDate, inSameDayAs: sevenDays) {
                return "Birchat HaLevana starts tonight".localized();
            }
        } else {
            if getJewishDayOfMonth() < 9 {
                return ""
            }
            if getYomTovIndex() == JewishCalendar.TISHA_BEAV {
                return "Birchat HaLevana starts tonight".localized();
            }
        }
        
        if getJewishDayOfMonth() == 14 {
            return "Last night for Birchat HaLevana".localized();
        }
        
        let latest = Calendar(identifier: .hebrew).date(bySetting: .day, value: 14, of: sevenDays)!
        
        if workingDate.timeIntervalSince1970 > sevenDays.timeIntervalSince1970 && workingDate.timeIntervalSince1970 < latest.timeIntervalSince1970 {
            let format = DateFormatter()
            format.dateFormat = "MMM d"
            if Locale.isHebrewLocale() {
                return "ברכת הלבנה עד ליל טו'"
            }
            return "Birchat HaLevana until " + format.string(from: latest)
        }
        return ""
    }

    func getIsMashivHaruchOrMoridHatalSaid() -> String {
        if TefilaRules().isMashivHaruachRecited(jewishCalendar: self) {
            return "משיב הרוח"
        }
        if TefilaRules().isMoridHatalRecited(jewishCalendar: self) {
            return "מוריד הטל"
        }
        return ""
    }
    
    func getIsBarcheinuOrBarechAleinuSaid() -> String {
        if TefilaRules().isVeseinBerachaRecited(jewishCalendar: self) {
            return "ברכנו";
        } else {
            return "ברך עלינו";
        }
    }
    
    func isNightTikkunChatzotSaid() -> Bool {
        // These are all days that Tikkun Chatzot is not said at all, so we NOT it to know if Tikkun Chatzot IS said
        return !(getDayOfWeek() == 7 ||
                 isRoshHashana() ||
                 isYomKippur() ||
                 getYomTovIndex() == JewishCalendar.SUCCOS ||
                 isShminiAtzeres() ||
                 isSimchasTorah() ||
                 isPesach() || isShavuos());
    }
    
    func isDayTikkunChatzotSaid() -> Bool {
        // Tikkun Rachel is said during the daytime for the three weeks, but not in these cases. Tikkun Rachel IS said on Erev Tisha Beav
        return !((isErevRoshChodesh() && getJewishMonth() == JewishCalendar.TAMMUZ) ||// Use tammuz to check for erev rosh chodesh Av
                isRoshChodesh() ||
                getDayOfWeek() == 6 ||
                getDayOfWeek() == 7 ||
                getTachanun() == "No Tachanun today" || getTachanun() == "לא אומרים תחנון");
    }
    
    func isOnlyTikkunLeiaSaid(forNightTikkun: Bool, isTikkunChatzotSaid: Bool) -> Bool {
        if (forNightTikkun) {
            if (isTikkunChatzotSaid) {
                // These are days where we ONLY say Tikkun Leia
                let currentDate = workingDate
                let currentHebrewMonth = getJewishMonth();
                while (currentHebrewMonth == getJewishMonth()) {
                    forward() // go forward until the next month
                }
                let molad = getMoladAsDate(); // now we can get the molad for the next month
                let roshChodesh = workingDate
                workingDate = currentDate // reset
                let afterMoladBeforeRoshChodesh = molad.timeIntervalSince1970 < Date().timeIntervalSince1970 && roshChodesh.timeIntervalSince1970 > Date().timeIntervalSince1970 && !isRoshChodesh(); // Tikkun Leia (only) is said if it is after the molad but before Rosh Chodesh, this condition is time based even though all the other methods are date based
                return (isAseresYemeiTeshuva() ||
                        isCholHamoedSuccos() ||
                        getDayOfOmer() != -1 ||
                        (getInIsrael() && isShmitaYear()) ||
                        getTachanun() == "No Tachanun today" || getTachanun() == "לא אומרים תחנון" ||
                        afterMoladBeforeRoshChodesh);
                // Tikkun Rachel is also skipped in the house of a Mourner, Chatan, or Brit Milah (Specifically the father of the boy)
            }
        } else { // for day tikkun, we do not say Tikkun Rachel if there is no tachanun
            return getTachanun() == "No Tachanun today" || getTachanun() == "לא אומרים תחנון";
        }
        return false;
    }
    
    /**
     * This method returns which year of the shmita cycle is the current hebrew year in.
     * 0 = Shmita, 1 = First Year, 2 = Second Year, 3 = Third Year, 4 = Fourth Year, 5 = Fifth Year, 6 = Sixth Year.
     *
     * @return an int indicating what year of the shmita cycle the current hebrew year is in.
     * NOTE: Some Rishonim hold that the year of shmita is a year off.
     */
    func getYearOfShmitaCycle() -> Int {
        return getJewishYear() % 7
    }
}

public extension AstronomicalCalendar {
    
    func getSolarMidnightIfSunTransitNil() -> Date? {
        let sunTransit = getSunTransit(startOfDay: getSunrise(), endOfDay: getSunset())
        workingDate = workingDate.addingTimeInterval(86400)
        let sunTransitTomorrow = getSunTransit(startOfDay: getSunrise(), endOfDay: getSunset())
        workingDate = workingDate.addingTimeInterval(-86400)
        
        if sunTransit == nil || sunTransitTomorrow == nil {
            return getSolarMidnight()
        }
        
        let offset = ((sunTransitTomorrow!.timeIntervalSince1970 - sunTransit!.timeIntervalSince1970) / 2) * 1000
        
        return AstronomicalCalendar.getTimeOffset(
            time: sunTransit,
            offset: offset)
    }
}

public extension ZmanimCalendar {
    func getCandleLighting() -> Date? {
        return ZmanimCalendar.getTimeOffset(time: getElevationAdjustedSunset(), offset: -Double(getCandleLightingOffset()) * ZmanimCalendar.MINUTE_MILLIS);
    }
}

public extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: self)
    }
}

public extension Locale {
    static func isHebrewLocale() -> Bool {
        return Locale.current.localizedString(forIdentifier: "he") == "עברית"
    }
}

public extension TimeZone {
    func corrected() -> TimeZone {
        var id = identifier
        if identifier == "Asia/Gaza" || identifier == "Asia/Hebron" {
            id = "Asia/Jerusalem"
        }
        return TimeZone(identifier: id) ?? TimeZone.current
    }
}
