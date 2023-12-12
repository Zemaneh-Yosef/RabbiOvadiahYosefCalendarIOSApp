//
//  ContentView.swift
//  Rabbi Ovadiah Yosef Calendar watchOS Watch App
//
//  Created by User on 11/16/23.
//

import SwiftUI
import KosherCocoa

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
                .padding()
            }.navigationTitle(settings.description)
        }.onChange(of: settings.hash, {
            getZmanimCalendarWithLocation { complexZmanimCalendar in
                zmanimCalendar = complexZmanimCalendar
                dateFormatterForZmanim.timeZone = timezone
                setNextUpcomingZman()
                zmanimList = updateZmanimList()
            }
        })
        .onAppear {
            getZmanimCalendarWithLocation { complexZmanimCalendar in
                // Once the complex zmanim calendar is obtained,
                // update the zmanimList using the data obtained with the current date
                zmanimCalendar = complexZmanimCalendar
                userChosenDate = Date()
                syncCalendarDates()
                dateFormatterForZmanim.timeZone = timezone
                setNextUpcomingZman()
                zmanimList = updateZmanimList()
            }
        }
    }
}


func updateZmanimList() -> Array<ZmanListEntry> {
    var zmanimList = Array<ZmanListEntry>()
    if !defaults.bool(forKey: "hasGottenDataFromApp") {
        zmanimList.append(ZmanListEntry(title: "Settings not recieved from the Main App. Please open up the app on your phone."))
    }
    if defaults.bool(forKey: "showSeconds") {
        dateFormatterForZmanim.dateFormat = "h:mm:ss aa"
    } else {
        dateFormatterForZmanim.dateFormat = "h:mm aa"
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d MMMM, yyyy"
    dateFormatter.timeZone = timezone
    zmanimList.append(ZmanListEntry(title: locationName))
    let date = dateFormatter.string(from: userChosenDate)
            
    let hebrewDateFormatter = DateFormatter()
    hebrewDateFormatter.calendar = Calendar(identifier: .hebrew)
    hebrewDateFormatter.dateFormat = "d MMMM, yyyy"
    let hebrewDate = hebrewDateFormatter.string(from: userChosenDate)
        .replacingOccurrences(of: "Heshvan", with: "Cheshvan")
        .replacingOccurrences(of: "Tamuz", with: "Tammuz")

    zmanimList.append(ZmanListEntry(title:date, zman: userChosenDate))
    zmanimList.append(ZmanListEntry(title:hebrewDate, zman: userChosenDate))
    //forward jewish calendar to saturday
    while jewishCalendar.currentDayOfTheWeek() != 7 {
        jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
    }
    //now that we are on saturday, check the parasha
    let specialParasha = jewishCalendar.getSpecialParasha()
    var parasha = ""
    
    if defaults.bool(forKey: "inIsrael") {
        parasha = ParashatHashavuaCalculator().parashaInIsrael(for: jewishCalendar.workingDate).name()
    } else {
        parasha = ParashatHashavuaCalculator().parashaInDiaspora(for: jewishCalendar.workingDate).name()
    }
    if !specialParasha.isEmpty {
        parasha += " / " + specialParasha
    }
    zmanimList.append(ZmanListEntry(title:parasha))
    syncCalendarDates()//reset
    dateFormatter.dateFormat = "EEEE"
    zmanimList.append(ZmanListEntry(title:dateFormatter.string(from: zmanimCalendar.workingDate) + " / " + getHebrewDay(day: jewishCalendar.currentDayOfTheWeek())))
    let specialDay = jewishCalendar.getSpecialDay(addOmer:true)
    if !specialDay.isEmpty {
        zmanimList.append(ZmanListEntry(title:specialDay))
    }
    if jewishCalendar.is3Weeks() {
        if jewishCalendar.is9Days() {
            if jewishCalendar.isShevuahShechalBo() {
                zmanimList.append(ZmanListEntry(title: "Shevuah Shechal Bo"))
            } else {
                zmanimList.append(ZmanListEntry(title: "Nine Days"))
            }
        } else {
            zmanimList.append(ZmanListEntry(title: "Three Weeks"))
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
        zmanimList.append(ZmanListEntry(title: "Birchat HaChamah is said today"))
    }
    dateFormatter.dateFormat = "h:mm aa"
    dateFormatter.timeZone = timezone
    let tekufaSetting = defaults.integer(forKey: "tekufaOpinion")
    if tekufaSetting == 0 {
        let tekufa = jewishCalendar.getTekufaAsDate()
        if tekufa != nil {
            if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufa!)))
            }
        }
        jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
        let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
        if checkTomorrowForTekufa != nil {
            if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: checkTomorrowForTekufa!)))
            }
        }
        jewishCalendar.workingDate = userChosenDate //reset
    } else if tekufaSetting == 1 {
        let tekufa = jewishCalendar.getAmudeiHoraahTekufaAsDate()
        if tekufa != nil {
            if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufa!)))
            }
        }
        jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
        let checkTomorrowForTekufa = jewishCalendar.getAmudeiHoraahTekufaAsDate()
        if checkTomorrowForTekufa != nil {
            if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: checkTomorrowForTekufa!)))
            }
        }
        jewishCalendar.workingDate = userChosenDate //reset
    } else {
        let tekufa = jewishCalendar.getTekufaAsDate()
        if tekufa != nil {
            if Calendar.current.isDate(tekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufa!)))
            }
        }
        jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
        let checkTomorrowForTekufa = jewishCalendar.getTekufaAsDate()
        if checkTomorrowForTekufa != nil {
            if Calendar.current.isDate(checkTomorrowForTekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: checkTomorrowForTekufa!)))
            }
        }
        jewishCalendar.workingDate = userChosenDate //reset
        
        let tekufaAH = jewishCalendar.getAmudeiHoraahTekufaAsDate()
        if tekufaAH != nil {
            if Calendar.current.isDate(tekufaAH!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: tekufaAH!)))
            }
        }
        jewishCalendar.workingDate = jewishCalendar.workingDate.addingTimeInterval(86400)
        let checkTomorrowForAHTekufa = jewishCalendar.getAmudeiHoraahTekufaAsDate()
        if checkTomorrowForAHTekufa != nil {
            if Calendar.current.isDate(checkTomorrowForAHTekufa!, inSameDayAs: userChosenDate) {
                zmanimList.append(ZmanListEntry(title: "Tekufa " + jewishCalendar.getTekufaName() + " is today at " + dateFormatter.string(from: checkTomorrowForAHTekufa!)))
            }
        }
        jewishCalendar.workingDate = userChosenDate //reset
    }
    
    zmanimList = addZmanim(list: zmanimList)
    
    let dafYomi = jewishCalendar.dafYomiBavli()
    if dafYomi != nil {
        zmanimList.append(ZmanListEntry(title:"Daf Yomi: " + ((dafYomi!.name())) + " " + dafYomi!.pageNumber.formatHebrew()))
    }
    let dateString = "1980-02-02"//Yerushalmi start date
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let yerushalmiYomi = DafYomiCalculator(date: userChosenDate).dafYomiYerushalmi(calendar: jewishCalendar)
    if let targetDate = dateFormatter.date(from: dateString) {
        let comparisonResult = targetDate.compare(userChosenDate)
        if comparisonResult == .orderedDescending {
            print("The target date is before Feb 2, 1980.")
        } else if comparisonResult == .orderedAscending {
            if yerushalmiYomi != nil {
                zmanimList.append(ZmanListEntry(title:"Yerushalmi Vilna Yomi: " +  yerushalmiYomi!.nameYerushalmi() + " " + yerushalmiYomi!.pageNumber.formatHebrew()))
            } else {
                zmanimList.append(ZmanListEntry(title:"No Yerushalmi Vilna Yomi"))
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
        && jewishCalendar.yomTovIndex() != kTishaBeav.rawValue
        && jewishCalendar.yomTovIndex() != kYomKippur.rawValue {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.alos72Zmanis(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.alos72Zmanis(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.talitTefilin(), isZman: true))
    let chaitables = ChaiTables(locationName: locationName, jewishYear: jewishCalendar.currentHebrewYear(), defaults: defaults)
    let visibleSurise = chaitables.getVisibleSurise(forDate: userChosenDate)
    if visibleSurise != nil {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true, isVisibleSunriseZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
    }
    if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.sofZmanShmaMGA72MinutesZmanis(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.sofZmanShmaGra(), isZman: true))
    if jewishCalendar.yomTovIndex() == kErevPesach.rawValue {
        temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(), zman:zmanimCalendar.sofZmanTfilaMGA72MinutesZmanis(), isZman: true, isNoteworthyZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(), zman:zmanimCalendar.sofZmanBiurChametzMGA(), isZman: true, isNoteworthyZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(), zman:zmanimCalendar.chatzos(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman:zmanimCalendar.minchaGedolaGreaterThan30(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman:zmanimCalendar.minchaKetana(), isZman: true))
    if defaults.integer(forKey: "plagOpinion") == 1 || defaults.object(forKey: "plagOpinion") == nil {
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString(), zman:zmanimCalendar.plagHamincha(), isZman: true))
    } else if defaults.integer(forKey: "plagOpinion") == 2 {
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.plagHaminchaHalachaBerurah(), isZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.plagHaminchaHalachaBerurah(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedYalkutYosefString(), zman:zmanimCalendar.plagHamincha(), isZman: true))
    }
    if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.currentDayOfTheWeek() == 6 {
        zmanimCalendar.candleLightingOffset = 20
        if defaults.object(forKey: "candleLightingOffset") != nil {
            zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
        }
        temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (" + String(zmanimCalendar.candleLightingOffset) + ")", zman:zmanimCalendar.candleLighting(), isZman: true, isNoteworthyZman: true))
    }
    if defaults.bool(forKey: "showWhenShabbatChagEnds") {
        if jewishCalendar.currentDayOfTheWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni() {
            jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
            zmanimCalendar.workingDate = jewishCalendar.workingDate//go to the next day
            if !(jewishCalendar.currentDayOfTheWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni()) {//only add if shabbat/chag actually ends
                if defaults.bool(forKey: "showRegularWhenShabbatChagEnds") {
                    zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
                    if defaults.object(forKey: "shabbatOffset") != nil {
                        zmanimCalendar.ateretTorahSunsetOffset = Int32(defaults.integer(forKey: "shabbatOffset"))
                    }
                    if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + " (" + String(zmanimCalendar.ateretTorahSunsetOffset) + ")" + zmanimNames.getMacharString(), zman:zmanimCalendar.tzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
                    } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
                    } else {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
                    }
                }
                if defaults.bool(forKey: "showRTWhenShabbatChagEnds") {
                    temp.append(ZmanListEntry(title: zmanimNames.getRTString() + zmanimNames.getMacharString(), zman:zmanimCalendar.tzais72Zmanis(), isZman: true))
                }
            }
            jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: -86400)
            zmanimCalendar.workingDate = jewishCalendar.workingDate//go back
        }
    }
    jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
    if jewishCalendar.yomTovIndex() == kTishaBeav.rawValue {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman:zmanimCalendar.sunset(), isZman: true))
    }
    jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: -86400)
    temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.sunset(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.tzeit(), isZman: true))
    if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.currentDayOfTheWeek() != 6 {
        if jewishCalendar.currentDayOfTheWeek() == 7 {
            zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
            if defaults.object(forKey: "shabbatOffset") != nil {
                zmanimCalendar.ateretTorahSunsetOffset = Int32(defaults.integer(forKey: "shabbatOffset"))
            }
            if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
            } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            } else {
                temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
            }
        } else {// just yom tov
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzeit(), isZman: true, isNoteworthyZman: true))
        }
    }
    if jewishCalendar.isTaanis() && jewishCalendar.yomTovIndex() != kYomKippur.rawValue {
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzeitTaanit(), isZman: true, isNoteworthyZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.tzeitTaanitLChumra(), isZman: true, isNoteworthyZman: true))
    } else if defaults.bool(forKey: "showTzeitLChumra") {
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman: zmanimCalendar.tzeitTaanit(), isZman: true))
    }
    if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
        zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
        if defaults.object(forKey: "shabbatOffset") != nil {
            zmanimCalendar.ateretTorahSunsetOffset = Int32(defaults.integer(forKey: "shabbatOffset"))
        }
        if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + " (" + String(zmanimCalendar.ateretTorahSunsetOffset) + ")", zman:zmanimCalendar.tzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
        } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
        }
        temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.tzait72Zmanit(), isZman: true, isNoteworthyZman: true, isRTZman: true))
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
            temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.tzait72Zmanit(), isZman: true, isNoteworthyZman: true, isRTZman: true))
        }
    }
    temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman:zmanimCalendar.solarMidnight(), isZman: true))
    return temp
}

