//
//  Extentions.swift
//  Rabbi Ovadiah Yosef Calendar WidgetExtension
//
//  Created by Macbook Pro on 8/28/23.
//

import Foundation
import KosherCocoa

struct GlobalStruct {
    static var useElevation = false
}

public extension ComplexZmanimCalendar {
    
    func tzait72Zmanit() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        return sunset()?.addingTimeInterval(shaahZmanit*1.2);
    }
    
    func tzeitTaanitLChumra() -> Date? {
        return sunset()?.addingTimeInterval(30 * 60);
    }
    
    func tzeitTaanit() -> Date? {
        return sunset()?.addingTimeInterval(20 * 60);
    }
    
    func tzeit() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        
        return sunset()?.addingTimeInterval(13 * dakahZmanit + (dakahZmanit / 2));
    }
    
    override func sunset() -> Date? {
        if GlobalStruct.useElevation {
            return super.sunset()
        }
        return super.seaLevelSunset()
    }
    
    override func sunrise() -> Date? {
        if GlobalStruct.useElevation {
            return super.sunrise()
        }
        return super.seaLevelSunrise()
    }
    
    func seaLevelSunriseOnly() -> Date? {
        return super.seaLevelSunrise()
    }
    
    override func plagHamincha() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        
        return tzeit()?.addingTimeInterval(-(shaahZmanit + (15 * dakahZmanit)));
    }
    
    func sofZmanBiurChametzMGA() -> Date? {
        let shaahZmanit = shaahZmanitMga()
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        return alos72Zmanis()?.addingTimeInterval(5 * shaahZmanit)
    }
    
    func talitTefilin() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        
        return alos72Zmanis()?.addingTimeInterval(6 * dakahZmanit);
    }
    
    override func shaahZmanisGra() -> Double {
        var sunrise = seaLevelSunrise()
        var sunset = seaLevelSunset()
        if GlobalStruct.useElevation {
            sunrise = self.sunrise()
            sunset = self.sunset()
        }
        if sunrise == nil || sunset == nil {
            return .leastNormalMagnitude
        }
        return temporalHour(fromSunrise: sunrise!, toSunset: sunset!)
    }
    
    func shaahZmanitMga() -> Double {
        let alot = alos72Zmanis()
        let tzait = tzait72Zmanit()
        if alot == nil || tzait == nil {
            return .leastNormalMagnitude
        }
        return temporalHour(fromSunrise: alos72Zmanis()!, toSunset: tzait72Zmanit()!)
    }
    
    //Amudei Horaah zmanim start here
    
    func plagHaminchaYalkutYosefAmudeiHoraah() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        
        return tzaitAmudeiHoraah()?.addingTimeInterval(-(shaahZmanit + (15 * dakahZmanit)));
    }
    
    func plagHaminchaHalachaBerurah() -> Date? {
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        
        return sunset()?.addingTimeInterval(-(shaahZmanit + (15 * dakahZmanit)));
    }
    
    func alotAmudeiHoraah() -> Date? {
        let calendar = Calendar.current
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!
        let alotBy16Degrees = sunriseOffset(byDegrees:90 + 16.04)
        let numberOfSeconds = ((seaLevelSunrise()!.timeIntervalSince1970 - alotBy16Degrees!.timeIntervalSince1970))
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunrise()?.addingTimeInterval(-(numberOfSeconds * secondsZmanit));
    }
    
    func talitTefilinAmudeiHoraah() -> Date? {
        let calendar = Calendar.current
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!
        let alotBy16Degrees = sunriseOffset(byDegrees:90 + 16.04)
        let numberOfSeconds = ((seaLevelSunrise()!.timeIntervalSince1970 - alotBy16Degrees!.timeIntervalSince1970))
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunrise()?.addingTimeInterval(-(numberOfSeconds * secondsZmanit * 5 / 6));
    }
    
    func shmaMGAAmudeiHoraah() -> Date? {
        let shaahZmanit = temporalHour(fromSunrise: alotAmudeiHoraah()!, toSunset: tzait72ZmanitAmudeiHoraah()!)
        return alotAmudeiHoraah()?.addingTimeInterval(3 * shaahZmanit)
    }
    
    func achilatChametzAmudeiHoraah() -> Date? {
        let shaahZmanit = temporalHour(fromSunrise: alotAmudeiHoraah()!, toSunset: tzait72ZmanitAmudeiHoraah()!)
        return alotAmudeiHoraah()?.addingTimeInterval(4 * shaahZmanit)
    }
    
    func biurChametzAmudeiHoraah() -> Date? {
        let shaahZmanit = temporalHour(fromSunrise: alotAmudeiHoraah()!, toSunset: tzait72ZmanitAmudeiHoraah()!)
        return alotAmudeiHoraah()?.addingTimeInterval(5 * shaahZmanit)
    }
    
    func tzaitAmudeiHoraah() -> Date? {
        let calendar = Calendar.current
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!
        let tzaitGeonimInDegrees = sunsetOffset(byDegrees:90 + 3.77)
        let numberOfSeconds = (tzaitGeonimInDegrees!.timeIntervalSince1970 - seaLevelSunset()!.timeIntervalSince1970)
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunset()?.addingTimeInterval(numberOfSeconds * secondsZmanit);
    }
    
    func tzaitAmudeiHoraahLChumra() -> Date? {
        let calendar = Calendar.current
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!
        let tzaitGeonimInDegrees = sunsetOffset(byDegrees:90 + 5.135)
        let numberOfSeconds = (tzaitGeonimInDegrees!.timeIntervalSince1970 - seaLevelSunset()!.timeIntervalSince1970)
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunset()?.addingTimeInterval(numberOfSeconds * secondsZmanit);
    }
    
    func tzait72ZmanitAmudeiHoraah() -> Date? {
        let calendar = Calendar.current
        let temp = workingDate
        workingDate = calendar.date(from: DateComponents(year: calendar.component(.year, from: workingDate), month: 3, day: 17))!
        let tzaitRTInDegrees = sunsetOffset(byDegrees:90 + 16.01)
        let numberOfSeconds = (tzaitRTInDegrees!.timeIntervalSince1970 - seaLevelSunset()!.timeIntervalSince1970)
        workingDate = temp//reset
        
        let shaahZmanit = shaahZmanisGra()
        
        if (shaahZmanit == .leastNormalMagnitude) {
            return nil;
        }
        
        let dakahZmanit = shaahZmanit / 60
        let secondsZmanit = dakahZmanit / 60
        
        return seaLevelSunset()?.addingTimeInterval(numberOfSeconds * secondsZmanit);
    }
    
    func tzaitShabbatAmudeiHoraah() -> Date? {
        return sunsetOffset(byDegrees: 90 + 7.14)
    }
    
    func tzaitShabbatAmudeiHoraahLesserThan40() -> Date? {
        if tzaitShabbatAmudeiHoraah()?.compare(tzaisAteretTorah()!) == .orderedDescending {
            return tzaisAteretTorah()
        } else {
            return tzaitShabbatAmudeiHoraah()
        }
    }
    
    func tzait72ZmanitAmudeiHoraahLkulah() -> Date? {
        if tzais72()?.compare(tzait72ZmanitAmudeiHoraah()!) == .orderedDescending {
            return tzait72ZmanitAmudeiHoraah()
        } else {
            return tzais72()
        }
    }
    
}

