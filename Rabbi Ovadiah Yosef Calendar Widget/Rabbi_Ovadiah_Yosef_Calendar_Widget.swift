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
        return SimpleEntry(
            dayOfWeek: "Sunday",
            hebrewDate: "1 Tishri, 5800".split(separator: " ").map { String($0) },
            parasha: "בראשית",
            upcomingZman: "Zman",
            date: Date(),
            tachanun: "Tachanun",
            daf: "שבת ב",
            configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        
        let formatter = HebrewDateFormatter()
        formatter.hebrewFormat = true
        formatter.useGershGershayim = false
        let daf = formatter.formatDafYomiBavli(daf: JewishCalendar().getDafYomiBavli()!)

        getZmanimCalendarWithLocation() { zmanimCalendar in
            let upcomingZman = getNextUpcomingZman(forTime: Date(), zmanimCalendar: zmanimCalendar)
            let jewishCalendar = getJewishCalendar()
            
            let entry = SimpleEntry(
                dayOfWeek: getDayOfWeek(),
                hebrewDate: getHebrewDate(),
                parasha: getParshah(jewishCalendar: jewishCalendar),
                upcomingZman: upcomingZman.title,
                date: upcomingZman.zman!,
                tachanun: jewishCalendar.getTachanun(),
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
                dayOfWeek: getDayOfWeek(),
                hebrewDate: getHebrewDate(),
                parasha: getParshah(jewishCalendar: getJewishCalendar()),
                upcomingZman: upcomingZman.title,
                date: upcomingZman.zman ?? Date(),
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
    let dayOfWeek: String
    let hebrewDate: [String]
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
            VStack(spacing: 0) {
                Spacer()
                Text(entry.dayOfWeek)
                    .font(.custom("Guttman Mantova", size: 26))
                    .bold()
                    .foregroundStyle(.red)
                                
                HStack(spacing: 1) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(entry.hebrewDate[1].replacingOccurrences(of: ",", with: ""))// Month
                            .font(Locale.isHebrewLocale() ? .custom("Guttman Mantova", size: 30) : .system(size: 30))
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .frame(alignment: .trailing)
                        Text(entry.hebrewDate[2])// Year
                            .font(Locale.isHebrewLocale() ? .custom("Guttman Mantova", size: 20) : .system(size: 20))
                            .foregroundStyle(.gray)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .frame(alignment: .trailing)
                    }
                    .padding(.trailing, 10)
                    
                    Text(entry.hebrewDate[0])// Day of month
                        .font(Locale.isHebrewLocale() ? .custom("Guttman Mantova", size: 80) : .system(size: 80))
                        .frame(alignment: .top)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .environment(\.layoutDirection, .leftToRight) // Force LTR
        case .systemMedium:
            HStack {
                VStack {
                    Text(entry.hebrewDate.joined(separator: " "))
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(.bottom, .leastNormalMagnitude)
                    Text(entry.parasha)
                        .font(.custom("Guttman Mantova", size: 18))
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
        default:
            VStack {
                Text(entry.hebrewDate.joined(separator: " "))
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
                .widgetBackground(backgroundView: EmptyView())
        }
        .configurationDisplayName("Rabbi Ovadiah Yosef Calendar Widget".localized())
        .description("This is a widget that will show relevant zmanim.".localized())
        .supportedFamilies([.systemSmall, .systemMedium])
        .contentMarginsDisabled()
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
            dayOfWeek: getDayOfWeek(),
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

func getDayOfWeek() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.string(from: Date())
}

func getHebrewDate() -> [String] {
    let hebrewDateFormatter = HebrewDateFormatter().withCorrectEnglishMonths()
    hebrewDateFormatter.hebrewFormat = Locale.isHebrewLocale()
    let hebrewDate = hebrewDateFormatter.format(jewishCalendar: JewishCalendar())
    var parts = hebrewDate.split(separator: " ").map { String($0) }
    parts[0] = parts[0]
        .replacingOccurrences(of: "׳", with: "")
        .replacingOccurrences(of: "״", with: "")
    return parts
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
                if location != nil {
                    lat = location!.coordinate.latitude
                    long = location!.coordinate.longitude
                    timezone = TimeZone.current
                    LocationManager.shared.resolveLocationName(with: location!) { name in
                        locationName = name ?? ""
                        let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
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
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    var theZman: ZmanListEntry? = nil
    var zmanim = Array<ZmanListEntry>()
    var today = forTime
    let jewishCalendar = getJewishCalendar()
    
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
