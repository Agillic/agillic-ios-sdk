//
//  ScreenViewEvent.swift
//  AgillicSDK

//  Copyright © 2021 Agillic. All rights reserved.
//

import Foundation
import SnowplowTracker

internal class AgillicPushNotification : AgillicTrackingEvent {
    var screenId: String
    var screenName: String
    var type: String?
    var previousScreenId: String?
    
    public init(_ screenId: String, screenName: String? = nil, type: String? = nil, previousScreenId: String? = nil) {
        self.screenId = screenId
        self.screenName = screenName != nil ? screenName! : screenId
        self.type = type
        self.previousScreenId = previousScreenId
    }
    
    func getSPEvent() -> SPPushNotification? {
        let event = SPPushNotification.build({(builder : SPPushNotificationBuilder?) -> Void in
            if let builder = builder {
                builder.setTrigger("PUSH") // can be "PUSH", "LOCATION", "CALENDAR", or "TIME_INTERVAL"
                builder.setAction("action")
                builder.setDeliveryDate("date")
                builder.setCategoryIdentifier("category")
                builder.setThreadIdentifier("thread")
            }
        })
        return event
    }
    
    public override func track(_ tracker: SPTracker) {
        tracker.track(getSPEvent())
    }

}
