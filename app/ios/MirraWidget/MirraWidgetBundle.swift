//
//  MirraWidgetBundle.swift
//  MirraWidget
//
//  Created by Ezzahar on 19/07/2026.
//

import WidgetKit
import SwiftUI

@main
struct MirraWidgetBundle: WidgetBundle {
    var body: some Widget {
        MirraWidget()
        MirraWidgetControl()
        MirraWidgetLiveActivity()
    }
}
