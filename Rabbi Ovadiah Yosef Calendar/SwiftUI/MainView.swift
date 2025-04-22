//
//  MainView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 10/7/24.
//

import SwiftUI
import KosherSwift

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
            case "Limudim/Hillulot":
                NavigationStack {
                    LimudimView()
                        .navigationTitle(title)
                }
            case "Rabbi Ovadiah Yosef Calendar":
                NavigationStack {
                    ZmanimView()
                        .navigationTitle(title)
                }
            case "Siddur":
                NavigationStack {
                    SiddurChooserView()
                        .navigationTitle(title)
                }
            default:
                EmptyView()
            }
        } else {
            switch title {
            case "Limudim/Hillulot":
                NavigationView {
                    LimudimView()
                        .navigationTitle(title)
                }
            case "Rabbi Ovadiah Yosef Calendar":
                NavigationView {
                    ZmanimView()
                        .navigationTitle(title)
                }
            case "Siddur":
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
                    tabContent(title: "Limudim/Hillulot")
                }
                Tab("Zmanim", systemImage: "alarm", value: 2) {
                    tabContent(title: "Rabbi Ovadiah Yosef Calendar")
                }
                Tab("Siddur", systemImage: "book", value: 3) {
                    tabContent(title: "Siddur")
                }
            }
        } else {
            TabView(selection: $selectedTab) {
                tabContent(title: "Limudim/Hillulot")
                    .tabItem {
                        Label("Limudim/Hillulot", systemImage: "text.justify")
                    }
                    .tag(1)

                tabContent(title: "Rabbi Ovadiah Yosef Calendar")
                    .tabItem {
                        Label("Zmanim", systemImage: "alarm")
                    }
                    .tag(2)

                tabContent(title: "Siddur")
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
