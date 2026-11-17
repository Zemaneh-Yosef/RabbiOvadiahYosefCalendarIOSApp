//
//  ContentView.swift
//  Rabbi Ovadiah Yosef Calendar watchOS Watch App
//
//  Created by User on 11/16/23.
//

import Foundation
import SwiftUI
import KosherSwift
import SunCalc

let defaults = UserDefaults.standard // user defaults do not get brought over from the main iOS app, so no suiteID will help
var timezone: TimeZone = TimeZone.current.corrected()
var userChosenDate: Date = Date()
var nextUpcomingZman: ZmanListEntry? = nil
var zmanimCalendar: ComprehensiveZmanimCalendar = ComprehensiveZmanimCalendar()
var jewishCalendar: JewishCalendar = JewishCalendar()

struct ContentView: View {
    @State private var zmanimList: [ZmanListEntry] = []
    @StateObject private var settings = InterfaceController()
    @State private var userHasNotPressed = true
    @State private var upcomingZman: ZmanListEntry? = nil
    
//    var initialView: some View {// TODO fix this transition
//        VStack {
//            Spacer()
//            HStack {
//                Spacer()
//                Text(upcomingZman?.title ?? "Test")
//                Spacer()
//                Text(upcomingZman?.zman?.format(defaults: defaults,
//                                                    timezone: timezone,
//                                                    secondTreatment: (nextUpcomingZman != nil ? nextUpcomingZman!.secondTreatment : .roundEarlier)) ?? "XX:XX")
//                Spacer()
//            }
//            Spacer()
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .contentShape(Rectangle())
//        .background {
//            Color.secondary// TODO fix background color
//        }
//        .gesture(DragGesture(minimumDistance: 1, coordinateSpace: .global).onEnded { value in
//            withAnimation(.smooth, {
//                userHasNotPressed = false
//            })
//        })
//        .onTapGesture {
//            withAnimation(.smooth, {
//                userHasNotPressed = false
//            })
//        }
//        .onAppear {
//            getZmanimCalendarWithLocation { complexZmanimCalendar in
//                zmanimCalendar = complexZmanimCalendar
//                zmanimCalendar.useElevation = defaults.bool(forKey: "useElevation")
//                jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
//                timezone = complexZmanimCalendar.geoLocation.timeZone
//                userChosenDate = Date()
//                syncCalendarDates()
//                setNextUpcomingZman()
//                upcomingZman = nextUpcomingZman
//                zmanimList = updateZmanimList()
//            }
//        }
//    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                List {
                    ForEach(zmanimList, id: \.title) { zmanTime in
                        HStack {
                            if !zmanTime.type.isZman {
                                Spacer()
                                Text(zmanTime.title)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            } else {// zmanim
                                if zmanTime.zman != nil {
                                    if defaults.bool(forKey: "isZmanimInHebrew") {
                                        if zmanTime.zman == nextUpcomingZman?.zman {
                                            Text(zmanTime.zman!.format(defaults: defaults, timezone: timezone, secondTreatment: zmanTime.secondTreatment)).bold().underline()
                                            Spacer()
                                            Text(zmanTime.title).bold().underline()
                                        } else {
                                            Text(zmanTime.zman!.format(defaults: defaults, timezone: timezone, secondTreatment: zmanTime.secondTreatment))
                                            Spacer()
                                            Text(zmanTime.title)
                                        }
                                    } else {
                                        if zmanTime.zman == nextUpcomingZman?.zman {
                                            Text(zmanTime.title).bold().underline()
                                            Spacer()
                                            Text(zmanTime.zman!.format(defaults: defaults, timezone: timezone, secondTreatment: zmanTime.secondTreatment)).bold().underline()
                                        } else {
                                            Text(zmanTime.title)
                                            Spacer()
                                            Text(zmanTime.zman!.format(defaults: defaults, timezone: timezone, secondTreatment: zmanTime.secondTreatment))
                                        }
                                    }
                                }
                            }
                        }
                        .id(zmanTime.zman?.timeIntervalSince1970)
                    }
                }
                .onChange(of: zmanimList, {
                    proxy.scrollTo(nextUpcomingZman?.zman?.timeIntervalSince1970, anchor: .center)
                })
            }
            .navigationTitle(settings.description)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button(action: { changeDay(by: -1) }) {
                        Image(systemName: "chevron.left")
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(action: { changeDay(by: 1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
        .onChange(of: settings.hash, {
            getZmanimCalendarWithLocation { complexZmanimCalendar in
                zmanimCalendar = complexZmanimCalendar
                zmanimCalendar.astronomicalCalculator = SPACalculator()
                zmanimCalendar.useElevation = defaults.bool(forKey: "useElevation")
                jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
                timezone = complexZmanimCalendar.geoLocation.timeZone
                setNextUpcomingZman()
                zmanimList = updateZmanimList()
            }
        })
        .onAppear {
            getZmanimCalendarWithLocation { complexZmanimCalendar in
                // Once the complex zmanim calendar is obtained,
                // update the zmanimList using the data obtained with the current date
                zmanimCalendar = complexZmanimCalendar
                zmanimCalendar.astronomicalCalculator = SPACalculator()
                zmanimCalendar.useElevation = defaults.bool(forKey: "useElevation")
                jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
                timezone = complexZmanimCalendar.geoLocation.timeZone
                userChosenDate = Date()
                syncCalendarDates()
                setNextUpcomingZman()
                zmanimList = updateZmanimList()
            }
        }
    }
    
    func changeDay(by amount: Int) {
        userChosenDate = Calendar.current.date(byAdding: .day, value: amount, to: userChosenDate) ?? Date()
        syncCalendarDates()
        zmanimList = updateZmanimList()
    }
}

func updateZmanimList() -> Array<ZmanListEntry> {
    var zmanimList = Array<ZmanListEntry>()
    if !defaults.bool(forKey: "hasGottenDataFromApp") {
        zmanimList.append(ZmanListEntry(title: "Settings not recieved from the Main App. Please open up the app on your phone.".localized()))
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMMM, yyyy"
    dateFormatter.timeZone = timezone
    zmanimList.append(ZmanListEntry(title: zmanimCalendar.geoLocation.locationName))
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
        if Date() > zmanimCalendar.getSunset() ?? Date() {
            hebrewDate = hDateFormatter.string(from: userChosenDate.addingTimeInterval(86400))
                .replacingOccurrences(of: "Heshvan", with: "Cheshvan")
                .replacingOccurrences(of: "Tamuz", with: "Tammuz")
            
            if Locale.isHebrewLocale() {
                let hebrewDateFormatter = HebrewDateFormatter()
                hebrewDateFormatter.hebrewFormat = true
                hebrewDate = hebrewDateFormatter.format(jewishCalendar: jewishCalendar.tomorrow())
            }
            date += "\n🌙\n" + hebrewDate
        } else {
            date += "\n☀️\n" + hebrewDate
        }
    } else {
        date += "\n" + hebrewDate
    }
    zmanimList.append(ZmanListEntry(title:date))
    //forward jewish calendar to saturday
    while jewishCalendar.getDayOfWeek() != 7 {
        jewishCalendar.forward()
    }
    let hebrewDateFormatter = HebrewDateFormatter()
    hebrewDateFormatter.hebrewFormat = true
    //now that we are on saturday, check the parasha
    let specialParasha = hebrewDateFormatter.formatSpecialParshah(jewishCalendar: jewishCalendar)
    var parasha = hebrewDateFormatter.formatParshah(parsha: jewishCalendar.getParshah())

    if !specialParasha.isEmpty {
        parasha += " / " + specialParasha
    }
    if !parasha.isEmpty {
        zmanimList.append(ZmanListEntry(title:parasha))
    } else {
        zmanimList.append(ZmanListEntry(title:"No Weekly Parasha".localized()))
    }
    let haftorah = WeeklySephardicHaftarot.getThisWeeksHaftarah(jCal: jewishCalendar)
    if !haftorah.text.isEmpty {
        zmanimList.append(ZmanListEntry(title: (Locale.isHebrewLocale() ? "מפטירין" : "Haftarah: \u{202B}")
            .appending(" (")
            .appending(haftorah.source)
            .appending(") ")
            .appending(haftorah.text)))
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
        zmanimList.append(ZmanListEntry(title: bircatHelevana, type: .birchatHalevana))
        if let nightfall = zmanimCalendar.getTzeitHacochavim(defaults: defaults),
           let dawn = getAlotHashacharDateForTomorrow() {
            let summary = getMoonSummary(czc: zmanimCalendar, start: nightfall, dawn: dawn)
            if !summary.isEmpty {
                zmanimList.append(ZmanListEntry(title: summary, type: .moonStatus))
            }
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
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + hebrewDateFormatter.formatTekufaName(jewishCalendar: jewishCalendar).replace("Tekufas ", "").replace("תקופת ", "").localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
                zmanimList = addTekufaLength(list: zmanimList, tekufa: tekufa, dateFormatter: dateFormatter)
            }
        }
        jewishCalendar.forward()
        let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
        if checkTomorrowForTekufa != nil {
            if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + hebrewDateFormatter.formatTekufaName(jewishCalendar: jewishCalendar).replace("Tekufas ", "").replace("תקופת ", "").localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
                zmanimList = addTekufaLength(list: zmanimList, tekufa: checkTomorrowForTekufa, dateFormatter: dateFormatter)
            }
        }
        jewishCalendar.workingDate = userChosenDate //reset
    } else if tekufaSetting == 2 || (tekufaSetting == 0 && defaults.bool(forKey: "LuachAmudeiHoraah")) {
        let tekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
        if tekufa != nil {
            if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + hebrewDateFormatter.formatTekufaName(jewishCalendar: jewishCalendar).replace("Tekufas ", "").replace("תקופת ", "").localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
                zmanimList = addTekufaLength(list: zmanimList, tekufa: tekufa, dateFormatter: dateFormatter)
            }
        }
        jewishCalendar.forward()
        let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
        if checkTomorrowForTekufa != nil {
            if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + hebrewDateFormatter.formatTekufaName(jewishCalendar: jewishCalendar).replace("Tekufas ", "").replace("תקופת ", "").localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
                zmanimList = addTekufaLength(list: zmanimList, tekufa: checkTomorrowForTekufa, dateFormatter: dateFormatter)
            }
        }
        jewishCalendar.workingDate = userChosenDate //reset
    } else {
        let tekufa = jewishCalendar.getTekufaAsDate()
        if tekufa != nil {
            if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + hebrewDateFormatter.formatTekufaName(jewishCalendar: jewishCalendar).replace("Tekufas ", "").replace("תקופת ", "").localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
            }
        }
        jewishCalendar.forward()
        let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
        if checkTomorrowForTekufa != nil {
            if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + hebrewDateFormatter.formatTekufaName(jewishCalendar: jewishCalendar).replace("Tekufas ", "").replace("תקופת ", "").localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
            }
        }
        jewishCalendar.workingDate = userChosenDate //reset
        
        let tekufaAH = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
        if tekufaAH != nil {
            if Calendar.current.isDate(tekufaAH!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + hebrewDateFormatter.formatTekufaName(jewishCalendar: jewishCalendar).replace("Tekufas ", "").replace("תקופת ", "").localized() + " is today at ".localized() + dateFormatter.string(from: tekufaAH!)))
            }
        }
        jewishCalendar.forward()
        let checkTomorrowForAHTekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
        if checkTomorrowForAHTekufa != nil {
            if Calendar.current.isDate(checkTomorrowForAHTekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + hebrewDateFormatter.formatTekufaName(jewishCalendar: jewishCalendar).replace("Tekufas ", "").replace("תקופת ", "").localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForAHTekufa!)))
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
    
    zmanimList.append(ZmanListEntry(title: jewishCalendar.getSeasonalPrayerChanges(), type: .seasonalPrayerChanges))
    
    zmanimList.append(ZmanListEntry(
        title: "Shaah Zemanit GR\"A: ".localized() + formatZmanitHours(zmanimCalendar.getShaahZmanisGRA()),
        type: .shaahZmanitGRA
    ))

    if defaults.bool(forKey: "LuachAmudeiHoraah") {
        let amudeiHoraahTI = zmanimCalendar.getTemporalHour(
            startOfDay: zmanimCalendar.getAlosAmudeiHoraah(),
            endOfDay: zmanimCalendar.getTzais72ZmanisAmudeiHoraah()
        )
        zmanimList.append(ZmanListEntry(
            title: "Shaah Zemanit MG\"A (A\"H): ".localized() + formatZmanitHours(amudeiHoraahTI),
            type: .shaahZmanitMGA
        ))
    } else {
        zmanimList.append(ZmanListEntry(
            title: "Shaah Zemanit MG\"A (O\"H): ".localized() + formatZmanitHours(zmanimCalendar.getShaahZmanis72MinutesZmanis()),
            type: .shaahZmanitMGA
        ))
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

func getAlotHashacharDateForTomorrow() -> Date? {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = timezone
    let copy = zmanimCalendar.copy()
    copy.workingDate = cal.date(byAdding: .day, value: 1, to: userChosenDate) ?? userChosenDate.addingTimeInterval(86400)
    return copy.getAlotHashachar(defaults: defaults)
}

/// Describes the moon between nightfall and dawn: up until moonset, rising later, up all night, or not up.
/// Returns an empty string if it can't be computed.
private func getMoonSummary(czc: ComprehensiveZmanimCalendar,start: Date, dawn: Date) -> String {
    guard dawn > start else { return "" }

    let hebrew = Locale.isHebrewLocale()
    let label = hebrew ? "נראות הירח: " : "Moon Visibility: "

    do {
        let moon = try MoonTimes.compute()
            .on(start)
            .at(czc.geoLocation.latitude, czc.geoLocation.longitude)
            .timezone(timezone)
            .limit(dawn.timeIntervalSince(start)) // one night only, not a full day
            .execute()

        if moon.alwaysUp {
            return label + (hebrew ? "כל הלילה" : "all night")
        }
        if moon.alwaysDown {
            return label + (hebrew ? "לא נראה הלילה" : "none tonight")
        }

        let formatter = DateFormatter()
        formatter.timeZone = timezone
        formatter.dateFormat = hebrew ? "H:mm" : "h:mm aa"
        let from = hebrew ? "מ-" : "from "
        let until = hebrew ? "עד " : "until "

        let rise = moon.rise.map { Date(timeIntervalSince1970: $0.timeIntervalSince1970) }
        let set = moon.set.map { Date(timeIntervalSince1970: $0.timeIntervalSince1970) }

        switch (rise, set) {
        case let (rise?, set?):
            return rise < set
                ? label + from + formatter.string(from: rise) + " " + until + formatter.string(from: set)
                : label + until + formatter.string(from: set) + ", " + from + formatter.string(from: rise)
        case let (nil, set?):
            return label + until + formatter.string(from: set)  // up at nightfall, sets during the night
        case let (rise?, nil):
            return label + from + formatter.string(from: rise)  // rises during the night, up until dawn
        default:
            return ""
        }
    } catch {
        print(error) // the moon line is a bonus, still show everything else
        return ""
    }
}

func formatZmanitHours(_ ti: TimeInterval?) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .abbreviated
    // Check if the calculation returned a valid, finite number (not NaN or Infinity)
    guard let seconds = ti, !seconds.isNaN && !seconds.isInfinite else {
        return "XX:XX"
    }
    return formatter.string(from: TimeInterval(seconds)) ?? "XX:XX"
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
    var theZman: ZmanListEntry? = nil
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
            if zman! > Date() && (theZman == nil || zman! < theZman?.zman ?? Date()) {
                theZman = entry
            }
        }
    }
    nextUpcomingZman = theZman
}

func syncCalendarDates() {//with userChosenDate
    zmanimCalendar.workingDate = userChosenDate
    jewishCalendar.workingDate = userChosenDate
}

func getZmanimCalendarWithLocation(completion: @escaping (ComprehensiveZmanimCalendar) -> Void) {
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
                if location != nil {
                    lat = location!.coordinate.latitude
                    long = location!.coordinate.longitude
                    timezone = TimeZone.current
                    LocationManager.shared.resolveLocationName(with: location!) { name in
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
                        completion(ComprehensiveZmanimCalendar(location: GeoLocation(locationName: locationName, latitude: lat, longitude: long, elevation: elevation, timeZone: timezone.corrected())))
                    }
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
    completion(ComprehensiveZmanimCalendar(location: GeoLocation(locationName: locationName, latitude: lat, longitude: long, elevation: elevation, timeZone: timezone.corrected())))
}

#Preview {
    ContentView()
}