public extension JewishCalendar {
    
    func getSpecialDay(addOmer: Bool) -> String {
        var result = Array<String>()
        
        let index = yomTovIndex()
        let indexNextDay = getYomTovIndexForNextDay()
        
        let yomTovOfToday = yomTovAsString(index:index)
        let yomTovOfNextDay = yomTovAsString(index:indexNextDay)
        
        if yomTovOfToday.isEmpty && yomTovOfNextDay.isEmpty {
            //Do nothing
        } else if yomTovOfToday.isEmpty && !yomTovOfNextDay.hasPrefix("Erev") {
            result.append("Erev " + yomTovOfNextDay)
        } else if !(yomTovOfNextDay.isEmpty) && !yomTovOfNextDay.hasPrefix("Erev") && !yomTovOfToday.hasSuffix(yomTovOfNextDay) {
            result.append(yomTovOfToday + " / Erev " + yomTovOfNextDay)
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
            arr.append("Erev Taanit Bechorot")
        }
        if isTaanisBechoros() {
            arr.append("Taanit Bechorot")
        }
        return arr
    }
    
    func tomorrowIsTaanitBechorot() -> Bool {
        let backup = workingDate
        workingDate = workingDate.advanced(by: 86400)
        let result = isTaanisBechoros()
        workingDate = backup
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

        let nextHebrewMonth = hebrewDateFormatter.string(from: workingDate.advanced(by: 86400 * 3))// advance 3 days into the future, because Rosh Chodesh can be 2 days and we need to know what the next month is at most 3 days before
        
        if isRoshChodesh() {
            result = "Rosh Chodesh " + nextHebrewMonth
        } else if isErevRoshChodesh() {
            result = "Erev Rosh Chodesh " + nextHebrewMonth
        }
        
        return result
    }
    
    func replaceChanukahWithDayOfChanukah(result:Array<String>) -> Array<String> {
        var arr = result
        let dayOfChanukah = dayOfChanukah()
        if dayOfChanukah != -1 {
            if let index = arr.firstIndex(of: "Chanukah") {
                arr.remove(at: index)
            }
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            arr.append(formatter.string(from: dayOfChanukah as NSNumber)! + " day of Chanukah")
        }
        return arr
    }
    
    func dayOfChanukah() -> Int {
        let day = currentHebrewDayOfMonth()
        if isChanukah() {
            if currentHebrewMonth() == HebrewMonth.kislev.rawValue {
                return day - 24
            } else {
                return isKislevShort() ? day + 5 : day + 6
            }
        } else {
            return -1
        }
    }
    
