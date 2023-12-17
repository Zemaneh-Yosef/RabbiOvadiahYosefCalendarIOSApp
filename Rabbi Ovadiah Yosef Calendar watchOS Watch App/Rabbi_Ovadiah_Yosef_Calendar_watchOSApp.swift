//
//  Rabbi_Ovadiah_Yosef_Calendar_watchOSApp.swift
//  Rabbi Ovadiah Yosef Calendar watchOS Watch App
//
//  Created by User on 11/16/23.
//

import SwiftUI

@main
struct Rabbi_Ovadiah_Yosef_Calendar_watchOS_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(watchOS 10.0, *) {
                ContentView()
            } else {
                ContentViewNotSupported()
            }
        }
    }
}

struct ContentViewNotSupported: View {
    var body: some View {
        Text("This requires watchOS version 10.0 and higher")
    }
}
