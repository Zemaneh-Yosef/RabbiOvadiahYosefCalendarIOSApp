//
//  ContentView.swift
//  Rabbi Ovadiah Yosef Calendar watchOS Watch App
//
//  Created by User on 11/16/23.
//

import SwiftUI
import KosherSwift

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
    let date = dateFormatter.string(from: userChosenDate)
            
    let hDateFormatter = DateFormatter()
    hDateFormatter.calendar = Calendar(identifier: .hebrew)
    hDateFormatter.dateFormat = "d MMMM, yyyy"
    let hebrewDate = hDateFormatter.string(from: userChosenDate)
        .replacingOccurrences(of: "Heshvan", with: "Cheshvan")
        .replacingOccurrences(of: "Tamuz", with: "Tammuz")

    zmanimList.append(ZmanListEntry(title:date, zman: userChosenDate))
    zmanimList.append(ZmanListEntry(title:hebrewDate, zman: userChosenDate))
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
    hebrewDateFormatter.hebrewFormat = false
    let haftorah = WeeklyHaftarahReading.getThisWeeksHaftarah(jewishCalendar: jewishCalendar)
    if !haftorah.isEmpty {
        zmanimList.append(ZmanListEntry(title: haftorah))
    }
    syncCalendarDates()//reset
    dateFormatter.dateFormat = "EEEE"
    if Locale.isHebrewLocale() {
        zmanimList.append(ZmanListEntry(title:dateFormatter.string(from: zmanimCalendar.workingDate)))
    } else {
        zmanimList.append(ZmanListEntry(title:dateFormatter.string(from: zmanimCalendar.workingDate) + " / " + getHebrewDay(day: jewishCalendar.getDayOfWeek())))
    }
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
    let bircatHelevana = jewishCalendar.getBirchatLevanaStatus()
    if !bircatHelevana.isEmpty {
        zmanimList.append(ZmanListEntry(title: bircatHelevana))
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
    if tekufaSetting == 0 {
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
    } else if tekufaSetting == 1 {
        let tekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
        if tekufa != nil {
            if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: tekufa!)))
            }
        }
        jewishCalendar.forward()
        let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate(shouldMinus21Minutes: true)
        if checkTomorrowForTekufa != nil {
            if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa ".localized() + jewishCalendar.getTekufaName().localized() + " is today at ".localized() + dateFormatter.string(from: checkTomorrowForTekufa!)))
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
        jewishCalendar.workingDate = userChosenDate //reset
    }
    
    zmanimList = addZmanim(list: zmanimList)
    
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