    func addDayOfOmer(result:Array<String>) -> Array<String> {
        var arr = result
        let dayOfOmer = getDayOfOmer()
        if dayOfOmer != -1 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            arr.append(formatter.string(from: dayOfOmer as NSNumber)! + " day of Omer")
        }
        return arr
    }
    
    func getDayOfOmer() -> Int {
        var omer = -1
        let month = currentHebrewMonth()
        let day = currentHebrewDayOfMonth()
        
        if month == HebrewMonth.nissan.rawValue && day >= 16 {
            omer = day - 15
        } else if month == HebrewMonth.iyar.rawValue {
            omer = day + 15
        } else if month == HebrewMonth.sivan.rawValue && day < 6 {
            omer = day + 44
        }
        return omer
    }
    
    func yomTovAsString(index:Int) -> String {
        if index == 33 {
            return "Lag Ba'Omer"
        } else if index == 34 {
            return "Shushan Purim Katan"
        } else if index != -1 {
            let yomtov = JewishHoliday(index: index).nameTransliterated()
            if yomtov.contains("Shemini Atzeret") {
                if inIsrael {
                    return "Shemini Atzeret & Simchat Torah"
                }
            }
            if yomtov.contains("Simchat Torah") {
                if !inIsrael {
                    return "Shemini Atzeret & Simchat Torah"
                }
            }
            return yomtov
        }
        return ""
    }

    func getSpecialParasha() -> String {
        if currentDayOfTheWeek() == 7 {
            if (currentHebrewMonth() == kHebrewMonth.shevat.rawValue && !isCurrentlyHebrewLeapYear()) || (currentHebrewMonth() == kHebrewMonth.adar.rawValue && isCurrentlyHebrewLeapYear()) {
                if [25, 27, 29].contains(currentHebrewDayOfMonth()) {
        return "שקלים"
        }
        }
            if (currentHebrewMonth() == kHebrewMonth.adar.rawValue && !isCurrentlyHebrewLeapYear()) || currentHebrewMonth() == kHebrewMonth.adar_II.rawValue {
        if currentHebrewDayOfMonth() == 1 {
        return "שקלים"
        }
        if [8, 9, 11, 13].contains(currentHebrewDayOfMonth()) {
        return "זכור"
        }
        if [18, 20, 22, 23].contains(currentHebrewDayOfMonth()) {
        return "פרה"
        }
        if [25, 27, 29].contains(currentHebrewDayOfMonth()) {
        return "החדש"
        }
        }
        if currentHebrewMonth() == kHebrewMonth.nissan.rawValue && currentHebrewDayOfMonth() == 1 {
        return "החדש"
        }
        }
        return ""
    }
                
    func isTaanisBechoros() -> Bool {
        let day = currentHebrewDayOfMonth()
        let dayOfWeek = currentDayOfTheWeek()
        //the fast is on the 14th of Nisan unless that is a Shabbos where the fast is moved to Thursday
        return currentHebrewMonth() == HebrewMonth.nissan.rawValue && ((day == 14 && dayOfWeek != 7) || (day == 12 && dayOfWeek == 5))
    }
    
    func getTachanun() -> String {
        let yomTovIndex = yomTovIndex()
        if isRoshChodesh()
            || yomTovIndex == kPesachSheni.rawValue
            || (currentHebrewMonth() == HebrewMonth.iyar.rawValue && currentHebrewDayOfMonth() == 18)//lag baomer
            || yomTovIndex == kTishaBeav.rawValue
            || yomTovIndex == kTuBeav.rawValue
            || yomTovIndex == kErevRoshHashana.rawValue
            || yomTovIndex == kRoshHashana.rawValue
            || yomTovIndex == kErevYomKippur.rawValue
            || yomTovIndex == kYomKippur.rawValue
            || yomTovIndex == kTuBeshvat.rawValue
            || yomTovIndex == kPurimKatan.rawValue
            || (isHebrewLeapYear(currentHebrewYear()) && currentHebrewMonth() == HebrewMonth.adar.rawValue && currentHebrewDayOfMonth() == 15)//shushan purim katan
            || yomTovIndex == kShushanPurim.rawValue
            || yomTovIndex == kPurim.rawValue
            || yomTovIndex == kYomYerushalayim.rawValue
            || isChanukah()
            || currentHebrewMonth() == HebrewMonth.nissan.rawValue
            || (currentHebrewMonth() == HebrewMonth.sivan.rawValue && currentHebrewDayOfMonth() <= 12)
            || (currentHebrewMonth() == HebrewMonth.tishrei.rawValue && currentHebrewDayOfMonth() >= 11) {
            return "There is no Tachanun today"
        }
        let yomTovIndexForNextDay = getYomTovIndexForNextDay()
        if currentDayOfTheWeek() == 6 //Friday
            || yomTovIndex == kFastOfEsther.rawValue
            || yomTovIndexForNextDay == kTishaBeav.rawValue
            || yomTovIndexForNextDay == kTuBeav.rawValue
            || yomTovIndexForNextDay == kTuBeshvat.rawValue
            || (currentHebrewMonth() == HebrewMonth.iyar.rawValue && currentHebrewDayOfMonth() == 17)// day before lag baomer
            || yomTovIndexForNextDay == kPesachSheni.rawValue
            || yomTovIndexForNextDay == kPurimKatan.rawValue
            || isErevRoshChodesh() {
            if currentDayOfTheWeek() == 7 {
                return "There is no Tachanun today"
            }
            return "There is only Tachanun in the morning"
        }
        if currentDayOfTheWeek() == 7 {
            return "צדקתך"
        }
        return "There is Tachanun today"
    }
    
    func getYomTovIndexForNextDay() -> Int {
        //set workingDate to next day
        let temp = workingDate
        workingDate.addTimeInterval(60*60*24)
        let yomTovIndexForTomorrow = yomTovIndex()
        workingDate = temp //reset
        return yomTovIndexForTomorrow
    }
    
    func hasCandleLighting() -> Bool {
        return currentDayOfTheWeek() == 6 || isErevYomTov() || isErevYomTovSheni()
    }
    
    func isErevYomTovSheni() -> Bool {
        return (currentHebrewMonth() == HebrewMonth.tishrei.rawValue && (currentHebrewDayOfMonth() == 1)) || (!inIsrael && ((currentHebrewMonth() == HebrewMonth.nissan.rawValue && (currentHebrewDayOfMonth() == 15 || currentHebrewDayOfMonth() == 21)) || (currentHebrewMonth() == HebrewMonth.tishrei.rawValue && (currentHebrewDayOfMonth() == 15 || currentHebrewDayOfMonth() == 22)) || (currentHebrewMonth() == HebrewMonth.sivan.rawValue && currentHebrewDayOfMonth() == 6 )))
    }
    
    func isAssurBemelacha() -> Bool {
        let holidayIndex = yomTovIndex()
        return currentDayOfTheWeek() == 7 || holidayIndex == kPesach.rawValue || holidayIndex == kShavuos.rawValue || holidayIndex == kSuccos.rawValue || holidayIndex == kSheminiAtzeres.rawValue || holidayIndex == kSimchasTorah.rawValue || holidayIndex == kRoshHashana.rawValue || holidayIndex == kYomKippur.rawValue
    }
    
    func isYomTovAssurBemelacha() -> Bool {
        let holidayIndex = yomTovIndex()
        return holidayIndex == kPesach.rawValue || holidayIndex == kShavuos.rawValue || holidayIndex == kSuccos.rawValue || holidayIndex == kSheminiAtzeres.rawValue || holidayIndex == kSimchasTorah.rawValue || holidayIndex == kRoshHashana.rawValue || holidayIndex == kYomKippur.rawValue
    }
    
    func getHallelOrChatziHallel() -> String {
        let yomTovIndex = yomTovIndex()
        let jewishMonth = currentHebrewMonth()
        let jewishDay = currentHebrewDayOfMonth()
        if (jewishMonth == HebrewMonth.nissan.rawValue && jewishDay == 15) || (!inIsrael && jewishMonth == HebrewMonth.nissan.rawValue && jewishDay == 16) || yomTovIndex == kShavuos.rawValue || yomTovIndex == kSuccos.rawValue || yomTovIndex == kSheminiAtzeres.rawValue || isCholHamoedSuccos() || isChanukah() {
            return "הלל שלם";
        } else if isRoshChodesh() || isCholHamoedPesach() || (jewishMonth == HebrewMonth.nissan.rawValue && jewishDay == 21) || (!inIsrael && jewishMonth == HebrewMonth.nissan.rawValue && jewishDay == 22) {
            return "חצי הלל";
        } else {
            return ""
        }
    }
    
    func getIsUlChaparatPeshaSaid() -> String {
        if isRoshChodesh() {
            if isHebrewLeapYear(currentHebrewYear()) {
                let month = currentHebrewMonth()
                if month == HebrewMonth.tishrei.rawValue || month == HebrewMonth.cheshvan.rawValue || month == HebrewMonth.kislev.rawValue || month == HebrewMonth.teves.rawValue || month == HebrewMonth.shevat.rawValue || month == HebrewMonth.adar.rawValue || month == HebrewMonth.adar_II.rawValue {
                    return "Say וּלְכַפָּרַת פֶּשַׁע";
                } else {
                    return "Do not say וּלְכַפָּרַת פֶּשַׁע";
                }
            } else {
                return "Do not say וּלְכַפָּרַת פֶּשַׁע";
            }
        }
        return ""
    }
    
    func isOKToListenToMusic() -> String {
        if getDayOfOmer() >= 8 && getDayOfOmer() <= 32 {
            return "No Music"
        } else if currentHebrewMonth() == HebrewMonth.tammuz.rawValue {
            if currentHebrewDayOfMonth() >= 17 {
                return "No Music"
            }
        } else if currentHebrewMonth() == HebrewMonth.av.rawValue {
            if currentHebrewDayOfMonth() <= 9 {
                return "No Music"
            }
        }
        return "";
    }
    
    func is3Weeks() -> Bool {
        if currentHebrewMonth() == HebrewMonth.tammuz.rawValue {
            return currentHebrewDayOfMonth() >= 17
        } else if currentHebrewMonth() == HebrewMonth.av.rawValue {
            return currentHebrewDayOfMonth() < 9
        }
        return false
    }
    
    func is9Days() -> Bool {
        if currentHebrewMonth() == HebrewMonth.av.rawValue {
            return currentHebrewDayOfMonth() < 9
        }
        return false
    }
    
    func isShevuahShechalBo() -> Bool {
        if currentHebrewMonth() != HebrewMonth.av.rawValue {
            return false
        }
        
        let backup = workingDate
        
        workingDate = Calendar(identifier: .hebrew).date(bySetting: .day, value: 9, of: workingDate)!
        
        if currentDayOfTheWeek() == 1 || currentDayOfTheWeek() == 7 {
            return false
        }
        workingDate = backup// reset
        
        let tishaBeav = Calendar(identifier: .hebrew).date(bySetting: .day, value: 8, of: workingDate)!
        let jewishCal = JewishCalendar()
        jewishCal.workingDate = tishaBeav
        
        var daysOfShevuahShechalBo = Array<Int>()
        
        while jewishCal.currentDayOfTheWeek() != 7 {
            daysOfShevuahShechalBo.append(jewishCal.currentHebrewDayOfMonth())
            jewishCal.workingDate = jewishCal.workingDate.advanced(by: -86400)
        }
        return daysOfShevuahShechalBo.contains(currentHebrewDayOfMonth())
    }
    
    func isBirkasHachamah() -> Bool {
        var elapsedDays = getJewishCalendarElapsedDays(jewishYear: currentHebrewYear())
        elapsedDays = elapsedDays + getDaysSinceStartOfJewishYear()
        if elapsedDays % Int((28 * 365.25)) == 172 {
            return true
        }
        return false
    }
    
    func getBirchatLevanaStatus() -> String {
        let CHALKIM_PER_DAY = 25920
        let chalakim = getChalakimSinceMoladTohu(year: currentHebrewYear(), month: currentHebrewMonth())
        let moladToAbsDate = (chalakim / CHALKIM_PER_DAY) + (-1373429)
        var year = moladToAbsDate / 366
        while (moladToAbsDate >= gregorianDateToAbsDate(year: year+1,month: 1,dayOfMonth: 1)) {
            year+=1
        }
        var month = 1
        while (moladToAbsDate > gregorianDateToAbsDate(year: year, month: month, dayOfMonth: getLastDayOfGregorianMonth(month: month, year: year))) {
            month+=1
        }
        var dayOfMonth = moladToAbsDate - gregorianDateToAbsDate(year: year, month: month, dayOfMonth: 1) + 1
        if dayOfMonth > getLastDayOfGregorianMonth(month: month, year: year) {
            dayOfMonth = getLastDayOfGregorianMonth(month: month, year: year)
        }
        let conjunctionDay = chalakim / CHALKIM_PER_DAY
        let conjunctionParts = chalakim - conjunctionDay * CHALKIM_PER_DAY
        
        var moladHours = conjunctionParts / 1080
        let moladRemainingChalakim = conjunctionParts - moladHours * 1080
        var moladMinutes = moladRemainingChalakim / 18
        let moladChalakim = moladRemainingChalakim - moladMinutes * 18
        var moladSeconds = Double(moladChalakim * 10 / 3)
        
        moladMinutes = moladMinutes - 20//to get to Standard Time
        moladSeconds = moladSeconds - 56.496//to get to Standard Time
        
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = Calendar.current.timeZone
        
        var moladDay = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "GMT+2")!, year: year, month: month, day: dayOfMonth, hour: moladHours, minute: moladMinutes, second: Int(moladSeconds))
        
        var molad:Date? = nil
        
        if moladHours > 6 {
            moladHours = (moladHours + 18) % 24
            moladDay.day! += 1
            moladDay.setValue(moladHours, for: .hour)
            molad = calendar.date(from: moladDay)
        } else {
            molad = calendar.date(from: moladDay)
        }
        
        let sevenDays = calendar.date(byAdding: .day, value: 7, to: molad!)!

        if currentHebrewMonth() != HebrewMonth.av.rawValue {
            if Calendar.current.isDate(workingDate, inSameDayAs: sevenDays) {
                return "Birchat HaLevana starts tonight";
            }
        } else {
            if currentHebrewDayOfMonth() < 9 {
                return ""
            }
            if yomTovIndex() == kTishaBeav.rawValue {
                return "Birchat HaLevana starts tonight";
            }
        }
        
        if currentHebrewDayOfMonth() == 14 {
            return "Last night for Birchat HaLevana";
        }
        
        let latest = Calendar(identifier: .hebrew).date(bySetting: .day, value: 14, of: sevenDays)!
        
        if workingDate.timeIntervalSince1970 > sevenDays.timeIntervalSince1970 && workingDate.timeIntervalSince1970 < latest.timeIntervalSince1970 {
            let format = DateFormatter()
            format.dateFormat = "MMM d"
            return "Birchat HaLevana until " + format.string(from: latest)
        }
        return ""
    }
    
    func gregorianDateToAbsDate(year:Int, month:Int, dayOfMonth:Int) -> Int {
        var absDate = dayOfMonth
        for m in stride(from: month-1, to: 0, by: -1) {
            absDate += getLastDayOfGregorianMonth(month: m, year: year)
        }
        return (absDate // days this year
                + 365 * (year - 1) // days in previous years ignoring leap days
                + (year - 1) / 4 // Julian leap days before this year
                - (year - 1) / 100 // minus prior century years
        + (year - 1) / 400); // plus prior years divisible by 400
    }
    
    func getLastDayOfGregorianMonth(month:Int, year:Int) -> Int {
        switch month {
        case 2:
            if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                return 29;
            } else {
                return 28;
            }
        case 4:
            return 30;
        case 6:
            return 30;
        case 9:
            return 30;
        case 11:
            return 30;
        default:
            return 31;
        }
    }

    func getIsMashivHaruchOrMoridHatalSaid() -> String {
        if isMashivHaruachRecited() {
            return "משיב הרוח"
        }
        if isMoridHatalRecited() {
            return "מוריד הטל"
        }
        return ""
    }
    
    func getIsBarcheinuOrBarechAleinuSaid() -> String {
        if (isVeseinBerachaRecited()) {
            return "ברכנו";
        } else {
            return "ברך עלינו";
        }
    }

    func isMashivHaruachRecited() -> Bool {
        let calendar = Calendar(identifier: .hebrew)
        let startDateComponents = DateComponents(calendar: calendar, year: currentHebrewYear(), month: 1, day: 22)
        let startDate = calendar.date(from: startDateComponents)!
        let endDateComponents = DateComponents(calendar: calendar, year: currentHebrewYear(), month: 8, day: 15)
        let endDate = calendar.date(from: endDateComponents)!
        return workingDate > startDate && workingDate < endDate
    }
    
    func isMoridHatalRecited() -> Bool {
        return !isMashivHaruachRecited() || isMashivHaruachStartDate() || isMashivHaruachEndDate()
    }
    
    func isMashivHaruachStartDate() -> Bool {
        return currentHebrewMonth() == HebrewMonth.tishrei.rawValue && currentHebrewDayOfMonth() == 22
    }
    
    func isMashivHaruachEndDate() -> Bool {
        return currentHebrewMonth() == HebrewMonth.nissan.rawValue && currentHebrewDayOfMonth() == 15
    }
    
    func isVeseinBerachaRecited() -> Bool {
        return !isVeseinTalUmatarRecited()
    }
    
    func isVeseinTalUmatarRecited() -> Bool {
        if currentHebrewMonth() == HebrewMonth.nissan.rawValue && currentHebrewDayOfMonth() < 15 {
            return true
        }
        if currentHebrewMonth() == HebrewMonth.nissan.rawValue || currentHebrewMonth() == HebrewMonth.iyar.rawValue || currentHebrewMonth() == HebrewMonth.sivan.rawValue || currentHebrewMonth() == HebrewMonth.tammuz.rawValue || currentHebrewMonth() == HebrewMonth.av.rawValue || currentHebrewMonth() == HebrewMonth.elul.rawValue || currentHebrewMonth() == HebrewMonth.tishrei.rawValue {
            return false
        }
        if inIsrael {
            return currentHebrewMonth() != HebrewMonth.cheshvan.rawValue || currentHebrewDayOfMonth() >= 7
        } else {
            let t = getTekufasTishreiElapsedDays()
            return t >= 47;
        }
    }
    
    func getTekufa() -> Double? {
        let INITIAL_TEKUFA_OFFSET = 12.625 // the number of days Tekufas Tishrei occurs before JEWISH_EPOCH

        let days = Double(getJewishCalendarElapsedDays(jewishYear: currentHebrewYear()) + getDaysSinceStartOfJewishYear()) + INITIAL_TEKUFA_OFFSET - 1 // total days since first Tekufas Tishrei event

        let solarDaysElapsed = days.truncatingRemainder(dividingBy: 365.25) // total days elapsed since start of solar year
        let tekufaDaysElapsed = solarDaysElapsed.truncatingRemainder(dividingBy: 91.3125) // the number of days that have passed since a tekufa event
        if (tekufaDaysElapsed > 0 && tekufaDaysElapsed <= 1) { // if the tekufa happens in the upcoming 24 hours
            return ((1.0 - tekufaDaysElapsed) * 24.0).truncatingRemainder(dividingBy: 24) // rationalize the tekufa event to number of hours since start of jewish day
        } else {
            return nil
        }
    }
    
    func getTekufaName() -> String {
        let tekufaNames = ["Tishri", "Tevet", "Nissan", "Tammuz"]
        let INITIAL_TEKUFA_OFFSET = 12.625 // the number of days Tekufas Tishrei occurs before JEWISH_EPOCH

        let days = Double(getJewishCalendarElapsedDays(jewishYear: currentHebrewYear()) + getDaysSinceStartOfJewishYear()) + INITIAL_TEKUFA_OFFSET - 1 // total days since first Tekufas Tishrei event

        let solarDaysElapsed = days.truncatingRemainder(dividingBy: 365.25) // total days elapsed since start of solar year
        let currentTekufaNumber = Int(solarDaysElapsed / 91.3125)
        let tekufaDaysElapsed = solarDaysElapsed.truncatingRemainder(dividingBy: 91.3125) // the number of days that have passed since a tekufa event
        
        if (tekufaDaysElapsed > 0 && tekufaDaysElapsed <= 1) {//if the tekufa happens in the upcoming 24 hours
            return tekufaNames[currentTekufaNumber]
        } else {
            return ""
        }
    }
    
    func getTekufaAsDate() -> Date? {
        let yerushalayimStandardTZ = TimeZone(identifier: "GMT+2")!
        let cal = Calendar(identifier: .gregorian)
        let workingDateComponents = cal.dateComponents([.year, .month, .day], from: workingDate)
        guard let tekufa = getTekufa() else {
            return nil
        }
        let hours = tekufa - 6
        let minutes = Int((hours - Double(Int(hours))) * 60)
        return cal.date(from: DateComponents(calendar: cal, timeZone: yerushalayimStandardTZ, year: workingDateComponents.year, month: workingDateComponents.month, day: workingDateComponents.day, hour: Int(hours), minute: minutes, second: 0, nanosecond: 0))
    }
    
    func getAmudeiHoraahTekufaAsDate() -> Date? {
        let yerushalayimStandardTZ = TimeZone(identifier: "GMT+2")!
        let cal = Calendar(identifier: .gregorian)
        let workingDateComponents = cal.dateComponents([.year, .month, .day], from: workingDate)
        guard let tekufa = getTekufa() else {
            return nil
        }
        let hours = tekufa - 6
        var minutes = Int((hours - Double(Int(hours))) * 60)
        minutes -= 21
        return cal.date(from: DateComponents(calendar: cal, timeZone: yerushalayimStandardTZ, year: workingDateComponents.year, month: workingDateComponents.month, day: workingDateComponents.day, hour: Int(hours), minute: minutes, second: 0, nanosecond: 0))
    }

    
    func getTekufasTishreiElapsedDays() -> Int {
        // Days since Rosh Hashana year 1. Add 1/2 day as the first tekufas tishrei was 9 hours into the day. This allows all
        // 4 years of the secular leap year cycle to share 47 days. Truncate 47D and 9H to 47D for simplicity.
        let days = Double(getJewishCalendarElapsedDays(jewishYear: currentHebrewYear())) + Double(getDaysSinceStartOfJewishYear() - 1) + 0.5
        // days of completed solar years
        let solar = Double(currentHebrewYear() - 1) * 365.25
        return Int(floor(days - solar))
    }
    
    func getDaysSinceStartOfJewishYear() -> Int {
        var elapsedDays = currentHebrewDayOfMonth()
        
        var hebrewMonth = currentHebrewMonth()
        
        if !isHebrewLeapYear(currentHebrewYear()) && hebrewMonth >= 7 {
            hebrewMonth = hebrewMonth - 1//special case for adar 2 because swift is weird
        }
        
        for month in 1..<hebrewMonth {
            elapsedDays += daysInJewishMonth(month: month, year: currentHebrewYear())
        }
        
        return elapsedDays
    }
    
    func daysInJewishMonth(month: Int, year: Int) -> Int {
        if ((month == HebrewMonth.iyar.rawValue) || (month == HebrewMonth.tammuz.rawValue) || (month == HebrewMonth.elul.rawValue) || ((month == HebrewMonth.cheshvan.rawValue) && !(isCheshvanLong(year: year))) || ((month == HebrewMonth.kislev.rawValue) && isKislevShort()) || (month == HebrewMonth.teves.rawValue) || ((month == HebrewMonth.adar.rawValue) && !(isHebrewLeapYear(year))) || (month == HebrewMonth.adar_II.rawValue && isHebrewLeapYear(year))) {
            return 29;
        } else {
            return 30;
        }
    }
    
    func isCheshvanLong(year:Int) -> Bool {
        return length(ofHebrewYear: year) == HebrewYearType.shalaim.rawValue
    }

    func getJewishCalendarElapsedDays(jewishYear: Int) -> Int {
        // The number of chalakim (25,920) in a 24 hour day.
        let CHALAKIM_PER_DAY: Int = 25920 // 24 * 1080
        let chalakimSince = getChalakimSinceMoladTohu(year: jewishYear, month: Int(HebrewMonth.tishrei.rawValue))
        let moladDay = Int(chalakimSince / CHALAKIM_PER_DAY)
        let moladParts = Int(chalakimSince - chalakimSince / CHALAKIM_PER_DAY * CHALAKIM_PER_DAY)
        // delay Rosh Hashana for the 4 dechiyos
        return addDechiyos(year: jewishYear, moladDay: moladDay, moladParts: moladParts)
    }
    
    func getChalakimSinceMoladTohu(year: Int, month: Int) -> Int {
        // The number  of chalakim in an average Jewish month. A month has 29 days, 12 hours and 793 chalakim (44 minutes and 3.3 seconds) for a total of 765,433 chalakim
        let CHALAKIM_PER_MONTH: Int = 765433 // (29 * 24 + 12) * 1080 + 793

        // Days from the beginning of Sunday till molad BaHaRaD. Calculated as 1 day, 5 hours and 204 chalakim = (24 + 5) * 1080 + 204 = 31524
        let CHALAKIM_MOLAD_TOHU: Int = 31524
        // Jewish lunar month = 29 days, 12 hours and 793 chalakim
        // chalakim since Molad Tohu BeHaRaD - 1 day, 5 hours and 204 chalakim
        var monthOfYear = month
        if !isHebrewLeapYear(year) && monthOfYear >= 7 {
            monthOfYear = monthOfYear - 1//special case for adar 2 because swift is weird
        }
        var monthsElapsed = (235 * ((year - 1) / 19))
        monthsElapsed = monthsElapsed + (12 * ((year - 1) % 19))
        monthsElapsed = monthsElapsed + ((7 * ((year - 1) % 19) + 1) / 19)
        monthsElapsed = monthsElapsed + (monthOfYear - 1)
        // return chalakim prior to BeHaRaD + number of chalakim since
        return Int(CHALAKIM_MOLAD_TOHU + (CHALAKIM_PER_MONTH * Int(monthsElapsed)))
    }
    
    func addDechiyos(year: Int, moladDay: Int, moladParts: Int) -> Int {
        var roshHashanaDay = moladDay // if no dechiyos
        // delay Rosh Hashana for the dechiyos of the Molad - new moon 1 - Molad Zaken, 2- GaTRaD 3- BeTuTaKFoT
        if (moladParts >= 19440) || // Dechiya of Molad Zaken - molad is >= midday (18 hours * 1080 chalakim)
            ((moladDay % 7) == 2 && // start Dechiya of GaTRaD - Ga = is a Tuesday
             moladParts >= 9924 && // TRaD = 9 hours, 204 parts or later (9 * 1080 + 204)
             !isHebrewLeapYear(year)) || // of a non-leap year - end Dechiya of GaTRaD
            ((moladDay % 7) == 1 && // start Dechiya of BeTuTaKFoT - Be = is on a Monday
             moladParts >= 16789 && // TRaD = 15 hours, 589 parts or later (15 * 1080 + 589)
             isHebrewLeapYear(year - 1)) { // in a year following a leap year - end Dechiya of BeTuTaKFoT
            roshHashanaDay += 1 // Then postpone Rosh HaShanah one day
        }
        // start 4th Dechiya - Lo ADU Rosh - Rosh Hashana can't occur on A- sunday, D- Wednesday, U - Friday
        if (roshHashanaDay % 7 == 0) || // If Rosh HaShanah would occur on Sunday,
            (roshHashanaDay % 7 == 3) || // or Wednesday,
            (roshHashanaDay % 7 == 5) { // or Friday - end 4th Dechiya - Lo ADU Rosh
            roshHashanaDay += 1 // Then postpone it one (more) day
        }
        return roshHashanaDay
    }
}


