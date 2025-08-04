//
//  MainView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 10/7/24.
//

import SwiftUI
import KosherSwift

@main
@available(iOS 15.0, *)
struct MainView: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

@available(iOS 15.0, *)
struct ContentView: View {
    init() {
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }

    @State private var selectedTab = 2 // Default tab

    @ViewBuilder
    private func tabContent(title: String) -> some View {
        if #available(iOS 16.0, *) {
            switch title {
            case "Limudim/Hillulot".localized():
                NavigationStack {
                    LimudimView()
                        .navigationTitle(title)
                }
            case "Rabbi Ovadia Yosef Calendar".localized():
                NavigationStack {
                    ZmanimView()
                        .navigationTitle(title)
                }
            case "Siddur".localized():
                NavigationStack {
                    SiddurChooserView()
                        .navigationTitle(title)
                }
            default:
                EmptyView()
            }
        } else {
            switch title {
            case "Limudim/Hillulot".localized():
                NavigationView {
                    LimudimView()
                        .navigationTitle(title)
                }
            case "Rabbi Ovadia Yosef Calendar".localized():
                NavigationView {
                    ZmanimView()
                        .navigationTitle(title)
                }
            case "Siddur".localized():
                NavigationView {
                    SiddurChooserView()
                        .navigationTitle(title)
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
                Tab("Zmanim", systemImage: "alarm", value: 2) {
                    tabContent(title: "Rabbi Ovadia Yosef Calendar".localized())
                }
                Tab("Siddur", systemImage: "book", value: 3) {
                    tabContent(title: "Siddur".localized())
                }
            }
        } else {
            TabView(selection: $selectedTab) {
                tabContent(title: "Limudim/Hillulot".localized())
                    .tabItem {
                        Label("Limudim/Hillulot", systemImage: "text.justify")
                    }
                    .tag(1)

                tabContent(title: "Rabbi Ovadia Yosef Calendar".localized())
                    .tabItem {
                        Label("Zmanim", systemImage: "alarm")
                    }
                    .tag(2)

                tabContent(title: "Siddur".localized())
                    .tabItem {
                        Label("Siddur", systemImage: "book")
                    }
                    .tag(3)
            }
        }
    }
}

#Preview {
    if #available(iOS 15.0, *) {
        ContentView()
    } else {
        // Fallback on earlier versions
    }
}