func addZmanim(list:Array<ZmanListEntry>) -> Array<ZmanListEntry> {
    if defaults.bool(forKey: "LuachAmudeiHoraah") {
        return addAmudeiHoraahZmanim(list:list)
    }
    var temp = list
    let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
    if jewishCalendar.isTaanis()
        && jewishCalendar.getYomTovIndex() != JewishCalendar.TISHA_BEAV
        && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.getAlos72Zmanis(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.getAlos72Zmanis(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.getMisheyakir66MinutesZmanit(), isZman: true))
    let chaitables = ChaiTables(locationName: locationName, jewishCalendar: jewishCalendar, defaults: defaults)
    let visibleSurise = chaitables.getVisibleSurise(forDate: userChosenDate)
    if visibleSurise != nil {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true, isVisibleSunriseZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
    }
    if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.getSofZmanShmaMGA72MinutesZmanis(), isZman: true))
    if (jewishCalendar.isBirkasHachamah()) {
        //TODO make sure this is supposed to be calculated as 3 GRA hours
        temp.append(ZmanListEntry(title: zmanimNames.getBirkatHachamaString(), zman: zmanimCalendar.getSofZmanShmaGRA(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.getSofZmanShmaGRA(), isZman: true))
    if jewishCalendar.getYomTovIndex() == JewishCalendar.EREV_PESACH {
        temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(), zman:zmanimCalendar.getSofZmanTfilaMGA72MinutesZmanis(), isZman: true, isNoteworthyZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.getSofZmanTfilaGRA(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(), zman:zmanimCalendar.getSofZmanBiurChametzMGA72MinutesZmanis(), isZman: true, isNoteworthyZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.getSofZmanTfilaGRA(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(), zman:zmanimCalendar.getChatzosIfHalfDayNil(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman:zmanimCalendar.getMinchaGedolaGreaterThan30(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman:zmanimCalendar.getMinchaKetana(), isZman: true))
    if defaults.integer(forKey: "plagOpinion") == 1 || defaults.object(forKey: "plagOpinion") == nil {
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString(), zman:zmanimCalendar.getPlagHaminchaYalkutYosef(), isZman: true))
    } else if defaults.integer(forKey: "plagOpinion") == 2 {
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.getPlagHamincha(), isZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.getPlagHamincha(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedYalkutYosefString(), zman:zmanimCalendar.getPlagHaminchaYalkutYosef(), isZman: true))
    }
    if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.getDayOfWeek() == 6 {
        zmanimCalendar.candleLightingOffset = 20
        if defaults.object(forKey: "candleLightingOffset") != nil {
            zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
        }
        temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (" + String(zmanimCalendar.candleLightingOffset) + ")", zman:zmanimCalendar.getCandleLighting(), isZman: true, isNoteworthyZman: true))
    }
    if defaults.bool(forKey: "showWhenShabbatChagEnds") {
        if jewishCalendar.getDayOfWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni() {
            jewishCalendar.forward()
            zmanimCalendar.workingDate = jewishCalendar.workingDate//go to the next day
            if !(jewishCalendar.getDayOfWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni()) {//only add if shabbat/chag actually ends
                if defaults.bool(forKey: "showRegularWhenShabbatChagEnds") {
                    zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
                    if defaults.object(forKey: "shabbatOffset") != nil {
                        zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
                    }
                    if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + " (" + String(Int(zmanimCalendar.ateretTorahSunsetOffset)) + ")" + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
                    } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
                    } else {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
                    }
                }
                if defaults.bool(forKey: "showRTWhenShabbatChagEnds") {
                    temp.append(ZmanListEntry(title: zmanimNames.getRTString() + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzais72Zmanis(), isZman: true))
                }
            }
            jewishCalendar.back()
            zmanimCalendar.workingDate = jewishCalendar.workingDate//go back
        }
    }
    jewishCalendar.forward()
    if jewishCalendar.getYomTovIndex() == JewishCalendar.TISHA_BEAV {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman:zmanimCalendar.getElevationAdjustedSunset(), isZman: true))
    }
    jewishCalendar.back()
    temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.getElevationAdjustedSunset(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.getTzais13Point5MinutesZmanis(), isZman: true))
    if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.getDayOfWeek() != 6 {
        if jewishCalendar.getDayOfWeek() == 7 {
            zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
            if defaults.object(forKey: "shabbatOffset") != nil {
                zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
            }
            if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
            } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            } else {
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
            }
        } else {// just yom tov
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzais13Point5MinutesZmanis(), isZman: true, isNoteworthyZman: true))
        }
    }
    if jewishCalendar.isTaanis() && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisAteretTorah(minutes: 20), isZman: true, isNoteworthyZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.getTzaisAteretTorah(minutes: 30), isZman: true, isNoteworthyZman: true))
    } else if defaults.bool(forKey: "showTzeitLChumra") {
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman: zmanimCalendar.getTzaisAteretTorah(minutes: 20), isZman: true))
    }
    if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
        zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
        if defaults.object(forKey: "shabbatOffset") != nil {
            zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
        }
        if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + " (" + String(Int(zmanimCalendar.ateretTorahSunsetOffset)) + ")", zman:zmanimCalendar.getTzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
        } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.getTzais72Zmanis(), isZman: true, isNoteworthyZman: true, isRTZman: true))
        var index = 0
        for var zman in temp {
            if zman.title == zmanimNames.getTzaitHacochavimString() || zman.title == zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString() {
                zman.shouldBeDimmed = true
                temp.remove(at: index)
                temp.insert(zman, at: index)
            }
            index+=1
        }
    }
    if defaults.bool(forKey: "alwaysShowRT") {
        if !(jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting()) {
            temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.getTzais72Zmanis(), isZman: true, isNoteworthyZman: true, isRTZman: true))
        }
    }
    temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman:zmanimCalendar.getSolarMidnightIfSunTransitNil(), isZman: true))
    return temp
}