public extension DafYomiCalculator {
    
    func dafYomiYerushalmi(calendar: JewishCalendar) -> Daf? {
        let dafYomiStartDay = gregorianDate(forYear: 1980, month: 2, andDay: 2)
        let WHOLE_SHAS_DAFS = 1554
        let BLATT_PER_MASSECTA = [
            68, 37, 34, 44, 31, 59, 26, 33, 28, 20, 13, 92, 65, 71, 22, 22, 42, 26, 26, 33, 34, 22,
            19, 85, 72, 47, 40, 47, 54, 48, 44, 37, 34, 44, 9, 57, 37, 19, 13
        ]
        
        let dateCreator = Calendar(identifier: .gregorian)
        var nextCycle = DateComponents()
        var prevCycle = DateComponents()
        var masechta = 0
        var dafYomi: Daf?
        
        // There isn't Daf Yomi on Yom Kippur or Tisha B'Av.
        if calendar.yomTovIndex() == kYomKippur.rawValue || calendar.yomTovIndex() == kTishaBeav.rawValue {
            return nil
        }
        
        if calendar.workingDate.compare(dafYomiStartDay!) == .orderedAscending {
            return nil
        }
        
        nextCycle.year = 1980
        nextCycle.month = 2
        nextCycle.day = 2
        
//        let n = dateCreator.date(from: nextCycle)
//        let p = dateCreator.date(from: prevCycle)

        // Go cycle by cycle, until we get the next cycle
        while calendar.workingDate.compare(dateCreator.date(from: nextCycle)!) == .orderedDescending {
            prevCycle = nextCycle
            
            nextCycle.day! += WHOLE_SHAS_DAFS
            nextCycle.day! += getNumOfSpecialDays(startDate: dateCreator.date(from: prevCycle)!, endDate: dateCreator.date(from: nextCycle)!)
        }
        
        // Get the number of days from cycle start until request.
        let dafNo = getDiffBetweenDays(start: dateCreator.date(from: prevCycle)!, end: calendar.workingDate)
        
        // Get the number of special day to subtract
        let specialDays = getNumOfSpecialDays(startDate: dateCreator.date(from: prevCycle)!, endDate: calendar.workingDate)
        var total = dafNo - specialDays
        
        // Finally find the daf.
        for j in 0..<BLATT_PER_MASSECTA.count {
            if total < BLATT_PER_MASSECTA[j] {
                dafYomi = Daf(tractateIndex: masechta, andPageNumber: total + 1)
                break
            }
            masechta += 1
            total -= BLATT_PER_MASSECTA[j]
        }
        
        return dafYomi
    }