func addAmudeiHoraahZmanim(list:Array<ZmanListEntry>) -> Array<ZmanListEntry> {
    var temp = list
    let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
    if jewishCalendar.isTaanis()
        && jewishCalendar.yomTovIndex() != kTishaBeav.rawValue
        && jewishCalendar.yomTovIndex() != kYomKippur.rawValue {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.alotAmudeiHoraah(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.alotAmudeiHoraah(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.talitTefilinAmudeiHoraah(), isZman: true))
    let chaitables = ChaiTables(locationName: locationName, jewishYear: jewishCalendar.currentHebrewYear(), defaults: defaults)
    let visibleSurise = chaitables.getVisibleSurise(forDate: userChosenDate)
    if visibleSurise != nil {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true, isVisibleSunriseZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
    }
    if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.seaLevelSunriseOnly(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.shmaMGAAmudeiHoraah(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.sofZmanShmaGra(), isZman: true))
    if jewishCalendar.yomTovIndex() == kErevPesach.rawValue {
        temp.append(ZmanListEntry(title: zmanimNames.getAchilatChametzString(), zman:zmanimCalendar.achilatChametzAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getBiurChametzString(), zman:zmanimCalendar.biurChametzAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getBrachotShmaString(), zman:zmanimCalendar.sofZmanTfilaGra(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getChatzotString(), zman:zmanimCalendar.chatzos(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getMinchaGedolaString(), zman:zmanimCalendar.minchaGedolaGreaterThan30(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getMinchaKetanaString(), zman: zmanimCalendar.minchaKetana(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedHalachaBerurahString(), zman:zmanimCalendar.plagHaminchaHalachaBerurah(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getPlagHaminchaString() + " " + zmanimNames.getAbbreviatedYalkutYosefString(), zman:zmanimCalendar.plagHaminchaYalkutYosefAmudeiHoraah(), isZman: true))
    if (jewishCalendar.hasCandleLighting() && !jewishCalendar.isAssurBemelacha()) || jewishCalendar.currentDayOfTheWeek() == 6 {
        zmanimCalendar.candleLightingOffset = 20
        if defaults.object(forKey: "candleLightingOffset") != nil {
            zmanimCalendar.candleLightingOffset = defaults.integer(forKey: "candleLightingOffset")
        }
        temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString() + " (" + String(zmanimCalendar.candleLightingOffset) + ")", zman:zmanimCalendar.candleLighting(), isZman: true, isNoteworthyZman: true))
    }
    if defaults.bool(forKey: "showWhenShabbatChagEnds") {
        if jewishCalendar.currentDayOfTheWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni() {
            jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
            zmanimCalendar.workingDate = jewishCalendar.workingDate//go to the next day
            if !(jewishCalendar.currentDayOfTheWeek() == 6 || jewishCalendar.isErevYomTov() || jewishCalendar.isErevYomTovSheni()) {//only add if shabbat/chag actually ends
                if defaults.bool(forKey: "showRegularWhenShabbatChagEnds") {
                    temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true))
                }
                if defaults.bool(forKey: "showRTWhenShabbatChagEnds") {
                    temp.append(ZmanListEntry(title: zmanimNames.getRTString() + zmanimNames.getMacharString(), zman:zmanimCalendar.tzait72ZmanitAmudeiHoraahLkulah(), isZman: true))
                }
            }
            jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: -86400)
            zmanimCalendar.workingDate = jewishCalendar.workingDate//go back
        }
    }
    jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
    if jewishCalendar.yomTovIndex() == kTishaBeav.rawValue {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman:zmanimCalendar.sunset(), isZman: true))
    }
    jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: -86400)
    temp.append(ZmanListEntry(title: zmanimNames.getSunsetString(), zman:zmanimCalendar.seaLevelSunset(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString(), zman:zmanimCalendar.tzaitAmudeiHoraah(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman:zmanimCalendar.tzaitAmudeiHoraahLChumra(), isZman: true))
    if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.currentDayOfTheWeek() != 6 {
        if jewishCalendar.currentDayOfTheWeek() == 7 {
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        } else {// just yom tov
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaitAmudeiHoraahLChumra(), isZman: true, isNoteworthyZman: true))
        }
    }
    if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag() + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.tzait72ZmanitAmudeiHoraahLkulah(), isZman: true, isNoteworthyZman: true, isRTZman: true))
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
            temp.append(ZmanListEntry(title: zmanimNames.getRTString(), zman: zmanimCalendar.tzait72ZmanitAmudeiHoraahLkulah(), isZman: true, isNoteworthyZman: true, isRTZman: true))
        }
    }
    temp.append(ZmanListEntry(title: zmanimNames.getChatzotLaylaString(), zman:zmanimCalendar.solarMidnight(), isZman: true))
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
        if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.currentDayOfTheWeek() == 7 {
            return "\u{05E9}\u{05D1}\u{05EA}/\u{05D7}\u{05D2}"
        } else if jewishCalendar.currentDayOfTheWeek() == 7 {
            return "\u{05E9}\u{05D1}\u{05EA}"
        } else {
            return "\u{05D7}\u{05D2}"
        }
    } else {
        if jewishCalendar.isYomTovAssurBemelacha() && jewishCalendar.currentDayOfTheWeek() == 7 {
            return "Shabbat/Chag";
        } else if jewishCalendar.currentDayOfTheWeek() == 7 {
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
    if defaults.bool(forKey: "useElevation") {
        GlobalStruct.useElevation = true
    } else {
        GlobalStruct.useElevation = false
    }
    if defaults.bool(forKey: "useZipcode") {
        locationName = defaults.string(forKey: "locationName") ?? ""
        lat = defaults.double(forKey: "lat")
        long = defaults.double(forKey: "long")
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
        timezone = TimeZone.init(identifier: defaults.string(forKey: "timezone")!)!
        completion(ComplexZmanimCalendar(location: GeoLocation(name: locationName, andLatitude: lat, andLongitude: long, andElevation: elevation, andTimeZone: timezone)))
    } else {
        LocationManager.shared.getUserLocation {
            location in DispatchQueue.main.async {
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
                    completion(ComplexZmanimCalendar(location: GeoLocation(name: locationName, andLatitude: lat, andLongitude: long, andElevation: elevation, andTimeZone: timezone)))
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
