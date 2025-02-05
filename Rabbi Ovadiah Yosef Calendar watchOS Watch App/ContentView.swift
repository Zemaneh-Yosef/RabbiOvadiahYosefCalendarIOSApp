//
//  ContentView.swift
//  Rabbi Ovadiah Yosef Calendar watchOS Watch App
//
//  Created by User on 11/16/23.
//

import SwiftUI
import KosherSwift
import SunCalc

let defaults = UserDefaults.standard
var locationName: String = ""
var lat: Double = 0
var long: Double = 0
var elevation: Double = 0.0
var timezone: TimeZone = TimeZone.current
var userChosenDate: Date = Date()
var nextUpcomingZman: Date? = nil
var zmanimCalendar: ComplexZmanimCalendar = ComplexZmanimCalendar()
var jewishCalendar: JewishCalendar = JewishCalendar()
let dateFormatterForZmanim = DateFormatter()

struct ContentView: View {
    @State private var zmanimList: [ZmanListEntry] = []
    @StateObject private var settings = InterfaceController()

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(zmanimList, id: \.title) { zmanTime in
                        HStack {
                            if !zmanTime.isZman {
                                if zmanTime.zman != nil {
                                    if Calendar.current.isDateInToday(zmanTime.zman!) {
                                        Spacer()
                                        Text(zmanTime.title).bold()
                                        Spacer()
                                    } else {
                                        Spacer()
                                        Text(zmanTime.title)
                                        Spacer()
                                    }
                                } else {
                                    Spacer()
                                    Text(zmanTime.title)
                                    Spacer()
                                }
                            } else {
                                if defaults.bool(forKey: "isZmanimInHebrew") {
                                    if zmanTime.zman == nextUpcomingZman {
                                        Text(dateFormatterForZmanim.string(from:zmanTime.zman!)).bold().underline()
                                        Spacer()
                                        Text(zmanTime.title).bold().underline()
                                    } else {
                                        Text(dateFormatterForZmanim.string(from:zmanTime.zman!))
                                        Spacer()
                                        Text(zmanTime.title)
                                    }
                                } else {
                                    if zmanTime.zman == nextUpcomingZman {
                                        Text(zmanTime.title).bold().underline()
                                        Spacer()
                                        Text(dateFormatterForZmanim.string(from: zmanTime.zman!)).bold().underline()
                                    } else {
                                        Text(zmanTime.title)
                                        Spacer()
                                        Text(dateFormatterForZmanim.string(from: zmanTime.zman!))
                                    }
                                }
                            }
                        }
                    }
                    Button(action: {
                        userChosenDate = userChosenDate.addingTimeInterval(-86400)
                        syncCalendarDates()
                        zmanimList = updateZmanimList()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left.circle.fill")
                            Spacer()
                            Text("Previous Day")
                        }
                    }
                    Button(action: {
                        userChosenDate = userChosenDate.addingTimeInterval(86400)
                        syncCalendarDates()
                        zmanimList = updateZmanimList()
                    }) {
                        HStack {
                            Text("Next Day")
                            Spacer()
                            Image(systemName: "chevron.right.circle.fill")
                        }
                    }
                }
            }.navigationTitle(settings.description)
        }.onChange(of: settings.hash, {
            getZmanimCalendarWithLocation { complexZmanimCalendar in
                zmanimCalendar = complexZmanimCalendar
                if defaults.bool(forKey: "useElevation") {
                    zmanimCalendar.useElevation = true
                } else {
                    zmanimCalendar.useElevation = false
                }
                dateFormatterForZmanim.timeZone = zmanimCalendar.geoLocation.timeZone.corrected()
                setNextUpcomingZman()
                zmanimList = updateZmanimList()
            }
        })
        .onAppear {
            getZmanimCalendarWithLocation { complexZmanimCalendar in
                // Once the complex zmanim calendar is obtained,
                // update the zmanimList using the data obtained with the current date
                zmanimCalendar = complexZmanimCalendar
                if defaults.bool(forKey: "useElevation") {
                    zmanimCalendar.useElevation = true
                } else {
                    zmanimCalendar.useElevation = false
                }
                userChosenDate = Date()
                syncCalendarDates()
                dateFormatterForZmanim.timeZone = zmanimCalendar.geoLocation.timeZone.corrected()
                setNextUpcomingZman()
                zmanimList = updateZmanimList()
            }
        }
    }
}


