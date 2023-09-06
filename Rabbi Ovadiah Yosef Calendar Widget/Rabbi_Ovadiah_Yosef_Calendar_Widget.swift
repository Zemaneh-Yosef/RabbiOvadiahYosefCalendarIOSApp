//
//  Rabbi_Ovadiah_Yosef_Calendar_Widget.swift
//  Rabbi Ovadiah Yosef Calendar Widget
//
//  Created by Macbook Pro on 8/27/23.
//

import WidgetKit
import SwiftUI
import Intents
import KosherCocoa

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {        
        var daf = ""
        
        let dafYomi = JewishCalendar().dafYomiBavli()
        if dafYomi != nil {
            daf = daf.appending(dafYomi!.name()).appending(" ").appending(dafYomi!.pageNumber.formatHebrew())
        }

        let upcomingZman = getNextUpcomingZman(forTime: Date(), zmanimCalendar: ComplexZmanimCalendar())
        
        let entry = SimpleEntry(
            hebrewDate: getHebrewDate(),
            parasha: getParshah(jewishCalendar: getJewishCalendar()),
            upcomingZman: upcomingZman.title,
            date: upcomingZman.zman!,
            tachanun: getJewishCalendar().getTachanun(),
            daf: daf,
            configuration: ConfigurationIntent())
        
        return entry
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        var daf = ""
        
        let dafYomi = JewishCalendar().dafYomiBavli()
        if dafYomi != nil {
            daf = daf.appending(dafYomi!.name()).appending(" ").appending(dafYomi!.pageNumber.formatHebrew())
        }
                
        getZmanimCalendarWithLocation() { zmanimCalendar in
            let upcomingZman = getNextUpcomingZman(forTime: Date(), zmanimCalendar: zmanimCalendar)
            
            let entry = SimpleEntry(
                hebrewDate: getHebrewDate(),
                parasha: getParshah(jewishCalendar: getJewishCalendar()),
                upcomingZman: upcomingZman.title,
                date: upcomingZman.zman!,
                tachanun: getJewishCalendar().getTachanun(),
                daf: daf,
                configuration: ConfigurationIntent())

            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        var daf = ""
        
        let dafYomi = JewishCalendar().dafYomiBavli()
        if dafYomi != nil {
            daf = daf.appending(dafYomi!.name()).appending(" ").appending(dafYomi!.pageNumber.formatHebrew())
        }
        
        
        getZmanimCalendarWithLocation() { zmanimCalendar in
            let upcomingZman = getNextUpcomingZman(forTime: Date(), zmanimCalendar: zmanimCalendar)
            
            let entry = SimpleEntry(
                hebrewDate: getHebrewDate(),
                parasha: getParshah(jewishCalendar: getJewishCalendar()),
                upcomingZman: upcomingZman.title,
                date: upcomingZman.zman!,
                tachanun: getJewishCalendar().getTachanun(),
                daf: daf,
                configuration: ConfigurationIntent())
            
            entries.append(entry)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            
            if UserDefaults.standard.string(forKey: "lastTimeNotificationsWereUpdated") != formatter.string(from: Date()) {
                NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
            }
            
            UserDefaults.standard.set(formatter.string(from: Date()), forKey: "lastTimeNotificationsWereUpdated")
                        
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let hebrewDate: String
    let parasha: String
    let upcomingZman: String
    let date: Date
    let tachanun: String
    let daf: String
    let configuration: ConfigurationIntent
}

struct Rabbi_Ovadiah_Yosef_Calendar_WidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family
    
    @ViewBuilder
    var body: some View {
        switch family {
            //        case .accessoryCircular:
            //            // Code to construct the view for the circular accessory widget or watch complication.
            //        case .accessoryRectangular:
            //            // Code to construct the view for the rectangular accessory widget or watch complication.
            //        case .accessoryInline:
            //            // Code to construct the view for the inline accessory widget or watch complication.
        case .systemSmall:
            VStack {
                Text(entry.hebrewDate)
                    .bold()
                    .padding(.bottom, .leastNormalMagnitude)
                Text(entry.parasha)
            }
        case .systemMedium:
            HStack {
                VStack {
                    Text(entry.hebrewDate)
                        .bold()
                        .padding(.bottom, .leastNormalMagnitude)
                    Text(entry.parasha)
                }.padding()
                VStack {
                    Text(entry.upcomingZman)
                        .padding(.bottom, .leastNormalMagnitude)
                    Text(entry.date, style: .time).bold()
                }.padding()
                VStack {
                    Text(entry.tachanun
                        .replacingOccurrences(of: "There is Tachanun today", with: "Tachanun")
                        .replacingOccurrences(of: "There is only Tachanun in the morning", with: "Tachanun Morning Only"))
                        .padding(.bottom, .leastNormalMagnitude)
                    Text(entry.daf)
                }.padding()
            }
        default:
            VStack {
                Text(entry.hebrewDate)
                    .bold()
                    .padding(.bottom, .leastNormalMagnitude)
                Text(entry.parasha)
            }
        }
    }
}

struct Rabbi_Ovadiah_Yosef_Calendar_Widget: Widget {
    let kind: String = "Rabbi_Ovadiah_Yosef_Calendar_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Rabbi_Ovadiah_Yosef_Calendar_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Rabbi Ovadiah Yosef Calendar Widget")
        .description("This is a widget that will show relevant zmanim.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct Rabbi_Ovadiah_Yosef_Calendar_Widget_Previews: PreviewProvider {
    static var previews: some View {
        var daf = ""
        
        let dafYomi = JewishCalendar().dafYomiBavli()
        if dafYomi != nil {
            daf = daf.appending(dafYomi!.name()).appending(" ").appending(dafYomi!.pageNumber.formatHebrew())
        }
        
        var cal = ComplexZmanimCalendar()
        
        getZmanimCalendarWithLocation() { zmanimCalendar in
            cal = zmanimCalendar
        }
        
        let upcomingZman = getNextUpcomingZman(forTime: Date(), zmanimCalendar: cal)
        
        let entry = SimpleEntry(
            hebrewDate: getHebrewDate(),
            parasha: getParshah(jewishCalendar: getJewishCalendar()),
            upcomingZman: upcomingZman.title,
            date: upcomingZman.zman!,
            tachanun: getJewishCalendar().getTachanun(),
            daf: daf,
            configuration: ConfigurationIntent())
        
        return Rabbi_Ovadiah_Yosef_Calendar_WidgetEntryView(entry: entry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

func getHebrewDate() -> String {
    let hebrewDateFormatter = DateFormatter()
    hebrewDateFormatter.calendar = Calendar(identifier: .hebrew)
    hebrewDateFormatter.dateFormat = "d MMMM, yyyy"
    return hebrewDateFormatter.string(from: Date())
}

func getZmanimCalendarWithLocation(completion: @escaping (ComplexZmanimCalendar) -> Void) {
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    
    var locationName = ""
    var lat = 0.0
    var long = 0.0
    var elevation = 0.0
    var timezone = TimeZone.current
    
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

func getNextUpcomingZman(forTime: Date, zmanimCalendar: ComplexZmanimCalendar) -> ZmanListEntry {
    
    var theZman: ZmanListEntry? = nil
    var zmanim = Array<ZmanListEntry>()
    var today = forTime
    let jewishCalendar = getJewishCalendar()
    
    today = today.advanced(by: -86400)//yesterday
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = addZmanim(list: zmanim, jewishCalendar: jewishCalendar, zmanimCalendar: zmanimCalendar)

    today = today.advanced(by: 86400)//today
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = addZmanim(list: zmanim, jewishCalendar: jewishCalendar, zmanimCalendar: zmanimCalendar)

    today = today.advanced(by: 86400)//tomorrow
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = addZmanim(list: zmanim, jewishCalendar: jewishCalendar, zmanimCalendar: zmanimCalendar)

    zmanimCalendar.workingDate = forTime//reset
    jewishCalendar.workingDate = forTime//reset
    
    for entry in zmanim {
        let zman = entry.zman
        if zman != nil {
            if zman! > Date() && (theZman == nil || zman! < theZman!.zman!) {
                theZman = entry
            }
        }
    }
    return theZman ?? ZmanListEntry(title: "Error", zman: Date())
}

func addZmanim(list:Array<ZmanListEntry>, jewishCalendar: JewishCalendar, zmanimCalendar: ComplexZmanimCalendar) -> Array<ZmanListEntry> {
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    
    if defaults.bool(forKey: "LuachAmudeiHoraah") {
        return addAmudeiHoraahZmanim(list:list, jewishCalendar: jewishCalendar, zmanimCalendar: zmanimCalendar)
    }
    GlobalStruct.useElevation = true
    var temp = list
    let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
    if jewishCalendar.isTaanis()
        && jewishCalendar.yomTovIndex() != kTishaBeav.rawValue
        && jewishCalendar.yomTovIndex() != kYomKippur.rawValue {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.alos72Zmanis(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.alos72Zmanis(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.talitTefilin(), isZman: true))
    let chaitables = ChaiTables(locationName: zmanimCalendar.geoLocation.locationName ?? "", jewishYear: jewishCalendar.currentHebrewYear(), defaults: defaults)
    let visibleSurise = chaitables.getVisibleSurise(forDate: zmanimCalendar.workingDate)
    if visibleSurise != nil {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true))
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
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString() + " (" + String(zmanimCalendar.ateretTorahSunsetOffset) + ")", zman:zmanimCalendar.tzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
                    } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
                    } else {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
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
        temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzeit(), isZman: true, isNoteworthyZman: true))
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
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString() + " (" + String(zmanimCalendar.ateretTorahSunsetOffset) + ")", zman:zmanimCalendar.tzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
        } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
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

func addAmudeiHoraahZmanim(list:Array<ZmanListEntry>, jewishCalendar: JewishCalendar, zmanimCalendar: ComplexZmanimCalendar) -> Array<ZmanListEntry> {
    GlobalStruct.useElevation = false
    var temp = list
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
    if jewishCalendar.isTaanis()
        && jewishCalendar.yomTovIndex() != kTishaBeav.rawValue
        && jewishCalendar.yomTovIndex() != kYomKippur.rawValue {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.alotAmudeiHoraah(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.alotAmudeiHoraah(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.talitTefilinAmudeiHoraah(), isZman: true))
    let chaitables = ChaiTables(locationName: zmanimCalendar.geoLocation.locationName ?? "", jewishYear: jewishCalendar.currentHebrewYear(), defaults: defaults)
    let visibleSurise = chaitables.getVisibleSurise(forDate: zmanimCalendar.workingDate)
    if visibleSurise != nil {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true))
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
                    temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true))
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
        temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.tzaitAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
    }
    if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString(), zman:zmanimCalendar.tzaitShabbatAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
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

func getShabbatAndOrChag(jewishCalendar: JewishCalendar) -> String {
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard

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

func getJewishCalendar() -> JewishCalendar {
    let jewishCalendar = JewishCalendar()
    jewishCalendar.returnsModernHolidays = true
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    
    jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
    
    return jewishCalendar
}

func getParshah(jewishCalendar:JewishCalendar) -> String {
    //forward jewish calendar to saturday
    while jewishCalendar.currentDayOfTheWeek() != 7 {
        jewishCalendar.workingDate = jewishCalendar.workingDate.advanced(by: 86400)
    }
    //now that we are on saturday, check the parasha
    let specialParasha = jewishCalendar.getSpecialParasha()
    var parasha = ""
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    
    if defaults.bool(forKey: "inIsrael") {
        parasha = ParashatHashavuaCalculator().parashaInIsrael(for: jewishCalendar.workingDate).name()
    } else {
        parasha = ParashatHashavuaCalculator().parashaInDiaspora(for: jewishCalendar.workingDate).name()
    }
    if !specialParasha.isEmpty {
        parasha += " / " + specialParasha
    }
    return parasha
}
