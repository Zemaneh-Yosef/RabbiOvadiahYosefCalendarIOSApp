////
////  upcomingShabbatZmanim.swift
////  Rabbi Ovadiah Yosef Calendar
////
////  Created by Elyahu Jacobi on 11/12/25.
////
//
//import WidgetKit
//import SwiftUI
//import KosherSwift
//
//struct UpcomingShabbatZmanimProvider: IntentTimelineProvider {
//    func placeholder(in context: Context) -> UpcomingShabbatZmanimEntry {
//        return UpcomingShabbatZmanimEntry(
//            date: Date(),
//            zmanimInHebrew: false,
//            upcomingZmanim: [ZmanListEntry(title: "Mincha Gedolah".localized()),
//                             ZmanListEntry(title: "Mincha Ketana".localized()),
//                             ZmanListEntry(title: "Plag HaMincha (Halacha Berura)".localized()),
//                             ZmanListEntry(title: "Plag HaMincha (Yalkut Yosef)".localized()),
//                             ZmanListEntry(title: "Sunset".localized())])
//    }
//
//    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (UpcomingShabbatZmanimEntry) -> ()) {
//        getZmanimCalendarWithLocation() { zmanimCalendar in
//            completion(UpcomingShabbatZmanimEntry(
//                date: Date(),
//                zmanimInHebrew: false,
//                upcomingZmanim: [ZmanListEntry(title: "Mincha Gedolah".localized()),
//                                 ZmanListEntry(title: "Mincha Ketana".localized()),
//                                 ZmanListEntry(title: "Plag HaMincha (Halacha Berura)".localized()),
//                                 ZmanListEntry(title: "Plag HaMincha (Yalkut Yosef)".localized()),
//                                 ZmanListEntry(title: "Sunset".localized())]))
//        }
//    }
//
//    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [UpcomingShabbatZmanimEntry] = []
//        let defaults = UserDefaults.getMyUserDefaults()
//
//        getZmanimCalendarWithLocation() { zmanimCalendar in
//            let upcomingZmanim = getNextUpcomingZmanim(forTime: Date(), zmanimCalendar: zmanimCalendar)
//            let entry = UpcomingShabbatZmanimEntry(
//                date: upcomingZmanim.first!.zman ?? Date(),
//                zmanimInHebrew: defaults.bool(forKey: "isZmanimInHebrew"),
//                upcomingZmanim: upcomingZmanim)
//            
//            entries.append(entry)
//            
//            let formatter = DateFormatter()
//            formatter.dateFormat = "MM/dd/yyyy"
//            
//            if UserDefaults.standard.string(forKey: "lastTimeNotificationsWereUpdated") != formatter.string(from: Date()) {
//                NotificationManager.instance.initializeLocationObjectsAndSetNotifications()
//            }
//            
//            UserDefaults.standard.set(formatter.string(from: Date()), forKey: "lastTimeNotificationsWereUpdated")
//                        
//            let timeline = Timeline(entries: entries, policy: .atEnd)
//            completion(timeline)
//        }
//    }
//}
//
//struct UpcomingShabbatZmanimEntry: TimelineEntry {
//    var date: Date
//    var zmanimInHebrew: Bool
//    let upcomingZmanim: [ZmanListEntry]
//}
//
//struct upcomingShabbatZmanimEntryView : View {
//    var entry: UpcomingShabbatZmanimProvider.Entry
//    @Environment(\.widgetFamily) var family
//    var dateFormat: DateFormatter {
//        let dateFormatter = DateFormatter()
//        if Locale.isHebrewLocale() {
//            dateFormatter.dateFormat = "H:mm"
//        } else {
//            dateFormatter.dateFormat = "h:mm aa"
//        }
//        return dateFormatter
//    }
//    
//    @ViewBuilder
//    var body: some View {
//        VStack(spacing: 4) { // Reduce spacing between rows
//            ForEach(0..<(family == .systemMedium ? 5 : 4), id: \.self) { index in
//                HStack {
//                    if entry.zmanimInHebrew && !Locale.isHebrewLocale() {
//                        Text(entry.upcomingZmanim[index].zman ?? Date(), formatter: dateFormat)
//                            .font(.system(size: 12))
//                            .lineLimit(1)
//                        Spacer()
//                        Text(entry.upcomingZmanim[index].title.appending(index == 0 ? "➤" : ""))
//                            .font(.system(size: 14))
//                            .minimumScaleFactor(0.5)
//                    } else {
//                        Text(entry.upcomingZmanim[index].title.appending(index == 0 ? Locale.isHebrewLocale() ? "➤" : "◄" : ""))
//                            .font(.system(size: 14))
//                            .minimumScaleFactor(0.5)
//                        Spacer()
//                        Text(entry.upcomingZmanim[index].zman ?? Date(), formatter: dateFormat)
//                            .font(.system(size: 12))
//                            .lineLimit(1)
//                    }
//                }
//                .overlay(Divider(), alignment: .bottom) // Add separator line
//            }
//        }
//    }
//}
//
//struct UpcomingShabbatZmanim: Widget {
//    let kind: String = "upcomingZmanim"
//
//    var body: some WidgetConfiguration {
//        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: UpcomingShabbatZmanimProvider()) { entry in
//            upcomingShabbatZmanimEntryView(entry: entry)
//                .widgetBackground(backgroundView: EmptyView())
//        }
//        .supportedFamilies([.systemSmall, .systemMedium])
//        .configurationDisplayName("Upcoming Zmanim Widget".localized())
//        .description("Show the four next upcoming zmanim.".localized())
//    }
//}