func updateZmanimList() -> Array<ZmanListEntry> {
    var zmanimList = Array<ZmanListEntry>()
    if !defaults.bool(forKey: "hasGottenDataFromApp") {
        zmanimList.append(ZmanListEntry(title: "Settings not recieved from the Main App. Please open up the app on your phone.".localized()))
    }
    if Locale.isHebrewLocale() {
        if defaults.bool(forKey: "showSeconds") {
            dateFormatterForZmanim.dateFormat = "H:mm:ss"
        } else {
            dateFormatterForZmanim.dateFormat = "H:mm"
        }
    } else {
        if defaults.bool(forKey: "showSeconds") {
            dateFormatterForZmanim.dateFormat = "h:mm:ss aa"
        } else {
            dateFormatterForZmanim.dateFormat = "h:mm aa"
        }
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
        zmanimList.append(ZmanListEntry(title: "No Tachanun in Yerushalayim or a Safek Mukaf Choma"))
    }
    let bircatHelevana = jewishCalendar.getBirchatLevanaStatus()
    if !bircatHelevana.isEmpty {
        zmanimList.append(ZmanListEntry(title: bircatHelevana))
        do {// This might crash watches with 32 bit architecture. Keep an eye out
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
        zmanimList.append(ZmanListEntry(title: "Birchat HaChamah is said today".localized()))
    }
    if Locale.isHebrewLocale() {
        dateFormatter.dateFormat = "H:mm"
    } else {
        dateFormatter.dateFormat = "h:mm aa"
    }
    dateFormatter.timeZone = timezone
    let tekufaSetting = defaults.integer(forKey: "tekufaOpinion")
    if (tekufaSetting == 0 && !defaults.bool(forKey: "LuachAmudeiHoraah")) || tekufaSetting == 1 {
        let tekufa = jewishCalendar.getTekufaAsDate()
        if tekufa != nil {
            if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
                zmanimList = addTekufaLength(list: zmanimList, tekufa: tekufa, dateFormatter: dateFormatter)
            }
        }
        jewishCalendar.forward()
        let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
        if checkTomorrowForTekufa != nil {
            if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
                zmanimList = addTekufaLength(list: zmanimList, tekufa: checkTomorrowForTekufa, dateFormatter: dateFormatter)
            }
        }
        jewishCalendar.workingDate = userChosenDate //reset
    } else if tekufaSetting == 2 || (tekufaSetting == 0 && defaults.bool(forKey: "LuachAmudeiHoraah")) {
        let tekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
        if tekufa != nil {
            if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
                zmanimList = addTekufaLength(list: zmanimList, tekufa: tekufa, dateFormatter: dateFormatter)
            }
        }
        jewishCalendar.forward()
        let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
        if checkTomorrowForTekufa != nil {
            if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
                zmanimList = addTekufaLength(list: zmanimList, tekufa: checkTomorrowForTekufa, dateFormatter: dateFormatter)
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
    
    zmanimList = ZmanimFactory.addZmanim(list: zmanimList, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar)
    
    zmanimList.append(ZmanListEntry(title:jewishCalendar.getIsMashivHaruchOrMoridHatalSaid() + " / " + jewishCalendar.getIsBarcheinuOrBarechAleinuSaid()))
    
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .abbreviated
    if defaults.bool(forKey: "LuachAmudeiHoraah") {
        zmanimList.append(ZmanListEntry(title:"Shaah Zmanit GRA: ".localized() + (formatter.string(from: TimeInterval(zmanimCalendar.getShaahZmanisGra() / 1000)) ?? "XX:XX")))
        zmanimList.append(ZmanListEntry(title:"Shaah Zmanit MGA: ".localized() + "(Amudei Horaah) ".localized() + (formatter.string(from: TimeInterval(zmanimCalendar.getTemporalHour(startOfDay: zmanimCalendar.getAlosAmudeiHoraah(), endOfDay: zmanimCalendar.getTzais72ZmanisAmudeiHoraah()) / 1000)) ?? "XX:XX")))
    } else {
        zmanimList.append(ZmanListEntry(title:"Shaah Zmanit GRA: ".localized() + (formatter.string(from: TimeInterval(zmanimCalendar.getShaahZmanisGra() / 1000)) ?? "XX:XX")))
        zmanimList.append(ZmanListEntry(title:"Shaah Zmanit MGA: ".localized() + "(Ohr HaChaim) ".localized() + (formatter.string(from: TimeInterval(zmanimCalendar.getShaahZmanis72MinutesZmanis() / 1000)) ?? "XX:XX")))
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
    
    hebrewDateFormatter.hebrewFormat = true
    hebrewDateFormatter.useGershGershayim = false
    let dafYomi = jewishCalendar.getDafYomiBavli()
    if dafYomi != nil {
        zmanimList.append(ZmanListEntry(title:"Daf Yomi: ".localized() + hebrewDateFormatter.formatDafYomiBavli(daf: dafYomi!)))
    }
    let dateString = "1980-02-02"//Yerushalmi start date
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let yerushalmiYomi = YerushalmiYomiCalculator.getDafYomiYerushalmi(jewishCalendar: jewishCalendar)
    if let targetDate = dateFormatter.date(from: dateString) {
        let comparisonResult = targetDate.compare(userChosenDate)
        if comparisonResult == .orderedDescending {
            print("The target date is before Feb 2, 1980.")
        } else if comparisonResult == .orderedAscending {
            if yerushalmiYomi != nil {
                zmanimList.append(ZmanListEntry(title:"Yerushalmi Vilna Yomi: ".localized() + hebrewDateFormatter.formatDafYomiYerushalmi(daf: yerushalmiYomi)))
            } else {
                zmanimList.append(ZmanListEntry(title:"No Yerushalmi Vilna Yomi".localized()))
            }
        }
    }
    return zmanimList
}

func addTekufaLength(list: Array<ZmanListEntry>, tekufa: Date?, dateFormatter: DateFormatter) -> Array<ZmanListEntry> {
    var temp = list
    let halfHourBefore = tekufa!.addingTimeInterval(-1800)
    let halfHourAfter = tekufa!.addingTimeInterval(1800)
    if Locale.isHebrewLocale() {
        temp.append(ZmanListEntry(title: "Tekufa Length: ".localized()
            .appending(dateFormatter.string(from: halfHourAfter))
            .appending(" - ")
            .appending(dateFormatter.string(from: halfHourBefore))))
    } else {
        temp.append(ZmanListEntry(title: "Tekufa Length: ".localized()
            .appending(dateFormatter.string(from: halfHourBefore))
            .appending(" - ")
            .appending(dateFormatter.string(from: halfHourAfter))))
    }
    return temp
}

func setNextUpcomingZman() {
    var theZman: Date? = nil
    var zmanim = Array<ZmanListEntry>()
    var today = Date()
    
    today = today.advanced(by: -86400)//yesterday
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = ZmanimFactory.addZmanim(list: zmanim, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar)
    
    today = today.advanced(by: 86400)//today
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = ZmanimFactory.addZmanim(list: zmanim, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar)

    today = today.advanced(by: 86400)//tomorrow
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = ZmanimFactory.addZmanim(list: zmanim, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar)

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

func syncCalendarDates() {//with userChosenDate
    zmanimCalendar.workingDate = userChosenDate
    jewishCalendar.workingDate = userChosenDate
}

func getZmanimCalendarWithLocation(completion: @escaping (ComplexZmanimCalendar) -> Void) {
    var locationName = ""
    var lat = 0.0
    var long = 0.0
    var elevation = 0.0
    var timezone = TimeZone.current
    
    if defaults.bool(forKey: "useAdvanced") {
        locationName = defaults.string(forKey: "advancedLN") ?? ""
        lat = defaults.double(forKey: "advancedLat")
        long = defaults.double(forKey: "advancedLong")
        timezone = TimeZone(identifier: defaults.string(forKey: "advancedTimezone") ?? "") ?? TimeZone.current
    } else if defaults.bool(forKey: "useLocation1") {
        locationName = defaults.string(forKey: "location1") ?? ""
        lat = defaults.double(forKey: "location1Lat")
        long = defaults.double(forKey: "location1Long")
        timezone = TimeZone(identifier: defaults.string(forKey: "location1Timezone") ?? "") ?? TimeZone.current
    } else if defaults.bool(forKey: "useLocation2") {
        locationName = defaults.string(forKey: "location2") ?? ""
        lat = defaults.double(forKey: "location2Lat")
        long = defaults.double(forKey: "location2Long")
        timezone = TimeZone(identifier: defaults.string(forKey: "location2Timezone") ?? "") ?? TimeZone.current
    } else if defaults.bool(forKey: "useLocation3") {
        locationName = defaults.string(forKey: "location3") ?? ""
        lat = defaults.double(forKey: "location3Lat")
        long = defaults.double(forKey: "location3Long")
        timezone = TimeZone(identifier: defaults.string(forKey: "location3Timezone") ?? "") ?? TimeZone.current
    } else if defaults.bool(forKey: "useLocation4") {
        locationName = defaults.string(forKey: "location4") ?? ""
        lat = defaults.double(forKey: "location4Lat")
        long = defaults.double(forKey: "location4Long")
        timezone = TimeZone(identifier: defaults.string(forKey: "location4Timezone") ?? "") ?? TimeZone.current
    } else if defaults.bool(forKey: "useLocation5") {
        locationName = defaults.string(forKey: "location5") ?? ""
        lat = defaults.double(forKey: "location5Lat")
        long = defaults.double(forKey: "location5Long")
        timezone = TimeZone(identifier: defaults.string(forKey: "location5Timezone") ?? "") ?? TimeZone.current
    } else if defaults.bool(forKey: "useZipcode") {
        locationName = defaults.string(forKey: "locationName") ?? ""
        lat = defaults.double(forKey: "lat")
        long = defaults.double(forKey: "long")
        timezone = TimeZone.init(identifier: defaults.string(forKey: "timezone")!)!
    } else {
        let concurrentQueue = DispatchQueue(label: "watch", attributes: .concurrent)

        return LocationManager.shared.getUserLocation {
            location in concurrentQueue.async {
                lat = location.coordinate.latitude
                long = location.coordinate.longitude
                timezone = TimeZone.current
                LocationManager.shared.resolveLocationName(with: location) { name in
                    locationName = name ?? ""
                    if defaults.object(forKey: "elevation" + locationName) != nil {//if we have been here before, use the elevation saved for this location
                        elevation = defaults.double(forKey: "elevation" + locationName)
                    } else {//we have never been here before, get the elevation from online
                            elevation = 0//undo any previous values
                    }
                    if locationName.isEmpty {
                        locationName = "Lat: " + String(lat) + " Long: " + String(long)
                        if defaults.bool(forKey: "setElevationToLastKnownLocation") {
                            elevation = defaults.double(forKey: "elevation" + (defaults.string(forKey: "lastKnownLocation") ?? ""))
                        }
                    }
                    completion(ComplexZmanimCalendar(location: GeoLocation(locationName: locationName, latitude: lat, longitude: long, elevation: elevation, timeZone: timezone.corrected())))
                }
            }
        }
    }
    if defaults.object(forKey: "elevation" + locationName) != nil {//if we have been here before, use the elevation saved for this location
        elevation = defaults.double(forKey: "elevation" + locationName)
    } else {//we have never been here before, get the elevation from online
            elevation = 0//undo any previous values
    }
    if locationName.isEmpty {
        locationName = "Lat: " + String(lat) + " Long: " + String(long)
        if defaults.bool(forKey: "setElevationToLastKnownLocation") {
            elevation = defaults.double(forKey: "elevation" + (defaults.string(forKey: "lastKnownLocation") ?? ""))
        }
    }
    completion(ComplexZmanimCalendar(location: GeoLocation(locationName: locationName, latitude: lat, longitude: long, elevation: elevation, timeZone: timezone.corrected())))
}

#Preview {
    ContentView()
}