func addAmudeiHoraahZmanim(list:Array<ZmanListEntry>) -> Array<ZmanListEntry> {
    var temp = list
    let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
    if jewishCalendar.isTaanis()
        && jewishCalendar.getYomTovIndex() != JewishCalendar.TISHA_BEAV
        && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.getAlosAmudeiHoraah(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.getAlosAmudeiHoraah(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.getMisheyakirAmudeiHoraah(), isZman: true))
    let chaitables = ChaiTables(locationName: locationName, jewishCalendar: jewishCalendar, defaults: defaults)
    let visibleSurise = chaitables.getVisibleSurise(forDate: userChosenDate)
    if visibleSurise != nil {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true, isVisibleSunriseZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
    }
    if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.getSofZmanShmaMGA72MinutesZmanisAmudeiHoraah(), isZman: true))
    if (jewishCalendar.isBirkasHachamah()) {
        //TODO make sure this is supposed to be calculated as 3 GRA hours
        temp.append(ZmanListEntry(title: zmanimNames.getBirkatHachamaString(), zman: zmanimCalendar.getSofZmanShmaGRA(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.getSofZmanShmaGRA(), isZman: true))
    if jewishCalendar.getYomTovIndex() == JewishCalendar.EREV_PESACH {
        temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(), zman:zmanimCalendar.getSofZmanAchilatChametzAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.getSofZmanTfilaGRA(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(), zman:zmanimCalendar.getSofZmanBiurChametzMGAAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.getSofZmanTfilaGRA(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(), zman:zmanimCalendar.getChatzosIfHalfDayNil(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman:zmanimCalendar.getMinchaGedolaGreaterThan30(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman: zmanimCalendar.getMinchaKetana(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.getPlagHamincha(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedYalkutYosefString(), zman:zmanimCalendar.getPlagHaminchaYalkutYosefAmudeiHoraah(), isZman: true))
    if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.getDayOfWeek() == 6 {
        zmanimCalendar.candleLightingOffset = 20
        if defaults.object(forKey: "candleLightingOffset") != nil {
            zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
        }
        temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (" + String(zmanimCalendar.candleLightingOffset) + ")", zman:zmanimCalendar.getCandleLighting(), isZman: true, isNoteworthyZman: true))
    }
    if defaults.bool(forKey: "showWhenShabbatChagEnds") {
        if jewishCalendar.getDayOfWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni() {
            jewishCalendar.forward()
            zmanimCalendar.workingDate = jewishCalendar.workingDate//go to the next day
            if !(jewishCalendar.getDayOfWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni()) {//only add if shabbat/chag actually ends
                if defaults.bool(forKey: "showRegularWhenShabbatChagEnds") {
                    temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true))
                }
                if defaults.bool(forKey: "showRTWhenShabbatChagEnds") {
                    temp.append(ZmanListEntry(title: zmanimNames.getRTString() + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzais72ZmanisAmudeiHoraahLkulah(), isZman: true))
                }
            }
            jewishCalendar.back()
            zmanimCalendar.workingDate = jewishCalendar.workingDate//go back
        }
    }
    jewishCalendar.forward()
    if jewishCalendar.getYomTovIndex() == JewishCalendar.TISHA_BEAV {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman:zmanimCalendar.getElevationAdjustedSunset(), isZman: true))
    }
    jewishCalendar.back()
    temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.getSeaLevelSunset(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.getTzaisAmudeiHoraah(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.getTzaisAmudeiHoraahLChumra(), isZman: true))
    if jewishCalendar.isTaanis() && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisAmudeiHoraahLChumra(), isZman: true, isNoteworthyZman: true))
    }
    if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.getDayOfWeek() != 6 {
        if jewishCalendar.getDayOfWeek() == 7 {
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        } else {// just yom tov
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisAmudeiHoraahLChumra(), isZman: true, isNoteworthyZman: true))
        }
    }
    if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.getTzais72ZmanisAmudeiHoraahLkulah(), isZman: true, isNoteworthyZman: true, isRTZman: true))
        var index = 0
        for var zman in temp {
            if zman.title == zmanimNames.getTzaitHacochavimString() || zman.title == zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString() {
                zman.shouldBeDimmed = true
                temp.remove(at: index)
                temp.insert(zman, at: index)
            }
            index+=1
        }
    }
    if defaults.bool(forKey: "alwaysShowRT") {
        if !(jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting()) {
            temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.getTzais72ZmanisAmudeiHoraahLkulah(), isZman: true, isNoteworthyZman: true, isRTZman: true))
        }
    }
    temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman:zmanimCalendar.getSolarMidnightIfSunTransitNil(), isZman: true))
    return temp
}

func setNextUpcomingZman() {
    var theZman: Date? = nil
    var zmanim = Array<ZmanListEntry>()
    var today = Date()
    
    today = today.advanced(by: -86400)//yesterday
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = addZmanim(list: zmanim)
    
    today = today.advanced(by: 86400)//today
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = addZmanim(list: zmanim)

    today = today.advanced(by: 86400)//tomorrow
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = addZmanim(list: zmanim)

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

func getHebrewDay(day:Int) -> String {
    var dayHebrew = "יום "
    if day == 1 {
        dayHebrew += "ראשון"
    }
    if day == 2 {
        dayHebrew += "שני"
    }
    if day == 3 {
        dayHebrew += "שלישי"
    }
    if day == 4 {
        dayHebrew += "רביעי"
    }
    if day == 5 {
        dayHebrew += "חמישי"
    }
    if day == 6 {
        dayHebrew += "שישי"
    }
    if day == 7 {
        dayHebrew += "שבת"
    }
    return dayHebrew
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
