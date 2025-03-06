//
//  upcomingZmanim.swift
//  upcomingZmanim
//
//  Created by Elyahu Jacobi on 2/5/25.
//

import WidgetKit
import SwiftUI
import KosherSwift

struct UpcomingZmanimProvider: IntentTimelineProvider {
    func placeholder(in context: Context) -> UpcomingZmanimEntry {
        return UpcomingZmanimEntry(
            date: Date(),
            zmanimInHebrew: false,
            upcomingZmanim: [ZmanListEntry(title: "Mincha Gedolah".localized()),
                             ZmanListEntry(title: "Mincha Ketana".localized()),
                             ZmanListEntry(title: "Plag HaMincha (Halacha Berura)".localized()),
                             ZmanListEntry(title: "Plag HaMincha (Yalkut Yosef)".localized()),
                             ZmanListEntry(title: "Sunset".localized())])
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (UpcomingZmanimEntry) -> ()) {
        getZmanimCalendarWithLocation() { zmanimCalendar in
            completion(UpcomingZmanimEntry(
                date: Date(),
                zmanimInHebrew: false,
                upcomingZmanim: [ZmanListEntry(title: "Mincha Gedolah".localized()),
                                 ZmanListEntry(title: "Mincha Ketana".localized()),
                                 ZmanListEntry(title: "Plag HaMincha (Halacha Berura)".localized()),
                                 ZmanListEntry(title: "Plag HaMincha (Yalkut Yosef)".localized()),
                                 ZmanListEntry(title: "Sunset".localized())]))
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [UpcomingZmanimEntry] = []
        let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
        
        getZmanimCalendarWithLocation() { zmanimCalendar in
            let upcomingZmanim = getNextUpcomingZmanim(forTime: Date(), zmanimCalendar: zmanimCalendar)
            let entry = UpcomingZmanimEntry(
                date: upcomingZmanim.first!.zman ?? Date(),
                zmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"),
                upcomingZmanim: upcomingZmanim)
            
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

struct UpcomingZmanimEntry: TimelineEntry {
    var date: Date
    var zmanimInHebrew: Bool
    let upcomingZmanim: [ZmanListEntry]
}

struct upcomingZmanimEntryView : View {
    var entry: UpcomingZmanimProvider.Entry
    @Environment(\.widgetFamily) var family
    var dateFormat: DateFormatter {
        let dateFormatter = DateFormatter()
        if Locale.isHebrewLocale() {
            dateFormatter.dateFormat = "H:mm"
        } else {
            dateFormatter.dateFormat = "h:mm aa"
        }
        return dateFormatter
    }
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: 4) { // Reduce spacing between rows
            ForEach(0..<(family == .systemMedium ? 5 : 4), id: \.self) { index in
                HStack {
                    if entry.zmanimInHebrew && !Locale.isHebrewLocale() {
                        Text(entry.upcomingZmanim[index].zman ?? Date(), formatter: dateFormat)
                            .font(.system(size: 12))
                            .lineLimit(1)
                        Spacer()
                        Text(entry.upcomingZmanim[index].title.appending(index == 0 ? "➤" : ""))
                            .font(.system(size: 14))
                            .minimumScaleFactor(0.5)
                    } else {
                        Text(entry.upcomingZmanim[index].title.appending(index == 0 ? Locale.isHebrewLocale() ? "➤" : "◄" : ""))
                            .font(.system(size: 14))
                            .minimumScaleFactor(0.5)
                        Spacer()
                        Text(entry.upcomingZmanim[index].zman ?? Date(), formatter: dateFormat)
                            .font(.system(size: 12))
                            .lineLimit(1)
                    }
                }
                .overlay(Divider(), alignment: .bottom) // Add separator line
            }
        }
    }
}


struct UpcomingZmanim: Widget {
    let kind: String = "upcomingZmanim"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: UpcomingZmanimProvider()) { entry in
            upcomingZmanimEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Upcoming Zmanim Widget".localized())
        .description("Show the four next upcoming zmanim.".localized())
    }
}

func getNextUpcomingZmanim(forTime: Date, zmanimCalendar: ComplexZmanimCalendar) -> [ZmanListEntry] {
    let defaults = UserDefaults(suiteName: "group.com.elyjacobi.Rabbi-Ovadiah-Yosef-Calendar") ?? UserDefaults.standard
    var upcomingZmanim: [ZmanListEntry] = []
    var zmanim = Array<ZmanListEntry>()
    var today = forTime
    let jewishCalendar = getJewishCalendar()
    
    // Load yesterday's zmanim
    today = today.advanced(by: -86400)
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = ZmanimFactory.addZmanim(list: zmanim, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar)

    // Load today's zmanim
    today = today.advanced(by: 86400)
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = ZmanimFactory.addZmanim(list: zmanim, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar)

    // Load tomorrow's zmanim
    today = today.advanced(by: 86400)
    jewishCalendar.workingDate = today
    zmanimCalendar.workingDate = today
    zmanim = ZmanimFactory.addZmanim(list: zmanim, defaults: defaults, zmanimCalendar: zmanimCalendar, jewishCalendar: jewishCalendar)

    // Reset to the original date
    zmanimCalendar.workingDate = forTime
    jewishCalendar.workingDate = forTime
    
    // Filter upcoming zmanim (sorted by time)
    let filteredZmanim: [ZmanListEntry] = zmanim
        .filter { $0.zman != nil && $0.zman! > Date() }
        .sorted { $0.zman! < $1.zman! }
    
    // Take the next five zmanim
    upcomingZmanim = Array(filteredZmanim.prefix(5))
    
    // Ensure at least one entry is returned, even if there's an error
    if upcomingZmanim.isEmpty {
        return [ZmanListEntry(title: "Error", zman: Date())]
    }
    
    return upcomingZmanim
}
