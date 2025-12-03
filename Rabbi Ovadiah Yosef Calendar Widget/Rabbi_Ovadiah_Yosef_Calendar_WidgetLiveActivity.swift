//
//  Rabbi_Ovadiah_Yosef_Calendar_WidgetLiveActivity.swift
//  Rabbi Ovadiah Yosef Calendar Widget
//
//  Created by Elyahu Jacobi on 8/27/23.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var endTime: Date
    }

    // Fixed non-changing properties about your activity go here!
    var zmanName: String
}

@available(iOSApplicationExtension 16.1, *)
struct Rabbi_Ovadiah_Yosef_Calendar_WidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            if context.state.endTime.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                Text("The Zman has passed!")
            } else {
                VStack {
                    HStack {
                        Text(context.attributes.zmanName).font(.headline)
                        Text(" : ")
                        Text(context.state.endTime, style: .timer)
                    }
                    ProgressView(timerInterval: .init(uncheckedBounds: (Date(), context.state.endTime)))
                }
                .padding(.all)
            }
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(getHebrewDate(language: .systemDefault).joined(separator: " "))
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .padding(.leading, 1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(getParshah(jewishCalendar:getJewishCalendar()))
                        .padding(.trailing, 1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.endTime.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                        Text("The Zman has passed!")
                    } else {
                        VStack {
                            Text(context.attributes.zmanName).font(.headline).multilineTextAlignment(.center)
                            Text("is in:").multilineTextAlignment(.center)
                            Text(context.state.endTime, style: .timer).font(.headline).multilineTextAlignment(.center)
                        }.padding(.top)
                    }
                }
            } compactLeading: {
                Text(context.attributes.zmanName)
            } compactTrailing: {
                if context.state.endTime.timeIntervalSince1970 < Date().timeIntervalSince1970 {
                    Text("--:--:--").multilineTextAlignment(.trailing)
                } else {
                    Text(context.state.endTime, style: .timer).multilineTextAlignment(.trailing)
                }
            } minimal: {
                Text("⏱️")
            }
            .keylineTint(Color.red)
        }
    }
}

@available(iOSApplicationExtension 16.2, *)
struct Rabbi_Ovadiah_Yosef_Calendar_WidgetLiveActivity_Previews: PreviewProvider {
    static let attributes = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes(zmanName: "Alot Hashachar")
    static let contentState = Rabbi_Ovadiah_Yosef_Calendar_WidgetAttributes.ContentState(endTime: Date())

    static var previews: some View {
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.compact))
            .previewDisplayName("Island Compact")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
            .previewDisplayName("Island Expanded")
        attributes
            .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
            .previewDisplayName("Minimal")
        attributes
            .previewContext(contentState, viewKind: .content)
            .previewDisplayName("Notification")
    }
}