    private func gregorianDate(forYear year: Int, month: Int, andDay day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.calendar = Calendar(identifier: .gregorian)
        return components.date
    }
    
    func getNumOfSpecialDays(startDate: Date, endDate: Date) -> Int {
        let startCalendar = JewishCalendar()
        startCalendar.workingDate = startDate
        let endCalendar = JewishCalendar()
        endCalendar.workingDate = endDate
        
        var startYear = startCalendar.currentHebrewYear()
        let endYear = endCalendar.currentHebrewYear()
        
        var specialDays = 0
        
        let dateCreator = Calendar(identifier: .hebrew)

        //create a hebrew calendar set to the date 7/10/5770
        var yomKippurComponents = DateComponents()
        yomKippurComponents.year = 5770
        yomKippurComponents.month = 1
        yomKippurComponents.day = 10
        
        var tishaBeavComponents = DateComponents()
        tishaBeavComponents.year = 5770
        tishaBeavComponents.month = 5
        tishaBeavComponents.day = 9
        
        while startYear <= endYear {
            yomKippurComponents.year = startYear
            tishaBeavComponents.year = startYear
            
            if isBetween(start: startDate, date: dateCreator.date(from: yomKippurComponents)!, end: endDate) {
                specialDays += 1
            }
            
            if isBetween(start: startDate, date: dateCreator.date(from: tishaBeavComponents)!, end: endDate) {
                specialDays += 1
            }
            
            startYear += 1
        }

        return specialDays
    }

