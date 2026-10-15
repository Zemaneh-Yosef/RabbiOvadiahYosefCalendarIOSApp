//
//  MainView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 10/7/24.
//

import SwiftUI
import KosherSwift

@main
struct MainView: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    
    @State private var selectedTab = 2 // Default tab
    
    @ViewBuilder
    private func tabContent(title: String) -> some View {
        if #available(iOS 16.0, *) {
            switch title {
            case "Limudim/Hillulot".localized():
                NavigationStack {
                    LimudimView()
                        .shrinkingNavigationTitle(title)
                }
            case "Rabbi Ovadia Yosef Calendar".localized():
                NavigationStack {
                    ZmanimView()
                        .shrinkingNavigationTitle(title)
                }
            case "Siddur".localized():
                NavigationStack {
                    SiddurChooserView()
                        .shrinkingNavigationTitle(title)
                }
            default:
                EmptyView()
            }
        } else {
            switch title {
            case "Limudim/Hillulot".localized():
                NavigationView {
                    LimudimView()
                        .shrinkingNavigationTitle(title)
                }
            case "Rabbi Ovadia Yosef Calendar".localized():
                NavigationView {
                    ZmanimView()
                        .shrinkingNavigationTitle(title)
                }
            case "Siddur".localized():
                NavigationView {
                    SiddurChooserView()
                        .shrinkingNavigationTitle(title)
                }
            default:
                EmptyView()
            }
        }
    }
    
    var body: some View {
        if #available(iOS 18.0, *) {
            TabView(selection: $selectedTab) {
                Tab("Limudim/Hillulot", systemImage: "text.justify", value: 1) {
                    tabContent(title: "Limudim/Hillulot".localized())
                }
                .badge(hasNissanLimudYomi() ? Text(getNissanTitle()) : nil)
                
                Tab("Zemanim", systemImage: "alarm", value: 2) {
                    tabContent(title: "Rabbi Ovadia Yosef Calendar".localized())
                }
                
                Tab("Siddur", systemImage: "book", value: 3) {
                    tabContent(title: "Siddur".localized())
                }
                .badge(hasSpecialPrayer() ? Text(getSpecialPrayerTitle()) : nil)
            }
        } else {
            TabView(selection: $selectedTab) {
                tabContent(title: "Limudim/Hillulot".localized())
                    .tabItem {
                        Label("Limudim/Hillulot", systemImage: "text.justify")
                    }
                    .tag(1)
                    .badge(hasNissanLimudYomi() ? Text(getNissanTitle()) : nil)

                tabContent(title: "Rabbi Ovadia Yosef Calendar".localized())
                    .tabItem {
                        Label("Zemanim", systemImage: "alarm")
                    }
                    .tag(2)

                tabContent(title: "Siddur".localized())
                    .tabItem {
                        Label("Siddur", systemImage: "book")
                    }
                    .tag(3)
                    .badge(hasSpecialPrayer() ? Text(getSpecialPrayerTitle()) : nil)
            }
        }
    }
}

func hasSpecialPrayer() -> Bool {
    let jewishCalendar = JewishCalendar()
    return jewishCalendar.getYomTovIndex() == JewishCalendar.TU_BESHVAT ||
    (jewishCalendar.getUpcomingParshah() == JewishCalendar.Parsha.BESHALACH && jewishCalendar.getDayOfWeek() == 3) ||
    (jewishCalendar.isErevRoshChodesh() && jewishCalendar.getJewishMonth() == JewishCalendar.IYAR)
}

func getSpecialPrayerTitle() -> String {
    let jewishCalendar = JewishCalendar()
    if jewishCalendar.getYomTovIndex() == JewishCalendar.TU_BESHVAT {
        return "Prayer for Etrog".localized()
    }
    if jewishCalendar.getUpcomingParshah() == JewishCalendar.Parsha.BESHALACH && jewishCalendar.getDayOfWeek() == 3 {
        return "Parshat Haman".localized()
    }
    if jewishCalendar.isErevRoshChodesh() && jewishCalendar.getJewishMonth() == JewishCalendar.IYAR {
        return "Tefilat HaShelah".localized()
    }
    return ""
}

func hasNissanLimudYomi() -> Bool {
    return JewishCalendar().getJewishMonth() == JewishCalendar.NISSAN
    && !NisanLimudYomi.getNisanLimudYomiTitle(day: JewishCalendar().getJewishDayOfMonth()).isEmpty
}

func getNissanTitle() -> String {
    return NisanLimudYomi.getNisanLimudYomiTitle(day: JewishCalendar().getJewishDayOfMonth())
}

struct AutoShrinkingNavigationTitle: ViewModifier {
    let title: String
    let minimumScaleFactor: CGFloat
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(minimumScaleFactor)
                }
            }
    }
}

extension View {
    @ViewBuilder
    func shrinkingNavigationTitle(_ title: String, minimumScaleFactor: CGFloat = 0.5) -> some View {
        if title.count <= 16 {// This is really specific to this app as Limudim/Hillulot is 16 characters long, but the main title is longer. You could add more or less characters depending on the title used.
            self.navigationTitle(title)
        } else {
            self.modifier(AutoShrinkingNavigationTitle(title: title, minimumScaleFactor: minimumScaleFactor))
        }
    }
}



#Preview {
    ContentView()
}
