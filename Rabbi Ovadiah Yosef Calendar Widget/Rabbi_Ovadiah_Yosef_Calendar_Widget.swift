//
//  Rabbi_Ovadiah_Yosef_Calendar_Widget.swift
//  Rabbi Ovadiah Yosef Calendar Widget
//
//  Created by Elyahu Jacobi on 8/27/23.
//

import WidgetKit
import SwiftUI
import Intents
import KosherSwift

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {        
        let formatter = HebrewDateFormatter()
        formatter.hebrewFormat = true
        formatter.useGershGershayim = false
        let daf = formatter.formatDafYomiBavli(daf: JewishCalendar().getDafYomiBavli()!)

        let entry = SimpleEntry(
            hebrewDate: getHebrewDate(),
            parasha: getParshah(jewishCalendar: getJewishCalendar()),
            upcomingZman: "Zman",
            date: Date(),
            tachanun: getJewishCalendar().getTachanun(),
            daf: daf,
            configuration: ConfigurationIntent())
        
        return entry
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        let formatter = HebrewDateFormatter()
        formatter.hebrewFormat = true
        formatter.useGershGershayim = false
        let daf = formatter.formatDafYomiBavli(daf: JewishCalendar().getDafYomiBavli()!)

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
        
        let formatter = HebrewDateFormatter()
        formatter.hebrewFormat = true
        formatter.useGershGershayim = false
        let daf = formatter.formatDafYomiBavli(daf: JewishCalendar().getDafYomiBavli()!)

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
                }
                VStack {
                    Text(entry.upcomingZman)
                        .padding(.bottom, .leastNormalMagnitude)
                    Text(entry.date, style: .time).bold()
                }
                VStack {
                    Text(entry.tachanun
                        .replacingOccurrences(of: "There is Tachanun today", with: "Tachanun")
                        .replacingOccurrences(of: "There is only Tachanun in the morning", with: "Tachanun Morning Only"))
                        .padding(.bottom, .leastNormalMagnitude)
                    Text(entry.daf)
                }
            }
        case .systemLarge:
            HStack {
                VStack {
                    Text(entry.hebrewDate)
                        .bold().padding()
                    Text(entry.parasha)
                        .padding()
                    Text(entry.tachanun
                        .replacingOccurrences(of: "There is Tachanun today", with: "Tachanun")
                        .replacingOccurrences(of: "There is only Tachanun in the morning", with: "Tachanun Morning Only"))
                    .padding()
                    Text(entry.daf)
                }
                VStack {
                    Text(entry.upcomingZman).padding()
                    Text(entry.date, style: .time).bold()
                }
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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct Rabbi_Ovadiah_Yosef_Calendar_Widget_Previews: PreviewProvider {
    static var previews: some View {
        let formatter = HebrewDateFormatter()
        formatter.hebrewFormat = true
        formatter.useGershGershayim = false
        let daf = formatter.formatDafYomiBavli(daf: JewishCalendar().getDafYomiBavli()!)

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
        .replacingOccurrences(of: "Heshvan", with: "Cheshvan")
        .replacingOccurrences(of: "Tamuz", with: "Tammuz")
}

func getZmanimCalendarWithLocation(completion: @escaping (ComplexZmanimCalendar) -> Void) {
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    
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
        let concurrentQueue = DispatchQueue(label: "widget", attributes: .concurrent)

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
    zmanimCalendar.useElevation = true
    var temp = list
    let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
    if jewishCalendar.isTaanis()
        && jewishCalendar.getYomTovIndex() != JewishCalendar.TISHA_BEAV
        && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.getAlos72Zmanis(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.getAlos72Zmanis(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.getMisheyakir66MinutesZmanit(), isZman: true))
    if defaults.bool(forKey: "showPreferredMisheyakirZman") {
        temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString().appending(" ").appending(zmanimNames.getBetterString()), zman: zmanimCalendar.getMisheyakir60MinutesZmanit(), isZman: true))
    }
    let chaitables = ChaiTables(locationName: zmanimCalendar.geoLocation.locationName , jewishCalendar: jewishCalendar, defaults: defaults)
    let visibleSurise = chaitables.getVisibleSurise(forDate: zmanimCalendar.workingDate)
    if visibleSurise != nil {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
    }
    if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.getSofZmanShmaMGA72MinutesZmanis(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.getSofZmanShmaGRA(), isZman: true))
    if (jewishCalendar.isBirkasHachamah()) {
        //TODO make sure this is supposed to be calculated as 3 GRA hours
        temp.append(ZmanListEntry(title: zmanimNames.getBirkatHachamaString(), zman: zmanimCalendar.getSofZmanShmaGRA(), isZman: true))
    }
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
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString() + " (" + String(Int(zmanimCalendar.ateretTorahSunsetOffset)) + ")", zman:zmanimCalendar.getTzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
                    } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString() + " (7.14°)", zman:zmanimCalendar.getTzaisShabbosAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
                    } else {
                        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisShabbosAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
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
        zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
        if defaults.object(forKey: "shabbatOffset") != nil {
            zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
        }
        if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
        } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisShabbosAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisShabbosAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
        }
    }
    if jewishCalendar.isTaanis() && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + zmanimNames.getTaanitString() + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisAteretTorah(minutes: 20), isZman: true, isNoteworthyZman: true))
    } else if defaults.bool(forKey: "showTzeitLChumra") {
        temp.append(ZmanListEntry(title: zmanimNames.getTzaitHacochavimString() + " " + zmanimNames.getLChumraString(), zman: zmanimCalendar.getTzaisAteretTorah(minutes: 20), isZman: true))
    }
    if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
        zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40
        if defaults.object(forKey: "shabbatOffset") != nil {
            zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
        }
        if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString() + " (" + String(Int(zmanimCalendar.ateretTorahSunsetOffset)) + ")", zman:zmanimCalendar.getTzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
        } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString() + " (7.14°)", zman:zmanimCalendar.getTzaisShabbosAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        } else {
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisShabbosAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
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

func addAmudeiHoraahZmanim(list:Array<ZmanListEntry>, jewishCalendar: JewishCalendar, zmanimCalendar: ComplexZmanimCalendar) -> Array<ZmanListEntry> {
    zmanimCalendar.useElevation = false
    var temp = list
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    let zmanimNames = ZmanimTimeNames.init(mIsZmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"), mIsZmanimEnglishTranslated: defaults.bool(forKey: "isZmanimEnglishTranslated"))
    if jewishCalendar.isTaanis()
        && jewishCalendar.getYomTovIndex() != JewishCalendar.TISHA_BEAV
        && jewishCalendar.getYomTovIndex() != JewishCalendar.YOM_KIPPUR {
        temp.append(ZmanListEntry(title: zmanimNames.getTaanitString() + zmanimNames.getStartsString(), zman: zmanimCalendar.getAlosAmudeiHoraah(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getAlotString(), zman: zmanimCalendar.getAlosAmudeiHoraah(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getTalitTefilinString(), zman: zmanimCalendar.getMisheyakirAmudeiHoraah(), isZman: true))
    let chaitables = ChaiTables(locationName: zmanimCalendar.geoLocation.locationName , jewishCalendar: jewishCalendar, defaults: defaults)
    let visibleSurise = chaitables.getVisibleSurise(forDate: zmanimCalendar.workingDate)
    if visibleSurise != nil {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString(), zman: visibleSurise, isZman: true))
    } else {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
    }
    if visibleSurise != nil && defaults.bool(forKey: "alwaysShowMishorSunrise") {
        temp.append(ZmanListEntry(title: zmanimNames.getHaNetzString() + " (" + zmanimNames.getMishorString() + ")", zman: zmanimCalendar.getSeaLevelSunrise(), isZman: true))
    }
    temp.append(ZmanListEntry(title: zmanimNames.getShmaMgaString(), zman:zmanimCalendar.getSofZmanShmaMGA72MinutesZmanisAmudeiHoraah(), isZman: true))
    temp.append(ZmanListEntry(title: zmanimNames.getShmaGraString(), zman:zmanimCalendar.getSofZmanShmaGRA(), isZman: true))
    if (jewishCalendar.isBirkasHachamah()) {
        //TODO make sure this is supposed to be calculated as 3 GRA hours
        temp.append(ZmanListEntry(title: zmanimNames.getBirkatHachamaString(), zman: zmanimCalendar.getSofZmanShmaGRA(), isZman: true))
    }
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
                    temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString() + zmanimNames.getMacharString(), zman:zmanimCalendar.getTzaisShabbosAmudeiHoraah(), isZman: true))
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
    if (jewishCalendar.hasCandleLighting() && jewishCalendar.isAssurBemelacha()) && jewishCalendar.getDayOfWeek() != 6 {
        temp.append(ZmanListEntry(title: zmanimNames.getCandleLightingString(), zman:zmanimCalendar.getTzaisShabbosAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
    }
    if jewishCalendar.isAssurBemelacha() && !jewishCalendar.hasCandleLighting() {
        if !defaults.bool(forKey: "overrideAHEndShabbatTime") {// default zman
            temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString() + " (7.14°)", zman:zmanimCalendar.getTzaisShabbosAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
        } else {// if user wants to override
            zmanimCalendar.ateretTorahSunsetOffset = defaults.bool(forKey: "inIsrael") ? 30 : 40 // should never be used in Israel
            if defaults.object(forKey: "shabbatOffset") != nil {
                zmanimCalendar.ateretTorahSunsetOffset = Double(defaults.integer(forKey: "shabbatOffset"))
            }
            if defaults.integer(forKey: "endOfShabbatOpinion") == 1 || defaults.object(forKey: "endOfShabbatOpinion") == nil {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString() + " (" + String(Int(zmanimCalendar.ateretTorahSunsetOffset)) + ")", zman:zmanimCalendar.getTzaisAteretTorah(), isZman: true, isNoteworthyZman: true))
            } else if defaults.integer(forKey: "endOfShabbatOpinion") == 2 {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString() + " (7.14°)", zman:zmanimCalendar.getTzaisShabbosAmudeiHoraah(), isZman: true, isNoteworthyZman: true))
            } else {
                temp.append(ZmanListEntry(title: zmanimNames.getTzaitString() + getShabbatAndOrChag(jewishCalendar: jewishCalendar) + zmanimNames.getEndsString(), zman:zmanimCalendar.getTzaisShabbosAmudeiHoraahLesserThan40(), isZman: true, isNoteworthyZman: true))
            }
        }
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

func getShabbatAndOrChag(jewishCalendar: JewishCalendar) -> String {
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard

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

func getJewishCalendar() -> JewishCalendar {
    let jewishCalendar = JewishCalendar()
    jewishCalendar.useModernHolidays = true
    
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    
    jewishCalendar.inIsrael = defaults.bool(forKey: "inIsrael")
    
    return jewishCalendar
}

func getParshah(jewishCalendar:JewishCalendar) -> String {
    //forward jewish calendar to saturday
    while jewishCalendar.getDayOfWeek() != 7 {
        jewishCalendar.forward()
    }
    let hebrewDateFormatter = HebrewDateFormatter()
    hebrewDateFormatter.hebrewFormat = true
    //now that we are on saturday, check the parasha
    var parasha = hebrewDateFormatter.formatParsha(parsha: jewishCalendar.getParshah())
    let specialParasha = hebrewDateFormatter.formatSpecialParsha(jewishCalendar: jewishCalendar)
    
    if !specialParasha.isEmpty {
        parasha += " / " + specialParasha
    }
    if !parasha.isEmpty {
        return parasha
    } else {
        return "No Weekly Parasha".localized()
    }
}
