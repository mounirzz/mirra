//
//  MirraWidgetLiveActivity.swift
//  MirraWidget
//
//  Created by Ezzahar on 19/07/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MirraWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MirraWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MirraWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MirraWidgetAttributes {
    fileprivate static var preview: MirraWidgetAttributes {
        MirraWidgetAttributes(name: "World")
    }
}

extension MirraWidgetAttributes.ContentState {
    fileprivate static var smiley: MirraWidgetAttributes.ContentState {
        MirraWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MirraWidgetAttributes.ContentState {
         MirraWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MirraWidgetAttributes.preview) {
   MirraWidgetLiveActivity()
} contentStates: {
    MirraWidgetAttributes.ContentState.smiley
    MirraWidgetAttributes.ContentState.starEyes
}