    func isBetween(start: Date, date: Date, end: Date) -> Bool {
        return (start.compare(date) == .orderedAscending) && (end.compare(date) == .orderedDescending)
    }

    func getDiffBetweenDays(start: Date, end: Date) -> Int {
        let DAY_MILIS: Double = 24 * 60 * 60
        let s = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
        return s / Int(DAY_MILIS)
    }
}

public extension Daf {
    
    func nameYerushalmi() -> String {
        let names = ["ברכות"
                     , "פיאה"
                     , "דמאי"
                     , "כלאים"
                     , "שביעית"
                     , "תרומות"
                     , "מעשרות"
                     , "מעשר שני"
                     , "חלה"
                     , "עורלה"
                     , "ביכורים"
                     , "שבת"
                     , "עירובין"
                     , "פסחים"
                     , "ביצה"
                     , "ראש השנה"
                     , "יומא"
                     , "סוכה"
                     , "תענית"
                     , "שקלים"
                     , "מגילה"
                     , "חגיגה"
                     , "מועד קטן"
                     , "יבמות"
                     , "כתובות"
                     , "סוטה"
                     , "נדרים"
                     , "נזיר"
                     , "גיטין"
                     , "קידושין"
                     , "בבא קמא"
                     , "בבא מציעא"
                     , "בבא בתרא"
                     , "שבועות"
                     , "מכות"
                     , "סנהדרין"
                     , "עבודה זרה"
                     , "הוריות"
                     , "נידה"
                     , "אין דף היום"]

        return names[tractateIndex]
    }
}

extension Int {
    func formatHebrew() -> String {
        if self <= 0 {
            fatalError("Input must be a positive integer")
        }
        var ret = String(repeating: "ת", count: self / 400)
        var num = self % 400
        if num >= 100 {
            ret.append("קרש"[String.Index(utf16Offset: num / 100 - 1, in: "קרש")])
            num %= 100
        }
        switch num {
        // Avoid letter combinations from the Tetragrammaton
        case 16:
            ret.append("טז")
        case 15:
            ret.append("טו")
        default:
            if num >= 10 {
                ret.append("יכלמנסעפצ"[String.Index(utf16Offset: num / 10 - 1, in: "יכלמנסעפצ")])
                num %= 10
            }
            if num > 0 {
                ret.append("אבגדהוזחט"[String.Index(utf16Offset: num - 1, in: "אבגדהוזחט")])
            }
        }
        return ret
    }
}
