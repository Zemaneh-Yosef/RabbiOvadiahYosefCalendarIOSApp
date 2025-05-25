//
//  ZmanimView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 2/10/25.
//

import SwiftUI
import KosherSwift
import WatchConnectivity
import SunCalc
import CoreLocation
import ActivityKit
import Combine
import SwiftUIScrollOffset

@available(iOS 15.0, *)
struct ZmanimView: View {
    @State var locationName: String = ""
    @State var lat: Double = 0
    @State var long: Double = 0
    @State var elevation: Double = 0.0
    @State var timezone: TimeZone = TimeZone.current
    @State var shabbatMode: Bool = false
    @State var useElevation: Bool = false
    @State var userChosenDate: Date = GlobalStruct.userChosenDate
    @State var lastTimeUserWasInApp: Date = Date()
    @State var nextUpcomingZman: Date? = nil
    @State var zmanimCalendar: ComplexZmanimCalendar = ComplexZmanimCalendar()
    @State var jewishCalendar: JewishCalendar = JewishCalendar()
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    @State private var zmanimList: [ZmanListEntry] = []
    let dateFormatterForZmanim = DateFormatter()
    let dateFormatterForRT = DateFormatter()
    @State var timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()
    @State var timerForShabbatMode: Publishers.Autoconnect<Timer.TimerPublisher> = .init(upstream: .init(interval: .greatestFiniteMagnitude, runLoop: .current, mode: .default))
    @State var scrollViewOffset = CGFloat(1000)
    @State var timerForNextZman: Timer?
    var shouldAddMisheyakirZman = false
    @State var askedToUpdateTablesAlready = false
    @StateObject private var sessionManager = WCSessionManager.shared
    @State var simpleList = false
    @State var showSetup = false
    @State var didLocationUpdate = false
    @State var datePickerIsVisible = false
    @State var hebrewDatePickerIsVisible = false
    @State var scrollToTop = false
    @State var scrollDirection = 1
    @ScrollOffsetProxy(.bottom, id: "Scroller") private var scrollOffsetProxy
    
    @State var showZmanAlert = false
    @State var showLocationInfoAlert = false
    @State var selectedZman: ZmanListEntry = ZmanListEntry(title: "")
    @State var showLocationServicesDisabledAlert = false
    @State var showInIsraelAlert = false
    @State var showOutOfIsraelAlert = false
    @State var showTablesNeedToBeUpdatedAlert = false
    @State var showChaitablesErrorAlert = false
    @State var showAppUpdateAlert = false
    @State var appStoreURL: String? = nil
    @State var showShareSheet = false
    @State var nextView = NextView.none
    @State var showNextView = false
    @State var isBannerHidden = false
    @State var isFirstTimeForShabbatBanner = true
    
    init() {
        dateFormatterForZmanim.dateFormat = (Locale.isHebrewLocale() ? "H" : "h") + ":mm" + (defaults.bool(forKey: "showSeconds") ? ":ss" : "")
        dateFormatterForRT.dateFormat = (Locale.isHebrewLocale() ? "H" : "h") + ":mm" + (defaults.bool(forKey: "roundUpRT") ? "" : ":ss")
    }
    
    func startShabbatMode() {
        userChosenDate = Date()
        syncCalendarDates()
        updateZmanimList()
        isBannerHidden = false
        scheduleTimer()//to update zmanim at 12AM
    }
    
    func endShabbatMode() {
        updateZmanimList()
        scrollViewOffset = CGFloat(1000)
    }
    
    func scheduleTimer() {
        let calendar = Calendar.current
        let currentDate = Date()
        var dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: currentDate)
        dateComponents.day! += 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 2
        let targetDate = calendar.date(from: dateComponents)!

