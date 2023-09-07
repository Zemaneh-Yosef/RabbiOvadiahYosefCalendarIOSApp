//
//  Rabbi_Ovadiah_Yosef_Calendar_WidgetLiveActivity.swift
//  Rabbi Ovadiah Yosef Calendar Widget
//
//  Created by Macbook Pro on 8/27/23.
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
            VStack {
                HStack {
                    Text(context.attributes.zmanName).font(.headline)
                    Text(" : ")
                    Text(context.state.endTime, style: .timer)
                }//TODO instead of timer counting up, say "Zman has passed!"
                ProgressView(timerInterval: .init(uncheckedBounds: (Date(), context.state.endTime)))
            }
            .padding(.all)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text(getHebrewDate())
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(getParshah(jewishCalendar:getJewishCalendar()))
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.attributes.zmanName).font(.headline).padding()
                        Spacer()
                        Text(" is in: ").padding(.leading).padding(.leading).padding(.leading).padding(.leading)
                        Spacer()
                        Text(context.state.endTime, style: .timer).multilineTextAlignment(.trailing)
                    }.padding(.top)
                }
            } compactLeading: {
                Text(context.attributes.zmanName)
            } compactTrailing: {
                Text(context.state.endTime, style: .timer).multilineTextAlignment(.trailing)
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
