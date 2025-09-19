//
//  Rabbi_Ovadiah_Yosef_Calendar_WidgetBundle.swift
//  Rabbi Ovadiah Yosef Calendar Widget
//
//  Created by Elyahu Jacobi on 8/27/23.
//

import WidgetKit
import SwiftUI

@main
struct Rabbi_Ovadiah_Yosef_Calendar_WidgetBundle: WidgetBundle {
    var body: some Widget {
        Rabbi_Ovadiah_Yosef_Calendar_Widget()
        UpcomingZmanim()
        if #available(iOSApplicationExtension 16.1, *) {
            Rabbi_Ovadiah_Yosef_Calendar_WidgetLiveActivity()
        }
    }
}

extension View {
    func widgetBackground(backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