        let timeInterval = calendar.dateComponents([.second], from: currentDate, to: targetDate).second!
        timerForShabbatMode = Timer.publish(every: TimeInterval(timeInterval), on: .main, in: .common).autoconnect()
    }
    
    func formatDate(using calendar: Calendar = Calendar.current, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale.current
        dateFormatter.calendar = calendar
        return dateFormatter.string(from: GlobalStruct.userChosenDate)
    }
    
    func getFastStartTime() -> String {
        let zmanimNames = ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        let useAHZmanim = defaults.bool(forKey: "LuachAmudeiHoraah")
        if jewishCalendar.isTaanis()
            && !jewishCalendar.isTishaBav()
            && !jewishCalendar.isYomKippur() {
            return zmanimNames.getTaanitString() + zmanimNames.getStartsString() + ": " + dateFormatterForZmanim.string(from:((useAHZmanim ? zmanimCalendar.getAlosAmudeiHoraah() : zmanimCalendar.getAlos72Zmanis()) ?? Date()))
        } else if jewishCalendar.tomorrow().isTaanis() && jewishCalendar.tomorrow().isTishaBav() {
            return zmanimNames.getTaanitString() + zmanimNames.getStartsString() + ": " + dateFormatterForZmanim.string(from:( zmanimCalendar.getElevationAdjustedSunset() ?? Date()))
        } else {
            if jewishCalendar.tomorrow().isTaanis() && !jewishCalendar.tomorrow().isTishaBav() {
                zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(86400)
                let tomorrowAlot = dateFormatterForZmanim.string(from:((useAHZmanim ? zmanimCalendar.getAlosAmudeiHoraah() : zmanimCalendar.getAlos72Zmanis()) ?? Date()))
                zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(-86400)
                return zmanimNames.getTaanitString() + zmanimNames.getStartsString() + ": " + tomorrowAlot
            } else {
                zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(-86400)
                let yesterdaySunset = dateFormatterForZmanim.string(from:(zmanimCalendar.getElevationAdjustedSunset() ?? Date()))
                zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(86400)
                return zmanimNames.getTaanitString() + zmanimNames.getStartsString() + ": " + yesterdaySunset
            }
        }
    }
    
    func getFastEndTime() -> String {
        let zmanimNames = ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        let useAHZmanim = defaults.bool(forKey: "LuachAmudeiHoraah")
        if jewishCalendar.isTaanis()
            && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
            return zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() + ": " + dateFormatterForZmanim.string(from: (useAHZmanim ? zmanimCalendar.getTzaisAmudeiHoraahLChumra() : zmanimCalendar.getTzaisAteretTorah(minutes: 20)) ?? Date())
        } else {// This method was called the day before
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(86400)
            let fastEnds = dateFormatterForZmanim.string(from: (useAHZmanim ? zmanimCalendar.getTzaisAmudeiHoraahLChumra() ?? Date() : zmanimCalendar.getTzaisAteretTorah(minutes: 20) ?? Date()))
            zmanimCalendar.workingDate = zmanimCalendar.workingDate.addingTimeInterval(-86400)
            return zmanimNames.getTaanitString() + zmanimNames.getEndsString() + ": " + fastEnds
        }
    }
    
    func getShabbatStartEndsAsString() -> String {
        let zmanimNames = ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
        let useAHZmanim = defaults.bool(forKey: "LuachAmudeiHoraah")
        let backup = jewishCalendar.workingDate
        while jewishCalendar.isAssurBemelacha() {
            jewishCalendar.back()// go back until the start of shabbat/yom tov
        }
        zmanimCalendar.workingDate = jewishCalendar.workingDate
        let startTime = dateFormatterForZmanim.string(from: zmanimCalendar.getCandleLighting() ?? Date())
        while jewishCalendar.tomorrow().isAssurBemelacha() {
            jewishCalendar.forward()
        }
        zmanimCalendar.workingDate = jewishCalendar.workingDate
        zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
        if defaults.object(forKey: "shabbatOffset") != nil {
            zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
        }
        var endShabbat: Date?
        if !defaults.bool(forKey: "overrideAHEndShabbatTime") {// default zman
            endShabbat = (useAHZmanim ? zmanimCalendar.getTzaisShabbosAmudeiHoraah() : zmanimCalendar.getTzaisAteretTorah())
        } else {// if user wants to override
            if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                endShabbat = zmanimCalendar.getTzaisAteretTorah()
            } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                endShabbat = zmanimCalendar.getTzaisShabbosAmudeiHoraah()
            } else {
                endShabbat = zmanimCalendar.getTzaisShabbosAmudeiHoraahLesserThan40()
            }
        }
        let endTime = dateFormatterForZmanim.string(from: endShabbat ?? Date())
        let result = getShabbatAndOrChag() + zmanimNames.getStartsString() + ": " + startTime + " - " + zmanimNames.getEndsString() + ": " + endTime
        jewishCalendar.workingDate = backup
        return result
    }
    
    func getShabbatAndOrChag() -> String {
        if (defaults.bool(forKey: "isZmanimInHebrew")) {
            if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.getDayOfWeek() == 7 {
                return "\u{05E9}\u{05D1}\u{05EA}/\u{05D7}\u{05D2}"
            } else if jewishCalendar.getDayOfWeek() == 7 {
                return "\u{05E9}\u{05D1}\u{05EA}"
            } else {
                return "\u{05D7}\u{05D2}"
            }
        } else {
            if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.getDayOfWeek() == 7 {
                return "Shabbat/Chag";
            } else if jewishCalendar.getDayOfWeek() == 7 {
                return "Shabbat";
            } else {
                return "Chag";
            }
        }
    }
    
    func getMoonRiseSet(isRise: Bool) -> String {
        do {
            var cal = Calendar.current
            cal.timeZone = timezone
            let moonTimes = try MoonTimes.compute()
                .on(cal.startOfDay(for: userChosenDate))
                .at(lat, long)
                .timezone(timezone)
                .limit(TimeInterval.ofDays(1))
                .execute()
            if (moonTimes.alwaysUp) {
                return "The moon is up all night".localized()
            } else if (moonTimes.alwaysDown) {
                return "There is no moon tonight".localized()
            } else {
                let dateFormatterForMoonTimes = DateFormatter()
                dateFormatterForMoonTimes.dateFormat = Locale.isHebrewLocale() ? "H:mm" : "h:mm aa"
                var moonRiseSet = ""
                if (isRise && moonTimes.rise != nil) {
                    moonRiseSet += "Moonrise: ".localized() + dateFormatterForMoonTimes.string(from: Date(timeIntervalSince1970: moonTimes.rise!.timeIntervalSince1970))
                }
                if (!isRise && moonTimes.set != nil) {
                    moonRiseSet += "Moonset: ".localized() + dateFormatterForMoonTimes.string(from: Date(timeIntervalSince1970: moonTimes.set!.timeIntervalSince1970))
                }
                if (!moonRiseSet.isEmpty) {
                    return moonRiseSet
                }
            }
        } catch {
            print(error)
        }
        return ""
    }
    
    func updateZmanimList(add66Misheyakir: Bool = false) {
        zmanimList = []
        if !simpleList {
            zmanimList = ZmanimFactory.addZmanim(list: zmanimList, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, add66Misheyakir: add66Misheyakir)
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, yyyy"
        dateFormatter.timeZone = timezone
        zmanimList.append(ZmanListEntry(title: locationName))
        var date = dateFormatter.string(from: userChosenDate)
        
        let hDateFormatter = DateFormatter()
        hDateFormatter.calendar = Calendar(identifier: .hebrew)
        hDateFormatter.dateFormat = "d MMMM, yyyy"
        var hebrewDate = hDateFormatter.string(from: userChosenDate)
            .replacingOccurrences(of: "Heshvan", with: "Cheshvan")
            .replacingOccurrences(of: "Tamuz", with: "Tammuz")
        
        if Locale.isHebrewLocale() {
            let hebrewDateFormatter = HebrewDateFormatter()
            hebrewDateFormatter.hebrewFormat = true
            hebrewDate = hebrewDateFormatter.format(jewishCalendar: jewishCalendar)
        }
        
        if Calendar.current.isDateInToday(userChosenDate) {
            date += "   ▼   " + hebrewDate
        } else {
            date += "       " + hebrewDate
        }
        zmanimList.append(ZmanListEntry(title:date))
        //forward jewish calendar to saturday
        while jewishCalendar.getDayOfWeek() != 7 {
            jewishCalendar.forward()
        }
        let hebrewDateFormatter = HebrewDateFormatter()
        hebrewDateFormatter.hebrewFormat = true
        //now that we are on saturday, check the parasha
        let specialParasha = hebrewDateFormatter.formatSpecialParsha(jewishCalendar: jewishCalendar)
        var parasha = hebrewDateFormatter.formatParsha(parsha: jewishCalendar.getParshah())
        
        if !specialParasha.isEmpty {
            parasha += " / " + specialParasha
        }
        if !parasha.isEmpty {
            zmanimList.append(ZmanListEntry(title:parasha))
        } else {
            zmanimList.append(ZmanListEntry(title:"No Weekly Parasha".localized()))
        }
        let haftorah = WeeklyHaftarahReading.getThisWeeksHaftarah(jewishCalendar: jewishCalendar)
            .replacingOccurrences(of: "מפטירין", with: Locale.isHebrewLocale() ? "מפטירין" : "Haftarah: \u{202B}")
        if !haftorah.isEmpty {
            zmanimList.append(ZmanListEntry(title: haftorah))
        }
        syncCalendarDates()//reset
        if defaults.bool(forKey: "showShabbatMevarchim") {
            if (jewishCalendar.tomorrow().isShabbosMevorchim()) {
                zmanimList.append(ZmanListEntry(title: "שבת מברכים"))
            }
        }
        dateFormatter.dateFormat = "EEEE"
        hebrewDateFormatter.setLongWeekFormat(longWeekFormat: true)
        if Locale.isHebrewLocale() {
            zmanimList.append(ZmanListEntry(title:dateFormatter.string(from: zmanimCalendar.workingDate)))
        } else {
            zmanimList.append(ZmanListEntry(title:dateFormatter.string(from: zmanimCalendar.workingDate) + " / " + "יום " + hebrewDateFormatter.formatDayOfWeek(jewishCalendar: jewishCalendar)))
        }
        hebrewDateFormatter.hebrewFormat = false
        let specialDay = jewishCalendar.getSpecialDay(addOmer:false)
        if !specialDay.isEmpty {
            zmanimList.append(ZmanListEntry(title:specialDay))
        }
        let omerDay = jewishCalendar.addDayOfOmer(result: Array())
        if omerDay.count == 1 && !omerDay[0].isEmpty {
            zmanimList.append(ZmanListEntry(title:omerDay[0]))
        }
        if jewishCalendar.is3Weeks() {
            if jewishCalendar.is9Days() {
                if jewishCalendar.isShevuahShechalBo() {
                    zmanimList.append(ZmanListEntry(title: "Shevuah Shechal Bo".localized()))
                } else {
                    zmanimList.append(ZmanListEntry(title: "Nine Days".localized()))
                }
            } else {
                zmanimList.append(ZmanListEntry(title: "Three Weeks".localized()))
            }
        }
        if jewishCalendar.isRoshHashana() && jewishCalendar.isShmitaYear() {
            zmanimList.append(ZmanListEntry(title: "This year is a Shemita year".localized()))
        }
        let music = jewishCalendar.isOKToListenToMusic()
        if !music.isEmpty {
            zmanimList.append(ZmanListEntry(title: music))
        }
        let hallel = jewishCalendar.getHallelOrChatziHallel()
        if !hallel.isEmpty {
            zmanimList.append(ZmanListEntry(title: hallel))
        }
        let ulChaparatPesha = jewishCalendar.getIsUlChaparatPeshaSaid()
        if !ulChaparatPesha.isEmpty {
            zmanimList.append(ZmanListEntry(title: ulChaparatPesha))
        }
        zmanimList.append(ZmanListEntry(title:jewishCalendar.getTachanun()))
        if (jewishCalendar.isPurimMeshulash()) {
            zmanimList.append(ZmanListEntry(title: "No Tachanun in Yerushalayim or a Safek Mukaf Choma".localized()))
        }
        let bircatHelevana = jewishCalendar.getBirchatLevanaStatus()
        if !bircatHelevana.isEmpty {
            zmanimList.append(ZmanListEntry(title: bircatHelevana))
            do {
                var cal = Calendar.current
                cal.timeZone = timezone
                let moonTimes = try MoonTimes.compute()
                    .on(cal.startOfDay(for: userChosenDate))
                    .at(lat, long)
                    .timezone(timezone)
                    .limit(TimeInterval.ofDays(1))
                    .execute()
                if (moonTimes.alwaysUp) {
                    zmanimList.append(ZmanListEntry(title: "The moon is up all night".localized()))
                } else if (moonTimes.alwaysDown) {
                    zmanimList.append(ZmanListEntry(title: "There is no moon tonight".localized()))
                } else {
                    let dateFormatterForMoonTimes = DateFormatter()
                    if (Locale.isHebrewLocale()) {
                        dateFormatterForMoonTimes.dateFormat = "H:mm"
                    } else {
                        dateFormatterForMoonTimes.dateFormat = "h:mm aa"
                    }
                    var moonRiseSet = ""
                    if (moonTimes.rise != nil) {
                        moonRiseSet += "Moonrise: ".localized() + dateFormatterForMoonTimes.string(from: Date(timeIntervalSince1970: moonTimes.rise!.timeIntervalSince1970))
                    }
                    if (moonTimes.set != nil) {
                        if (!moonRiseSet.isEmpty) {
                            moonRiseSet += " - ";
                        }
                        moonRiseSet += "Moonset: ".localized() + dateFormatterForMoonTimes.string(from: Date(timeIntervalSince1970: moonTimes.set!.timeIntervalSince1970))
                    }
                    if (!moonRiseSet.isEmpty) {
                        zmanimList.append(ZmanListEntry(title: moonRiseSet));
                    }
                }
            } catch {
                print(error)
            }
        }
        if jewishCalendar.isBirkasHachamah() {
            zmanimList.append(ZmanListEntry(title: "Birchat Ha'Ḥamah is said today".localized()))
        }
        
        if (jewishCalendar.tomorrow().getDayOfWeek() == 7
            && jewishCalendar.tomorrow().getYomTovIndex() == JewishCalendar.EREV_PESACH) {
            zmanimList.append(ZmanListEntry(title: "Burn your Ḥametz today".localized()))
        }
        
        if Locale.isHebrewLocale() {
            dateFormatter.dateFormat = "H:mm"
        } else {
            dateFormatter.dateFormat = "h:mm aa"
        }
        dateFormatter.timeZone = timezone
        let tekufaSetting = defaults.integer(forKey: "tekufaOpinion")
        if (tekufaSetting == 0 && !defaults.bool(forKey: "LuachAmudeiHoraah")) || tekufaSetting == 1 { // 0 is default
            let tekufa = jewishCalendar.getTekufaAsDate()
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
                    addTekufaLength(tekufa, dateFormatter)
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
                    addTekufaLength(checkTomorrowForTekufa, dateFormatter)
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        } else if tekufaSetting == 2 || (tekufaSetting == 0 && defaults.bool(forKey: "LuachAmudeiHoraah")) {
            let tekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
                    addTekufaLength(tekufa, dateFormatter)
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
                    addTekufaLength(checkTomorrowForTekufa, dateFormatter)
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        } else {
            let tekufa = jewishCalendar.getTekufaAsDate()
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
            
            let tekufaAH = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if tekufaAH != nil {
                if Calendar.current.isDate(tekufaAH!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufaAH!)))
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForAHTekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if checkTomorrowForAHTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForAHTekufa!, inSameDayAs: userChosenDate) {
                    zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForAHTekufa!)))
                }
            }
            var earlierTekufa = tekufaAH
            if earlierTekufa == nil {
                earlierTekufa = checkTomorrowForAHTekufa
            }
            var laterTekufa = tekufa
            if laterTekufa == nil {
                laterTekufa = checkTomorrowForTekufa
            }
            if earlierTekufa != nil && laterTekufa != nil && Calendar.current.isDate(earlierTekufa!, inSameDayAs: userChosenDate) {
                let halfHourBefore = earlierTekufa!.addingTimeInterval(-1800)
                let halfHourAfter = laterTekufa!.addingTimeInterval(1800)
                if Locale.isHebrewLocale() {
                    zmanimList.append(ZmanListEntry(title: "Tekufa Length: ".localized()
                        .appending(dateFormatter.string(from: halfHourAfter))
                        .appending(" - ")
                        .appending(dateFormatter.string(from: halfHourBefore))))
                } else {
                    zmanimList.append(ZmanListEntry(title: "Tekufa Length: ".localized()
                        .appending(dateFormatter.string(from: halfHourBefore))
                        .appending(" - ")
                        .appending(dateFormatter.string(from: halfHourAfter))))
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        }
        
        zmanimList = ZmanimFactory.addZmanim(list: zmanimList, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, add66Misheyakir: add66Misheyakir)
        
        zmanimList.append(ZmanListEntry(title:jewishCalendar.getIsMashivHaruchOrMoridHatalSaid() + " / " + jewishCalendar.getIsBarcheinuOrBarechAleinuSaid()))
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        // TODO replace with only colons
        zmanimList.append(ZmanListEntry(title:"Shaah Zmanit GRA: ".localized() + (formatter.string(from: TimeInterval(zmanimCalendar.getShaahZmanisGra() / 1000)) ?? "XX:XX")))
        if defaults.bool(forKey: "LuachAmudeiHoraah") {
            zmanimList.append(ZmanListEntry(title:"Shaah Zemanit MG\"A (A\"H): ".localized() + (formatter.string(from: TimeInterval(zmanimCalendar.getTemporalHour(startOfDay: zmanimCalendar.getAlosAmudeiHoraah(), endOfDay: zmanimCalendar.getTzais72ZmanisAmudeiHoraah()) / 1000)) ?? "XX:XX")))
        } else {
            zmanimList.append(ZmanListEntry(title:"Shaah Zemanit MG\"A (O\"H): ".localized() + (formatter.string(from: TimeInterval(zmanimCalendar.getShaahZmanis72MinutesZmanis() / 1000)) ?? "XX:XX")))
        }
        
        if defaults.bool(forKey: "showShmita") {
            switch (jewishCalendar.getYearOfShmitaCycle()) {
            case 1:
                zmanimList.append(ZmanListEntry(title: "First year of Shemita".localized()))
                break;
            case 2:
                zmanimList.append(ZmanListEntry(title: "Second year of Shemita".localized()))
                break;
            case 3:
                zmanimList.append(ZmanListEntry(title: "Third year of Shemita".localized()))
                break;
            case 4:
                zmanimList.append(ZmanListEntry(title: "Fourth year of Shemita".localized()))
                break;
            case 5:
                zmanimList.append(ZmanListEntry(title: "Fifth year of Shemita".localized()))
                break;
            case 6:
                zmanimList.append(ZmanListEntry(title: "Sixth year of Shemita".localized()))
                break;
            default:
                zmanimList.append(ZmanListEntry(title: "This year is a Shemita Year".localized()))
                break;
            }
        }
    }
    
    func addTekufaLength(_ tekufa: Date?, _ dateFormatter: DateFormatter) {
        let halfHourBefore = tekufa!.addingTimeInterval(-1800)
        let halfHourAfter = tekufa!.addingTimeInterval(1800)
        if Locale.isHebrewLocale() {
            zmanimList.append(ZmanListEntry(title: "Tekufa Length: ".localized()
                .appending(dateFormatter.string(from: halfHourAfter))
                .appending(" - ")
                .appending(dateFormatter.string(from: halfHourBefore))))
        } else {
            zmanimList.append(ZmanListEntry(title: "Tekufa Length: ".localized()
                .appending(dateFormatter.string(from: halfHourBefore))
                .appending(" - ")
                .appending(dateFormatter.string(from: halfHourAfter))))
        }
    }
    
    func doesTekufaOccurToday() -> Bool {
        let tekufaSetting = defaults.integer(forKey: "tekufaOpinion")
        if (tekufaSetting == 0 && !defaults.bool(forKey: "LuachAmudeiHoraah")) || tekufaSetting == 1 { // 0 is default
            let tekufa = jewishCalendar.getTekufaAsDate()
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    return true
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    return true
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        } else if tekufaSetting == 2 || (tekufaSetting == 0 && defaults.bool(forKey: "LuachAmudeiHoraah")) {
            let tekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    return true
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    return true
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        } else {
            let tekufa = jewishCalendar.getTekufaAsDate()
            if tekufa != nil {
                if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                    return true
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
            if checkTomorrowForTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                    return true
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
            
            let tekufaAH = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if tekufaAH != nil {
                if Calendar.current.isDate(tekufaAH!, inSameDayAs: userChosenDate) {
                    return true
                }
            }
            jewishCalendar.forward()
            let checkTomorrowForAHTekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
            if checkTomorrowForAHTekufa != nil {
                if Calendar.current.isDate(checkTomorrowForAHTekufa!, inSameDayAs: userChosenDate) {
                    return true
                }
            }
            jewishCalendar.workingDate = userChosenDate //reset
        }
        return false
    }
    
    func recreateZmanimCalendar() {
        zmanimCalendar = ComplexZmanimCalendar(location: GeoLocation(locationName: locationName, latitude: lat, longitude: long, elevation: elevation, timeZone: timezone.corrected()))
        zmanimCalendar.useElevation = GlobalStruct.useElevation
        zmanimCalendar.useAstronomicalChatzos = false
        GlobalStruct.geoLocation = zmanimCalendar.geoLocation
    }
    
    func setNextUpcomingZman() {
        var theZman: Date? = nil
        var zmanim = Array<ZmanListEntry>()
        var today = Date()
        
        today = today.advanced(by: -86400)//yesterday
        jewishCalendar.workingDate = today
        zmanimCalendar.workingDate = today
        zmanim = ZmanimFactory.addZmanim(list: zmanim, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, add66Misheyakir: false)
        
        today = today.advanced(by: 86400)//today
        jewishCalendar.workingDate = today
        zmanimCalendar.workingDate = today
        zmanim = ZmanimFactory.addZmanim(list: zmanim, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, add66Misheyakir: false)
        
        today = today.advanced(by: 86400)//tomorrow
        jewishCalendar.workingDate = today
        zmanimCalendar.workingDate = today
        zmanim = ZmanimFactory.addZmanim(list: zmanim, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar, add66Misheyakir: false)
        
        zmanimCalendar.workingDate = userChosenDate//reset
        jewishCalendar.workingDate = userChosenDate//reset
        
        for entry in zmanim {
            let zman = entry.zman
            if zman != nil {
                if zman! > Date() && (theZman == nil || zman! < theZman!) {
                    theZman = zman
                }
            }
        }
        nextUpcomingZman = theZman
    }
    
    func createBackgroundThreadForNextUpcomingZman() {
        setNextUpcomingZman()
        updateZmanimList()
        let calendar = Calendar.current
        let timeInterval = calendar.dateComponents([.second], from: Date(), to: nextUpcomingZman!).second!
        timerForNextZman = Timer.scheduledTimer(withTimeInterval: TimeInterval(timeInterval + 1), repeats: false) { _ in
            createBackgroundThreadForNextUpcomingZman()
        }
    }
    
    func syncCalendarDates() {//with userChosenDate
        zmanimCalendar.workingDate = userChosenDate
        jewishCalendar.workingDate = userChosenDate
        GlobalStruct.jewishCalendar.workingDate = userChosenDate
        GlobalStruct.userChosenDate = userChosenDate
    }
    
    func setNotificationsDefaults() {
        defaults.set(false, forKey: "showDayOfOmer")
        defaults.set(true, forKey: "roundUpRT")
        defaults.set(false, forKey: "zmanim_notifications")
        defaults.set(false, forKey: "zmanim_notifications_on_shabbat")
        
        defaults.set(false, forKey: "NotifyAlot Hashachar")
        defaults.set(false, forKey: "NotifyTalit And Tefilin")
        defaults.set(false, forKey: "NotifySunrise")
        defaults.set(true, forKey: "NotifySof Zman Shma MGA")
        defaults.set(true, forKey: "NotifySof Zman Shma GRA")
        defaults.set(true, forKey: "NotifySof Zman Tefila")
        defaults.set(true, forKey: "NotifyAchilat Chametz")
        defaults.set(true, forKey: "NotifyBiur Chametz")
        defaults.set(false, forKey: "NotifyChatzot")
        defaults.set(false, forKey: "NotifyMincha Gedolah")
        defaults.set(false, forKey: "NotifyMincha Ketana")
        defaults.set(false, forKey: "NotifyPlag HaMincha Yalkut Yosef")
        defaults.set(false, forKey: "NotifyPlag HaMincha Halacha Berurah")
        defaults.set(true, forKey: "NotifyCandle Lighting")
        defaults.set(true, forKey: "NotifySunset")
        defaults.set(true, forKey: "NotifyTzeit Hacochavim")
        defaults.set(true, forKey: "NotifyTzeit Hacochavim (Stringent)")
        defaults.set(true, forKey: "NotifyFast Ends")
        defaults.set(false, forKey: "NotifyShabbat Ends")
        defaults.set(false, forKey: "NotifyRabbeinu Tam")
        defaults.set(false, forKey: "NotifyChatzot Layla")
        
        defaults.set(-1, forKey: "Alot Hashachar")
        defaults.set(-1, forKey: "Talit And Tefilin")
        defaults.set(-1, forKey: "Sunrise")
        defaults.set(15, forKey: "Sof Zman Shma MGA")
        defaults.set(15, forKey: "Sof Zman Shma GRA")
        defaults.set(15, forKey: "Sof Zman Tefila")
        defaults.set(15, forKey: "Achilat Chametz")
        defaults.set(15, forKey: "Biur Chametz")
        defaults.set(20, forKey: "Chatzot")
        defaults.set(-1, forKey: "Mincha Gedolah")
        defaults.set(-1, forKey: "Mincha Ketana")
        defaults.set(-1, forKey: "Plag HaMincha Yalkut Yosef")
        defaults.set(-1, forKey: "Plag HaMincha Halacha Berurah")
        defaults.set(15, forKey: "Candle Lighting")
        defaults.set(15, forKey: "Sunset")
        defaults.set(15, forKey: "Tzeit Hacochavim")
        defaults.set(15, forKey: "Tzeit Hacochavim (Stringent)")
        defaults.set(15, forKey: "Fast Ends")
        defaults.set(-1, forKey: "Shabbat Ends")
        defaults.set(0, forKey: "Rabbeinu Tam")
        defaults.set(-1, forKey: "Chatzot Layla")
    }
    
    func getUserLocation() {
        let concurrentQueue = DispatchQueue(label: "mainApp", attributes: .concurrent)
        
        LocationManager.shared.getUserLocation {//4.4 fixed the location issue
            location in concurrentQueue.async { [self] in
                if location != nil {
                    lat = location!.coordinate.latitude
                    long = location!.coordinate.longitude
                    timezone = TimeZone.current.corrected()
                    recreateZmanimCalendar()
                    defaults.set(timezone.identifier, forKey: "timezone")
                    defaults.set(false, forKey: "useZipcode")
                    defaults.set(false, forKey: "useAdvanced")
                    LocationManager.shared.resolveLocationName(with: location!) { [self] locationName in
                        self.locationName = locationName ?? ""
                        resolveElevation()
                        recreateZmanimCalendar()
                        jewishCalendar = JewishCalendar(workingDate: Date(), timezone: timezone, inIsrael: defaults.bool(forKey: "inIsrael"), useModernHolidays: true)
                        GlobalStruct.jewishCalendar = jewishCalendar
                        setNextUpcomingZman()
                        updateZmanimList()
                        didLocationUpdate = true
                        NotificationManager.instance.requestAuthorization()
                        NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
                        sessionManager.sendMessage(self.getSettingsDictionary())
                    }
                } else {
                    print("location is nil")
                }
            }
        }
    }
    
    func getSettingsDictionary() -> [String : Any] {
        return ["useElevation" : defaults.bool(forKey: "useElevation"),
                "showSeconds" : defaults.bool(forKey: "showSeconds"),
                "inIsrael" : defaults.bool(forKey: "inIsrael"),
                "tekufaOpinion" : defaults.integer(forKey: "tekufaOpinion"),
                "LuachAmudeiHoraah" : defaults.bool(forKey: "LuachAmudeiHoraah"),
                "isZmanimInHebrew" : defaults.bool(forKey: "isZmanimInHebrew"),
                "isZmanimEnglishTranslated" : defaults.bool(forKey: "isZmanimEnglishTranslated"),
                "visibleSunriseTable\(locationName)\(jewishCalendar.getJewishYear())" : defaults.string(forKey: "visibleSunriseTable\(locationName)\(jewishCalendar.getJewishYear())") ?? "",
                "alwaysShowMishorSunrise" : defaults.bool(forKey: "alwaysShowMishorSunrise"),
                "showPreferredMisheyakirZman" : defaults.bool(forKey: "showPreferredMisheyakirZman"),
                "plagOpinion" : defaults.integer(forKey: "plagOpinion"),
                "candleLightingOffset" : defaults.integer(forKey: "candleLightingOffset"),
                "showWhenShabbatChagEnds" : defaults.bool(forKey: "showWhenShabbatChagEnds"),
                "showRegularWhenShabbatChagEnds" : defaults.bool(forKey: "showRegularWhenShabbatChagEnds"),
                "shabbatOffset" : defaults.integer(forKey: "shabbatOffset"),
                "endOfShabbatOpinion" : defaults.integer(forKey: "endOfShabbatOpinion"),
                "showRTWhenShabbatChagEnds" : defaults.bool(forKey: "showRTWhenShabbatChagEnds"),
                "overrideAHEndShabbatTime" : defaults.bool(forKey: "overrideAHEndShabbatTime"),
                "showTzeitLChumra" : defaults.bool(forKey: "showTzeitLChumra"),
                "alwaysShowRT" : defaults.bool(forKey: "alwaysShowRT"),
                "useZipcode" : defaults.string(forKey: "useZipcode") ?? "",
                "locationName" : defaults.string(forKey: "locationName") ?? "",
                "lat" : defaults.double(forKey: "lat"),
                "long" : defaults.double(forKey: "long"),
                "elevation" + locationName : defaults.double(forKey: "elevation" + locationName),
                "setElevationToLastKnownLocation" : defaults.bool(forKey: "setElevationToLastKnownLocation"),
                "lastKnownLocation" : defaults.string(forKey: "lastKnownLocation") ?? "",
                "timezone" : defaults.string(forKey: "timezone") ?? "",
                "useAdvanced" : defaults.bool(forKey: "useAdvanced"),
                "advancedLN" : defaults.string(forKey: "advancedLN") ?? "",
                "advancedLat" : defaults.double(forKey: "advancedLat"),
                "advancedLong" : defaults.double(forKey: "advancedLong"),
                "advancedTimezone" : defaults.string(forKey: "advancedTimezone") ?? "",
                "useLocation1" : defaults.bool(forKey: "useLocation1"),
                "useLocation2" : defaults.bool(forKey: "useLocation2"),
                "useLocation3" : defaults.bool(forKey: "useLocation3"),
                "useLocation4" : defaults.bool(forKey: "useLocation4"),
                "useLocation5" : defaults.bool(forKey: "useLocation5"),
                "location1" : defaults.string(forKey: "location1") ?? "",
                "location1Lat" : defaults.double(forKey: "location1Lat"),
                "location1Long" : defaults.double(forKey: "location1Long"),
                "location1Timezone" : defaults.string(forKey: "location1Timezone") ?? "",
                "location2" : defaults.string(forKey: "location2") ?? "",
                "location2Lat" : defaults.double(forKey: "location2Lat"),
                "location2Long" : defaults.double(forKey: "location2Long"),
                "location2Timezone" : defaults.string(forKey: "location2Timezone") ?? "",
                "location3" : defaults.string(forKey: "location3") ?? "",
                "location3Lat" : defaults.double(forKey: "location3Lat"),
                "location3Long" : defaults.double(forKey: "location3Long"),
                "location3Timezone" : defaults.string(forKey: "location3Timezone") ?? "",
                "location4" : defaults.string(forKey: "location4") ?? "",
                "location4Lat" : defaults.double(forKey: "location4Lat"),
                "location4Long" : defaults.double(forKey: "location4Long"),
                "location4Timezone" : defaults.string(forKey: "location4Timezone") ?? "",
                "location5" : defaults.string(forKey: "location5") ?? "",
                "location5Lat" : defaults.double(forKey: "location5Lat"),
                "location5Long" : defaults.double(forKey: "location5Long"),
                "location5Timezone" : defaults.string(forKey: "location5Timezone") ?? "",
        ]
    }
    
    func resolveElevation() {
        if self.defaults.object(forKey: "elevation" + self.locationName) != nil {//if we have been here before, use the elevation saved for this location
            if self.defaults.bool(forKey: "useElevation") {
                self.elevation = self.defaults.double(forKey: "elevation" + self.locationName)
            } else {
                self.elevation = 0
            }
        } else {//we have never been here before, get the elevation from online
            if self.defaults.bool(forKey: "useElevation") {
                self.getElevationFromOnline()
            } else {
                self.elevation = 0//undo any previous values
            }
        }
        if locationName.isEmpty {
            locationName = "Lat: " + String(lat) + " Long: " + String(long)
            if defaults.bool(forKey: "setElevationToLastKnownLocation") {
                self.elevation = self.defaults.double(forKey: "elevation" + (defaults.string(forKey: "lastKnownLocation") ?? ""))
            }
        }
    }
    
    func getElevationFromOnline() {
        var intArray: [Int] = []
        var e1:Int = 0
        var e2:Int = 0
        var e3:Int = 0
        let group = DispatchGroup()
        group.enter()
        let geocoder = LSGeoLookup(withUserID: "Elyahu41")
        geocoder.findElevationGtopo30(latitude: lat, longitude: long) {
            elevation in
            if let elevation = elevation {
                e1 = Int(truncating: elevation)
            }
            group.leave()
        }
        group.enter()
        geocoder.findElevationSRTM3(latitude: lat, longitude: long) {
            elevation in
            if let elevation = elevation {
                e2 = Int(truncating: elevation)
            }
            group.leave()
        }
        group.enter()
        geocoder.findElevationAstergdem(latitude: lat, longitude: long) {
            elevation in
            if let elevation = elevation {
                e3 = Int(truncating: elevation)
            }
            group.leave()
        }
        group.notify(queue: .main) {
            if e1 > 0 {
                intArray.append(e1)
            } else {
                e1 = 0
            }
            if e2 > 0 {
                intArray.append(e2)
            } else {
                e2 = 0
            }
            if e3 > 0 {
                intArray.append(e3)
            } else {
                e3 = 0
            }
            var count = Double(intArray.count)
            if count == 0 {
                count = 1 //edge case
            }
            let text = String(Double(e1 + e2 + e3) / Double(count))
            self.elevation = Double(text) ?? 0
            self.defaults.set(self.elevation, forKey: "elevation" + self.locationName)
            self.recreateZmanimCalendar()
            self.jewishCalendar = JewishCalendar(workingDate: Date(), timezone: self.timezone, inIsrael: self.defaults.bool(forKey: "inIsrael"), useModernHolidays: true)
            self.setNextUpcomingZman()
            self.updateZmanimList()
        }
    }
    
    func refreshTable() {
        if defaults.bool(forKey: "useAdvanced") {
            setLocation(defaultsLN: "advancedLN", defaultsLat: "advancedLat", defaultsLong: "advancedLong", defaultsTimezone: "advancedTimezone")
        } else if defaults.bool(forKey: "useLocation1") {
            setLocation(defaultsLN: "location1", defaultsLat: "location1Lat", defaultsLong: "location1Long", defaultsTimezone: "location1Timezone")
        } else if defaults.bool(forKey: "useLocation2") {
            setLocation(defaultsLN: "location2", defaultsLat: "location2Lat", defaultsLong: "location2Long", defaultsTimezone: "location2Timezone")
        } else if defaults.bool(forKey: "useLocation3") {
            setLocation(defaultsLN: "location3", defaultsLat: "location3Lat", defaultsLong: "location3Long", defaultsTimezone: "location3Timezone")
        } else if defaults.bool(forKey: "useLocation4") {
            setLocation(defaultsLN: "location4", defaultsLat: "location4Lat", defaultsLong: "location4Long", defaultsTimezone: "location4Timezone")
        } else if defaults.bool(forKey: "useLocation5") {
            setLocation(defaultsLN: "location5", defaultsLat: "location5Lat", defaultsLong: "location5Long", defaultsTimezone: "location5Timezone")
        } else if defaults.bool(forKey: "useZipcode") {
            setLocation(defaultsLN: "locationName", defaultsLat: "lat", defaultsLong: "long", defaultsTimezone: "timezone")
        } else {
            if defaults.bool(forKey: "isSetup") {
                getUserLocation()
            }
        }
        userChosenDate = Date()
        syncCalendarDates()
        updateZmanimList()
    }
    
    func setLocation(defaultsLN:String, defaultsLat:String, defaultsLong:String, defaultsTimezone:String) {
        locationName = defaults.string(forKey: defaultsLN) ?? ""
        lat = defaults.double(forKey: defaultsLat)
        long = defaults.double(forKey: defaultsLong)
        resolveElevation()
        timezone = TimeZone(identifier: defaults.string(forKey: defaultsTimezone) ?? TimeZone.current.identifier) ?? TimeZone.current
        recreateZmanimCalendar()
        jewishCalendar = JewishCalendar(workingDate: Date(), timezone: timezone, inIsrael: defaults.bool(forKey: "inIsrael"), useModernHolidays: true)
        GlobalStruct.jewishCalendar = jewishCalendar
        setNextUpcomingZman()
        updateZmanimList()
        NotificationManager.instance.requestAuthorization()
        NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
    }
    
    func syncOldDefaults() {
        let oldDefaults = UserDefaults.standard
        
        if oldDefaults.bool(forKey: "hasBeenSynced") {
            return
        }
        
        if oldDefaults.object(forKey: "isSetup") != nil {
            for (key, value) in oldDefaults.dictionaryRepresentation() {
                defaults.set(value, forKey: key)
            }
        }
        
        oldDefaults.setValue(true, forKey: "hasBeenSynced")
    }
    
    func getShabbatBannerText(isFirstTime:Bool) -> String {
        if isFirstTime {
            jewishCalendar.forward()
        }
        
        let isShabbat = jewishCalendar.getDayOfWeek() == 7
        
        var bannerText = ""
        
        switch jewishCalendar.getYomTovIndex() {
        case JewishCalendar.PESACH:
            bannerText += "PESACH".localized()
            if isShabbat {
                bannerText += "/SHABBAT".localized()
            }
            bannerText += " MODE".localized() + "          "
        case JewishCalendar.SHAVUOS:
            bannerText += "SHAVUOT".localized()
            if isShabbat {
                bannerText += "/SHABBAT".localized()
            }
            bannerText += " MODE".localized() + "          "
        case JewishCalendar.SUCCOS:
            bannerText += "SUCCOT"
            if isShabbat {
                bannerText += "/SHABBAT".localized()
            }
            bannerText += " MODE".localized() + "          "
        case JewishCalendar.SHEMINI_ATZERES:
            bannerText += "SHEMINI ATZERET".localized()
            if isShabbat {
                bannerText += "/SHABBAT".localized()
            }
            bannerText += " MODE".localized() + "          "
        case JewishCalendar.SIMCHAS_TORAH:
            bannerText += "SIMCHAT TORAH".localized()
            if isShabbat {
                bannerText += "/SHABBAT".localized()
            }
            bannerText += " MODE".localized() + "          "
        case JewishCalendar.ROSH_HASHANA:
            bannerText += "ROSH HASHANA".localized()
            if isShabbat {
                bannerText += "/SHABBAT".localized()
            }
            bannerText += " MODE".localized() + "          "
        case JewishCalendar.YOM_KIPPUR:
            bannerText += "YOM KIPPUR".localized()
            if isShabbat {
                bannerText += "/SHABBAT".localized()
            }
            bannerText += " MODE".localized() + "          "
        default:
            bannerText = "SHABBAT MODE          SHABBAT MODE          SHABBAT MODE           SHABBAT MODE          SHABBAT MODE          SHABBAT MODE          SHABBAT MODE          SHABBAT MODE          SHABBAT MODE          SHABBAT MODE          SHABBAT MODE          SHABBAT MODE          ".localized()
        }
                
        if isFirstTime {
            jewishCalendar.back()
        }
        
        return bannerText
    }
    
    func getShabbatBannerColors(isFirstTime:Bool, textOnly: Bool) -> Color {
        if isFirstTime {
            jewishCalendar.forward()
        }
                
        var bannerBGColor = Color.black
        var bannerTextColor = Color.white
        
        switch jewishCalendar.getYomTovIndex() {
        case JewishCalendar.PESACH:
            bannerBGColor = Color("light_yellow")
            bannerTextColor = .black
        case JewishCalendar.SHAVUOS:
            bannerBGColor = .blue
            bannerTextColor = .white
        case JewishCalendar.SUCCOS:
            bannerBGColor = .green
            bannerTextColor = .black
        case JewishCalendar.SHEMINI_ATZERES:
            bannerBGColor = .green
            bannerTextColor = .black
        case JewishCalendar.SIMCHAS_TORAH:
            bannerBGColor = .green
            bannerTextColor = .black
        case JewishCalendar.ROSH_HASHANA:
            bannerBGColor = .red
            bannerTextColor = .white
        case JewishCalendar.YOM_KIPPUR:
            bannerBGColor = .white
            bannerTextColor = .black
        default:
            bannerBGColor = Color(.darkBlue)
            bannerTextColor = .white
        }
        
        if isFirstTime {
            jewishCalendar.back()
        }
        
        if textOnly {
            return bannerTextColor
        } else {
            return bannerBGColor
        }
    }
    
    func checkIfUserIsInIsrael() {
        if defaults.bool(forKey: "neverAskInIsrael") {
            return
        }
        if !defaults.bool(forKey: "inIsrael") && timezone.corrected().identifier == "Asia/Jerusalem" {
            showInIsraelAlert = true
        }
        
        if defaults.bool(forKey: "inIsrael") && timezone.corrected().identifier != "Asia/Jerusalem" {
            showOutOfIsraelAlert = true
        }
    }
    
    func checkIfTablesNeedToBeUpdated() {
        if defaults.object(forKey: "chaitablesLink" + locationName) == nil || askedToUpdateTablesAlready {
            return
        }
        let chaitables = ChaiTables(locationName: locationName, jewishCalendar: jewishCalendar, defaults: defaults)
        if chaitables.getVisibleSurise(forDate: userChosenDate) == nil && chaitables.useVisibleSunrise {
            if chaitables.chaitableVisibleSunrise == "" {
                showTablesNeedToBeUpdatedAlert = true
                askedToUpdateTablesAlready = true
            } else {// There is an issue, because there is something in the string that is not formatting properly
                print(chaitables.chaitableVisibleSunrise)
                showChaitablesErrorAlert = true
            }
        }
    }
    
    func ZmanimMenu() -> some View {
        Menu {
            Button(action: {
                withAnimation {
                    isFirstTimeForShabbatBanner = true
                    shabbatMode.toggle()
                    shabbatMode ? endShabbatMode() : startShabbatMode()
                }
            }) {
                if shabbatMode {
                    Label("Shabbat/Chag Mode", systemImage: "checkmark")
                } else {
                    Text("Shabbat/Chag Mode")
                }
            }
//            Button(action: {
//                simpleList.toggle()
//                defaults.set(simpleList, forKey: "useSimpleList")
//                updateZmanimList()
//            }) {
//                if simpleList {
//                    Label("Use Simple List", systemImage: "checkmark")
//                } else {
//                    Text("Use Simple List")
//                }
//            }
            Button(action: {
                useElevation.toggle()
                defaults.set(useElevation, forKey: "useElevation")
                GlobalStruct.useElevation = useElevation
                resolveElevation()
                recreateZmanimCalendar()
                setNextUpcomingZman()
                updateZmanimList()
            }) {
                if useElevation {
                    Label("Use Elevation", systemImage: "checkmark")
                } else {
                    Text("Use Elevation")
                }
            }
            Button("Netz Countdown") {
                nextView = .netz
                showNextView = true
            }
            Button("Molad Calculator") {
                nextView = .molad
                showNextView = true
            }
            Button("Jerusalem Direction") {
                nextView = .jerDirection
                showNextView = true
            }
            Divider()
            Button("Setup") {
                GetUserLocationView.loneView = false
                nextView = .setup
                showNextView = true
            }
            Button("Search For A Place") {
                GetUserLocationView.loneView = true
                nextView = .searchForPlace
                showNextView = true
            }
            Button("Website") {
                if let url = URL(string: "https://royzmanim.com/") {
                    UIApplication.shared.open(url)
                }
            }
            Button("Settings") {
                nextView = .settings
                showNextView = true
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3)
                .padding(10)
                .background(alignment: .center) {
                    Color.gray.opacity(0.2)
                }
                .clipShape(Circle())
        }
    }
    
    func alerts(view: any View) -> some View {
        let result = view.overlay {
            ZStack {
                ZStack { }
                    .alert("Visible Sunrise Data Error", isPresented: $showChaitablesErrorAlert) {
                        Button("Do not use visible sunrise for this location") {
                            defaults.set(true, forKey: "useMishorSunrise".appending(GlobalStruct.geoLocation.locationName))
                        }
                        Button("Dismiss".localized(), role: .cancel) {}
                    } message: {
                        Text("An error occurred while trying to read the data that was retrieved from chaitables.com for this location. A table was expected but this was found instead:\n\n"
                            .appending(ChaiTables(locationName: locationName, jewishCalendar: jewishCalendar, defaults: defaults).chaitableVisibleSunrise
                                .appending("\n\nPlease try to download the table again, or choose to not use visible sunrise for this location.")))
                    }
                ZStack { }
                    .alert("Location Issues".localized(), isPresented: $showLocationServicesDisabledAlert) {
                        Button("Search For A Place".localized()) {
                            GetUserLocationView.loneView = true
                            nextView = .searchForPlace
                            showNextView = true
                        }
                        Button("Dismiss".localized(), role: .cancel) {}
                    } message: {
                        Text("The application is having issues requesting your device's location. Location Services might be disabled or parental controls may be restricting the application. If you would like to use a zipcode/address instead, choose the \"Search For A Place\" option.".localized())
                    }
                ZStack { }
                    .alert("Chaitables out of date".localized(), isPresented: $showTablesNeedToBeUpdatedAlert) {
                        Button("Yes".localized()) {
                            let oldLink = self.defaults.string(forKey: "chaitablesLink" + self.locationName)
                            let hebrewYear = String(self.jewishCalendar.getJewishYear())
                            let pattern = "&cgi_yrheb=\\d{4}"
                            let newLink = oldLink?.replacingOccurrences(of: pattern, with: "&cgi_yrheb=" + hebrewYear, options: .regularExpression)
                            let scraper = ChaiTablesScraper(link: newLink ?? "", locationName: self.locationName, jewishYear: self.jewishCalendar.getJewishYear(), defaults: self.defaults)
                            scraper.scrape {
                                self.updateZmanimList()
                            }
                        }
                        Button("No".localized()) {}
                    } message: {
                        Text("The current hebrew year is out of scope for the visible sunrise times that were downloaded from Chaitables. Would you like to download the tables for this hebrew year?".localized())
                    }
                ZStack { }
                    .alert("Are you in Israel now?".localized(), isPresented: $showInIsraelAlert) {
                        Button("Yes".localized()) {
                            self.defaults.set(true, forKey: "inIsrael")
                            self.defaults.set(false, forKey: "LuachAmudeiHoraah")
                            self.defaults.set(true, forKey: "useElevation")
                            self.jewishCalendar.inIsrael = true
                            GlobalStruct.jewishCalendar.inIsrael = self.jewishCalendar.inIsrael
                            GlobalStruct.useElevation = true
                            self.resolveElevation()
                            self.recreateZmanimCalendar()
                            self.updateZmanimList()
                        }
                        Button("Dismiss".localized(), role: .cancel) {}
                        Button("Do Not Ask Again".localized()) {
                            self.defaults.set(true, forKey: "neverAskInIsrael")
                        }
                    } message: {
                        Text("If you are in Israel, please confirm below.".localized())
                    }
                ZStack { }
                    .alert("Have you left Israel?".localized(), isPresented: $showOutOfIsraelAlert) {
                        Button("Yes".localized()) {
                            self.defaults.set(false, forKey: "inIsrael")
                            self.jewishCalendar.inIsrael = false
                            GlobalStruct.jewishCalendar.inIsrael = false
                            self.defaults.set(true, forKey: "LuachAmudeiHoraah")
                            self.defaults.set(false, forKey: "useElevation")
                            GlobalStruct.useElevation = false
                            self.resolveElevation()
                            self.recreateZmanimCalendar()
                            self.updateZmanimList()
                        }
                        Button("Dismiss".localized(), role: .cancel) {}
                        Button("Do Not Ask Again".localized()) {
                            self.defaults.set(true, forKey: "neverAskInIsrael")
                        }
                    } message: {
                        Text("If you have left Israel, please confirm below.".localized())
                    }
                ZStack { }
                    .alert("New version".localized(), isPresented: $showAppUpdateAlert) {
                        Button("Update".localized()) {
                            guard let url = URL(string: appStoreURL ?? "") else {
                                return
                            }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                        Button("Not now".localized(), role: .cancel) {}
                    } message: {
                        Text("A new version of our app is available on the App Store. Update now!".localized())
                    }
                ZStack { }
                    .confirmationDialog("Location info for: " + locationName, isPresented: $showLocationInfoAlert) {
                        Button("Change Location".localized()) {
                            GetUserLocationView.loneView = true
                            nextView = .searchForPlace
                            showNextView = true
                        }
                        Button("Set Elevation".localized()) {
                            nextView = .setupElevation
                            showNextView = true
                        }
                        Button("Share".localized()) {
                            showShareSheet = true
                        }
                    } message: {
                        Text("Location".localized().appending(": \(locationName)\n")
                            .appending("Latitude".localized()).appending(": \(lat)\n")
                            .appending("Longitude".localized()).appending(": \(long)\n")
                            .appending("Elevation".localized()).appending(": \(elevation) ").appending("meters".localized()).appending("\n")
                            .appending("Time Zone".localized()).appending(": \(timezone.corrected().identifier)\n")
                            .appending("Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0")"))
                    }
                ZStack {
                    if datePickerIsVisible {
                        VStack {
                            DatePicker("", selection: $userChosenDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.graphical)
                                .onChange(of: userChosenDate) { newValue in
                                    syncCalendarDates()
                                    updateZmanimList()
                                    checkIfTablesNeedToBeUpdated()
                                }
                            HStack {
                                Button {
                                    datePickerIsVisible.toggle()
                                    hebrewDatePickerIsVisible.toggle()
                                } label: {
                                    Text("Change Calendar")
                                }
                                Spacer()
                                Button {
                                    datePickerIsVisible.toggle()
                                } label: {
                                    Text("Done")
                                }
                            }.padding()
                        }.frame(width: 320)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                                    .shadow(radius: 1)
                            }
                    }
                    if hebrewDatePickerIsVisible {
                        VStack {
                            DatePicker("", selection: $userChosenDate, displayedComponents: .date)
                                .labelsHidden()
                                .datePickerStyle(.graphical)
                                .environment(\.locale, Locale(identifier: "he"))
                                .environment(\.calendar, Calendar(identifier: .hebrew))
                                .onChange(of: userChosenDate) { newValue in
                                    syncCalendarDates()
                                    updateZmanimList()
                                    checkIfTablesNeedToBeUpdated()
                                }
                            HStack {
                                Button {
                                    hebrewDatePickerIsVisible.toggle()
                                    datePickerIsVisible.toggle()
                                } label: {
                                    Text("Change Calendar")
                                }
                                Spacer()
                                Button {
                                    hebrewDatePickerIsVisible.toggle()
                                } label: {
                                    Text("Done")
                                }
                            }.padding()
                        }.frame(width: 320)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .foregroundColor(Color(UIColor.secondarySystemBackground))
                                    .shadow(radius: 1)
                            }
                    }
                }
            }
        }
        return AnyView(result)
    }
    
    var simpleListView: some View {
        ScrollViewReader { scrollViewProxy in
            List(zmanimList, id: \.self) { zmanEntry in
                Button {
                    if shabbatMode || !defaults.bool(forKey: "showZmanDialogs") {
                        return //do not show the dialogs
                    }
                    if zmanimList.first?.title == zmanEntry.title {
                        showLocationInfoAlert = true
                    }
                    if zmanimList.count > 1 && zmanEntry.title == zmanimList[1].title {
                        datePickerIsVisible.toggle()
                    }
                    if zmanEntry.title == ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")).getTalitTefilinString() && !zmanimList.contains(where: { $0.is66MisheyakirZman == true }) {
                        withAnimation {
                            updateZmanimList(add66Misheyakir: true)
                        }
                    } else {
                        if !ZmanimAlertInfoHolder(title: zmanEntry.title, mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")).getFullTitle().isEmpty {
                            selectedZman = zmanEntry
                            showZmanAlert = true
                        }
                    }
                } label: {
                    if !zmanEntry.isZman {
                        HStack {
                            Text("").frame(maxWidth: 0)
                            Spacer()
                            if !zmanimList.isEmpty && zmanEntry.title == zmanimList[2].title {
                                Text(zmanEntry.title)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            } else {
                                Text(zmanEntry.title)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                            Spacer()
                        }
                    } else {
                        zmanEntryRow(zmanEntry)
                    }
                }
                .id(zmanEntry.title)
                .confirmationDialog(ZmanimAlertInfoHolder(title: selectedZman.title, mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")).getFullTitle(), isPresented: $showZmanAlert, titleVisibility: .visible) {
                    if selectedZman.title.contains(ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")).getHaNetzString()) {
                        Button("Setup Visible Sunrise") {
                            nextView = .setupVisibleSunrise
                            showNextView = true
                        }
                    }
                    if selectedZman.title.contains("Birkat Halevana") || selectedZman.title.contains("ברכת הלבנה") {
                        Button("Show Full Text") {
                            GlobalStruct.chosenPrayer = "Birchat Halevana"
                            nextView = .siddur
                            showNextView = true
                        }
                    }
                    if selectedZman.title.contains("day of Omer") || selectedZman.title.contains("ימים לעומר") {
                        Button("Show Full Text") {
                            GlobalStruct.chosenPrayer = "Sefirat HaOmer"
                            nextView = .siddur
                            showNextView = true
                        }
                    }
                    if #available(iOS 16.2, *) {
                        if selectedZman.isZman
                            && (selectedZman.zman?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 > Date().timeIntervalSince1970) //after now
                            && selectedZman.zman?.timeIntervalSinceNow ?? Date().timeIntervalSinceNow < 28800 {// not after 8 hours
                            Button("Keep track of this zman with a Live Activity?") {
                                let attributes = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes(zmanName: selectedZman.title)
                                let contentState = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes.TimerStatus(endTime: selectedZman.zman ?? Date())
                                _ = try? Activity<Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes>.request(attributes: attributes, content: ActivityContent.init(state: contentState, staleDate: nil), pushType: nil)
                            }
                        }
                    }
                    Button("Dismiss", role: .cancel) { }
                } message: {
                    Text(ZmanimAlertInfoHolder(title: selectedZman.title, mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")).getFullMessage().replacingOccurrences(of: "%c", with: String(zmanimCalendar.candleLightingOffset)))
                }.textCase(nil)
            }
            .listStyle(.plain)
            .scrollOffsetID("Scroller")
            .refreshable {
                refreshTable()
            }
            .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .global).onEnded { value in
                let horizontalAmount = value.translation.width
                let verticalAmount = value.translation.height
                
                if abs(horizontalAmount) > abs(verticalAmount) {
                    if horizontalAmount < 0 {
                        updateDate(86400)
                    } else {
                        updateDate(-86400)
                    }
                }
            })
            .onChange(of: scrollViewOffset) { newValue in
                if shabbatMode {
                    DispatchQueue.main.async {
                        scrollOffsetProxy.scrollTo(newValue, withAnimation: false)
                    }
                }
            }
            .onChange(of: scrollToTop) { newValue in
                DispatchQueue.main.async {
                    scrollViewProxy.scrollTo(zmanimList.first?.title, anchor: .bottom)
                }
            }
            .onReceive(timer) { _ in
                guard shabbatMode else { return }
                
                let topOfView = ScrollOffset.proxy(.top, id: "Scroller")
                let bottomOfView = ScrollOffset.proxy(.bottom, id: "Scroller")
                
                if scrollViewOffset ==  CGFloat(1000) {
                    scrollViewOffset = bottomOfView.offset
                }
                                                                
                if scrollDirection == 1 {
                    scrollViewOffset += 0.25
                } else {
                    scrollViewOffset -= 0.25
                }

                // Reverse direction at bounds
                if topOfView.offset == 0 {
                    scrollDirection = -1
                } else if bottomOfView.offset == 0 {
                    scrollDirection = 1
                }
            }
            .onReceive(timerForShabbatMode) { _ in
                guard shabbatMode else { return }
                scheduleTimer()
                isFirstTimeForShabbatBanner = false
                refreshTable()
            }
        }
    }
    
    fileprivate func zmanEntryRow(_ zmanEntry: ZmanListEntry) -> some View {
        return HStack {
            if defaults.bool(forKey: "isZmanimInHebrew") && !Locale.isHebrewLocale() {
                if zmanEntry.isRTZman {
                    Text(zmanEntry.zman == nil ? "XX:XX" : dateFormatterForRT.string(from: zmanEntry.zman!))
                        .font(.system(size: 20, weight: .regular))
                } else {
                    Text(zmanEntry.zman == nil ? "XX:XX" : dateFormatterForZmanim.string(from: zmanEntry.zman!))
                        .font(.system(size: zmanEntry.is66MisheyakirZman ? 18 : 20, weight: .regular))
                }
                if zmanEntry.zman == nextUpcomingZman {
                    Image(systemName: "arrowtriangle.backward.fill")
                }
                Spacer()
                if zmanEntry.is66MisheyakirZman {
                    Text(zmanEntry.title)
                        .font(.system(size: 18, weight: .regular))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                } else {
                    if zmanEntry.title.contains(ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew")).getHalachaBerurahString()) || zmanEntry.title.contains(ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew")).getYalkutYosefString()) {
                        PelagZmanView(title: zmanEntry.title)
                    } else {
                        Text(zmanEntry.title)
                            .font(.system(size: 20, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
            } else {
                if zmanEntry.is66MisheyakirZman {
                    Text(zmanEntry.title)
                        .font(.system(size: 18, weight: .regular))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                } else {
                    if zmanEntry.title.contains(ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew")).getHalachaBerurahString()) || zmanEntry.title.contains(ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew")).getYalkutYosefString()) {
                        PelagZmanView(title: zmanEntry.title)
                    } else {
                        Text(zmanEntry.title)
                            .font(.system(size: 20, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
                Spacer()
                if zmanEntry.zman == nextUpcomingZman {
                    Image(systemName: "arrowtriangle.forward.fill")
                }
                if zmanEntry.isRTZman {
                    Text(zmanEntry.zman == nil ? "XX:XX" : dateFormatterForRT.string(from: zmanEntry.zman!)).font(.system(size: 20, weight: .regular))
                } else {
                    Text(zmanEntry.zman == nil ? "XX:XX" : dateFormatterForZmanim.string(from: zmanEntry.zman!)).font(.system(size: zmanEntry.is66MisheyakirZman ? 18 : 20, weight: .regular))
                }
            }
        }
    }
    
    struct PelagZmanView: View {
        let title: String
        
        var body: some View {
            let (mainTitle, parenTitle) = splitTitle(title)
            
            HStack(spacing: 2) {
                Text(mainTitle)
                    .font(.system(size: 20, weight: .bold))
                    .lineLimit(1)
                    .layoutPriority(1) // prioritize full title
                
                if !parenTitle.isEmpty {
                    Text(parenTitle)
                        .font(.system(size: 20, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.4) // only shrink the parens
                        .layoutPriority(0) // lower priority so it shrinks first
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .environment(\.layoutDirection, isHebrew(text: title) ? .rightToLeft : .leftToRight)
        }
        
        private func splitTitle(_ full: String) -> (String, String) {
            let pattern = #"^(.*?)\s*(\([^)]*\))?$"#
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: full, range: NSRange(full.startIndex..., in: full)) else {
                return (full, "")
            }
            
            let main = Range(match.range(at: 1), in: full).map { String(full[$0]) } ?? full
            let paren = Range(match.range(at: 2), in: full).map { String(full[$0]) } ?? ""
            
            return (main, paren)
        }
        
        private func isHebrew(text: String) -> Bool {
            return text.range(of: #"[\u0590-\u05FF]"#, options: .regularExpression) != nil
        }
    }

    var scrollView: some View {
        VStack {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    HStack {
                        VStack(spacing: 10) {
                            Color.clear.frame(height: 1).id("top") // this as a scroll anchor
                            if Calendar.current.isDateInToday(userChosenDate) {
                                Text(formatDate(format: "EEEE")).fontWeight(.heavy).foregroundStyle(Color.red)
                            } else {
                                Text(formatDate(format: "EEEE")).bold().foregroundStyle(Color.red)
                            }
                            Divider()
                            HStack {
                                VStack {
                                    Text(formatDate(using: Calendar(identifier: .hebrew), format: "MMM")).bold()
                                    Text(String(jewishCalendar.getJewishDayOfMonth())).font(.largeTitle)
                                    Text(String(jewishCalendar.getJewishYear()))
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                
                                Divider()
                                
                                VStack {
                                    Text(formatDate(format: "MMM")).bold()
                                    Text(String(Calendar.current.dateComponents([.day], from: GlobalStruct.userChosenDate).day ?? 1)).font(.largeTitle)
                                    Text(String(Calendar.current.dateComponents([.year], from: GlobalStruct.userChosenDate).year ?? 1))
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 0)
                        .padding(.bottom, nil)
                        .background(Color(.systemBackground))
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 26))
                        .onTapGesture {
                            if datePickerIsVisible {
                                withAnimation {
                                    datePickerIsVisible.toggle()
                                }
                            }
                            if hebrewDatePickerIsVisible {
                                withAnimation {
                                    hebrewDatePickerIsVisible.toggle()
                                }
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text(locationName.isEmpty ? "Updating...".localized() : locationName).fontWeight(.heavy).padding(.bottom, 5)
                                .onTapGesture {
                                    showLocationInfoAlert = true
                                }
                            Text(jewishCalendar.getThisWeeksParasha()).fontWeight(.heavy).foregroundStyle(Color.gray)
                            HStack(spacing: 5) {
                                Image(systemName: "star")
                                    .frame(width: 20).hidden()
                                Text(jewishCalendar.getSpecialDay(addOmer: false))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    VStack {
                        if jewishCalendar.tomorrow().isAssurBemelacha() || jewishCalendar.isAssurBemelacha() {
                            Text(getShabbatStartEndsAsString())
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.secondary)
                        }
                        if !jewishCalendar.tomorrow().isYomKippur() || !jewishCalendar.isYomKippur() {
                            if jewishCalendar.tomorrow().isTaanis() {
                                Text(jewishCalendar.tomorrow().yomTovAsString())
                                Text(getFastStartTime())
                                Text(getFastEndTime())
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color.secondary)
                            } else if jewishCalendar.isTaanis() {
                                Text(jewishCalendar.yomTovAsString())
                                Text(getFastStartTime())
                                Text(getFastEndTime())
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color.secondary)
                            }
                        }
                        if !jewishCalendar.getBirchatLevanaStatus().isEmpty {
                            Text(jewishCalendar.getBirchatLevanaStatus())
                            Text(getMoonRiseSet(isRise: true))
                            Text(getMoonRiseSet(isRise: false))
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.secondary)
                        }
                        if doesTekufaOccurToday() {
                            Text(jewishCalendar.getTekufaName())
                            Text("Do not drink ....")
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.secondary)
                        }
                        Divider()
                        ForEach(zmanimList, id: \.self) { zmanEntry in
                            if zmanEntry.isZman {
                                zmanEntryRow(zmanEntry)
                                    .padding(.leading).padding(.trailing)
                                    .onTapGesture {
                                        if shabbatMode || !defaults.bool(forKey: "showZmanDialogs") {
                                            return//do not show the dialogs
                                        }
                                        if zmanEntry.title == ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")).getTalitTefilinString() && !zmanimList.contains(where: { $0.is66MisheyakirZman == true }) {
                                            withAnimation {
                                                updateZmanimList(add66Misheyakir: true)
                                            }
                                        } else {
                                            selectedZman = zmanEntry
                                            showZmanAlert = true
                                        }
                                    }
                                    .confirmationDialog(ZmanimAlertInfoHolder(title: selectedZman.title, mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")).getFullTitle(), isPresented: $showZmanAlert, titleVisibility: .visible) {
                                        if selectedZman.title.contains(ZmanimTimeNames(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")).getHaNetzString()) {
                                            Button("Setup Visible Sunrise") {
                                                nextView = .setupVisibleSunrise
                                                showNextView = true
                                            }
                                        }
                                        if selectedZman.title.contains("Birkat Halevana") || selectedZman.title.contains("ברכת הלבנה") {
                                            Button("Show Full Text") {
                                                GlobalStruct.chosenPrayer = "Birchat Halevana"
                                                nextView = .siddur
                                                showNextView = true
                                            }
                                        }
                                        if selectedZman.title.contains("day of Omer") || selectedZman.title.contains("ימים לעומר") {
                                            Button("Show Full Text") {
                                                GlobalStruct.chosenPrayer = "Sefirat HaOmer"
                                                nextView = .siddur
                                                showNextView = true
                                            }
                                        }
                                        if #available(iOS 16.2, *) {
                                            if selectedZman.isZman
                                                && (selectedZman.zman?.timeIntervalSince1970 ?? Date().timeIntervalSince1970 > Date().timeIntervalSince1970) //after now
                                                && selectedZman.zman?.timeIntervalSinceNow ?? Date().timeIntervalSinceNow < 28800 {// not after 8 hours
                                                Button("Keep track of this zman with a Live Activity?") {
                                                    let attributes = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes(zmanName: selectedZman.title)
                                                    let contentState = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes.TimerStatus(endTime: selectedZman.zman ?? Date())
                                                    _ = try? Activity<Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes>.request(attributes: attributes, content: ActivityContent.init(state: contentState, staleDate: nil), pushType: nil)
                                                }
                                            }
                                        }
                                        Button("Dismiss", role: .cancel) { }
                                    } message: {
                                        Text(ZmanimAlertInfoHolder(title: selectedZman.title, mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated")).getFullMessage().replacingOccurrences(of: "%c", with: String(zmanimCalendar.candleLightingOffset)))
                                    }.textCase(nil)
                                Divider()
                            }
                        }
                        Text(jewishCalendar.getTachanun())
                        Text(jewishCalendar.getIsUlChaparatPeshaSaid())
                        Text(jewishCalendar.getIsMashivHaruchOrMoridHatalSaid()).padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Takes up all remaining space
                    .background(Color(.systemBackground))
                }
                .background(Color(uiColor: .systemGray6))
                .offset(y: scrollViewOffset)
                .refreshable {
                    refreshTable()
                }
                .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .global).onEnded { value in
                    let horizontalAmount = value.translation.width
                    let verticalAmount = value.translation.height
                    
                    if abs(horizontalAmount) > abs(verticalAmount) {
                        if horizontalAmount < 0 {
                            updateDate(86400)
                        } else {
                            updateDate(-86400)
                        }
                    }
                })
                .onChange(of: scrollToTop) { newValue in
                    DispatchQueue.main.async {
                        scrollViewProxy.scrollTo("top", anchor: .bottom)// use the anchor
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // Keep it compact
            }
        }
    }
    
    fileprivate func updateDate(_ seconds: TimeInterval) {
        userChosenDate = userChosenDate.advanced(by: seconds)
        syncCalendarDates()
        updateZmanimList()
        checkIfTablesNeedToBeUpdated()
        scrollToTop.toggle()
    }
    
    var body: some View {
        if shabbatMode && !isBannerHidden {
            MarqueeText(
                text: getShabbatBannerText(isFirstTime: isFirstTimeForShabbatBanner) + getShabbatBannerText(isFirstTime: isFirstTimeForShabbatBanner) + getShabbatBannerText(isFirstTime: isFirstTimeForShabbatBanner),
                font: UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: .bold),
                leftFade: 0,
                rightFade: 0,
                startDelay: 0,
                foregroundColor: getShabbatBannerColors(isFirstTime: isFirstTimeForShabbatBanner, textOnly: true),
                backgroundColor: getShabbatBannerColors(isFirstTime: isFirstTimeForShabbatBanner, textOnly: false)
            )
            .onTapGesture {
                isBannerHidden = true
            }
        }
        if #available(iOS 16.0, *) {
            alerts(view: simpleList ? simpleListView : scrollView)
                .scrollDisabled(shabbatMode)
        } else {
            alerts(view: simpleList ? simpleListView : scrollView)
        }
        HStack {
            Button {
                updateDate(-86400)
            } label: {
                Image(systemName: "arrowtriangle.backward.fill").resizable().scaledToFit().frame(width: 18, height: 18)
            }
            Spacer()
            Button {
                withAnimation(.easeInOut) {
                    datePickerIsVisible.toggle()
                }
            } label: {
                Image(systemName: "calendar").resizable().scaledToFit().frame(width: 26, height: 26)
            }
            Spacer()
            Button {
                updateDate(86400)
            } label: {
                Image(systemName: "arrowtriangle.forward.fill").resizable().scaledToFit().frame(width: 18, height: 18)
            }
        }
        .padding(.init(top: 2, leading: 0, bottom: 8, trailing: 0))
        .sheet(isPresented: $showShareSheet) {
            let image = UIImage(named: "AppIcon")
            let textToShare = "Find all the Zmanim on Zmanei Yosef".localized()
            
            if let myWebsite = URL(string: "https://royzmanim.com/calendar?locationName=\(locationName)&lat=\(lat)&long=\(long)&elevation=\(elevation)&timeZone=\(timezone.identifier)") {
                ShareSheet(items: [textToShare, myWebsite, image ?? UIImage(systemName: "square.and.arrow.up") as Any])
            }
        }
        .disabled(shabbatMode)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ZmanimMenu()
            }
        }
        .onReceive(timerForShabbatMode) { _ in
            refreshTable()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("elevation"))) { notification in
            if let value = notification.object as? String,
               let doubleValue = Double(value) {
                elevation = doubleValue
                defaults.set(elevation, forKey: "elevation" + locationName)
                recreateZmanimCalendar()
                setNextUpcomingZman()
                updateZmanimList()
            }
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
            if !defaults.bool(forKey: "isSetup") {
                defaults.set(true, forKey: "showZmanDialogs")
                setNotificationsDefaults()
            }
            if !defaults.bool(forKey: "massUpdateCheck") {// since version 6.4, we need to move everyone to AH mode if they are outside of Israel. This should eventually be removed, but far into the future
                if !defaults.bool(forKey: "inIsrael") {
                    defaults.set(true, forKey: "LuachAmudeiHoraah")
                    defaults.set(false, forKey: "useElevation")
                }
                defaults.set(true, forKey: "massUpdateCheck")// do not check again
            }
            GlobalStruct.useElevation = defaults.bool(forKey: "useElevation")
            CheckUpdate.shared.showUpdate(withConfirmation: true, isForSwiftUI: true) { needsUpdate, appURL in
                appStoreURL = appURL
                showAppUpdateAlert = needsUpdate
            }
            dateFormatterForZmanim.dateFormat = (Locale.isHebrewLocale() ? "H" : "h") + ":mm" + (defaults.bool(forKey: "showSeconds") ? ":ss" : "") + (Locale.isHebrewLocale() ? "" : " aa")
            dateFormatterForRT.dateFormat = (Locale.isHebrewLocale() ? "H" : "h") + ":mm" + (defaults.bool(forKey: "roundUpRT") ? "" : ":ss") + (Locale.isHebrewLocale() ? "" : " aa")
            syncOldDefaults()
            userChosenDate = GlobalStruct.userChosenDate
            syncCalendarDates()
            //simpleList = defaults.bool(forKey: "useSimpleList")
            simpleList = true// temp
            if !defaults.bool(forKey: "isSetup") {
                nextView = .setup
                showNextView = true
            } else { //not first run
                if defaults.bool(forKey: "useAdvanced") {
                    setLocation(defaultsLN: "advancedLN", defaultsLat: "advancedLat", defaultsLong: "advancedLong", defaultsTimezone: "advancedTimezone")
                } else if defaults.bool(forKey: "useLocation1") {
                    setLocation(defaultsLN: "location1", defaultsLat: "location1Lat", defaultsLong: "location1Long", defaultsTimezone: "location1Timezone")
                } else if defaults.bool(forKey: "useLocation2") {
                    setLocation(defaultsLN: "location2", defaultsLat: "location2Lat", defaultsLong: "location2Long", defaultsTimezone: "location2Timezone")
                } else if defaults.bool(forKey: "useLocation3") {
                    setLocation(defaultsLN: "location3", defaultsLat: "location3Lat", defaultsLong: "location3Long", defaultsTimezone: "location3Timezone")
                } else if defaults.bool(forKey: "useLocation4") {
                    setLocation(defaultsLN: "location4", defaultsLat: "location4Lat", defaultsLong: "location4Long", defaultsTimezone: "location4Timezone")
                } else if defaults.bool(forKey: "useLocation5") {
                    setLocation(defaultsLN: "location5", defaultsLat: "location5Lat", defaultsLong: "location5Long", defaultsTimezone: "location5Timezone")
                } else if defaults.bool(forKey: "useZipcode") {
                    setLocation(defaultsLN: "locationName", defaultsLat: "lat", defaultsLong: "long", defaultsTimezone: "timezone")
                } else {
                    DispatchQueue.global().async {
                        if CLLocationManager.locationServicesEnabled() {
                            let locationManager = CLLocationManager()
                            switch locationManager.authorizationStatus {
                            case .restricted, .denied:
                                DispatchQueue.main.async {
                                    showLocationServicesDisabledAlert = true
                                }
                                print("No access")
                                break
                            case .authorizedAlways, .authorizedWhenInUse:
                                //self.getUserLocation() this does not work for some reason. I assume it is because it works on another thread
                                break
                            case .notDetermined:
                                break
                            @unknown default:
                                break
                            }
                        } else {
                            showLocationServicesDisabledAlert = true
                            print("No access")
                        }
                    }
                    getUserLocation()
                }
                // another swiftUI hack because they removed onViewDidAppear, I'm concerned about what will happen if it takes too long to get the location...
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    refreshTable()
                
            }
            defaults.set(locationName, forKey: "lastKnownLocation")
            checkIfUserIsInIsrael()
            checkIfTablesNeedToBeUpdated()
            createBackgroundThreadForNextUpcomingZman()
            if !Calendar.current.isDate(lastTimeUserWasInApp, inSameDayAs: Date()) && lastTimeUserWasInApp.timeIntervalSinceNow < 7200 {//2 hours
                refreshTable()
            } else {
                updateZmanimList()
            }
            lastTimeUserWasInApp = Date()
        }
        .background {
            NavigationLink("", isActive: $showNextView) {
                switch nextView {
                case .netz:
                    NetzView().applyToolbarHidden()
                case .molad:
                    MoladView().applyToolbarHidden()
                case .jerDirection:
                    JerDirectionView().applyToolbarHidden()
                case .setup:
                    WelcomeScreenView()
                        .navigationBarBackButtonHidden(!defaults.bool(forKey: "isSetup"))
                        .applyToolbarHidden()
                case .setupElevation:
                    SetupElevationView().applyToolbarHidden()
                case .searchForPlace:
                    GetUserLocationView().applyToolbarHidden()
                case .settings:
                    SettingsView().applyToolbarHidden()
                case .setupVisibleSunrise:
                    SetupChooserView().applyToolbarHidden()
                case .siddur:
                    UIKitSiddurControllerView().applyToolbarHidden() // Temp
                default:
                    EmptyView()
                }
            }.hidden()
        }
    }
}

// MARK: - View Modifier for Hiding Toolbar
extension View {
    @ViewBuilder
    func applyToolbarHidden() -> some View {
        if #available(iOS 18.0, *) {
            self.toolbarVisibility(.hidden, for: .tabBar)
        } else if #available(iOS 16.0, *) {
            self.toolbar(.hidden, for: .tabBar)
        } else {
            self // TODO
        }
    }
}

public enum NextView {
    case setupVisibleSunrise
    case netz
    case molad
    case jerDirection
    case setup
    case setupElevation
    case searchForPlace
    case settings
    case siddur
    case none
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    if #available(iOS 15.0, *) {
        ZmanimView()
    } else {
        // Fallback on earlier versions
    }
}
