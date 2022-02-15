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
        self.type = type
        self.previousScreenId = previousScreenId
        if let screenName = screenName {
            self.screenName = screenName
        } else {
            self.screenName = screenId
        }
    }
    
    func getSPEvent() -> SPPushNotification? {
        let event = SPPushNotification.build({(builder : SPPushNotificationBuilder?) -> Void in
            guard let builder = builder else { return nil }
            builder.setTrigger("PUSH") // can be "PUSH", "LOCATION", "CALENDAR", or "TIME_INTERVAL"
            builder.setAction("action")
            builder.setDeliveryDate("date")
            builder.setCategoryIdentifier("category")
            builder.setThreadIdentifier("thread")
        })
        return event
    }
    
    public override func track(_ tracker: SPTracker) {
        tracker.track(getSPEvent())
    }

}
