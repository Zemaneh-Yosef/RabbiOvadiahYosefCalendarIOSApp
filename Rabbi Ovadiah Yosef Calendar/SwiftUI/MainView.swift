//
//  MainView.swift
//  Rabbi Ovadiah Yosef Calendar
//
//  Created by Elyahu Jacobi on 10/7/24.
//

import SwiftUI

@available(iOS 16.0, *)
struct MainView: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

@available(iOS 16.0, *)
struct ContentView: View {
    init() {
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }
    var body: some View {
        if #available(iOS 18.0, *) {
            TabView {
                Tab("Limudim/Hillulot", systemImage: "text.justify", content: {
                    NavigationStack {
                        List{
                            
                        }
                        .navigationTitle("Limudim/Hillulot")
                    }
                })
                Tab("Zmanim", systemImage: "alarm", content: {
                    NavigationStack {
                        List{
                            
                        }
                        .navigationTitle("Rabbi Ovadiah Yosef Calendar")
                    }
                })
                Tab("Siddur", systemImage: "book", content: {
                    NavigationStack {
                        HStack {
                            
                        }
                        .navigationTitle("Siddur")
                    }
                })
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        ContentView()
    } else {
        // No fallback on earlier versions
    }
}
